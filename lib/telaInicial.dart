import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_teste/export.dart';
import 'package:hive_teste/main.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lista Hive'),
        ),
        body: FutureBuilder(
          // Abre a caixa do Hive
          future: Future.wait([
            Hive.openBox<Desconto>('descontos'),
            Hive.openBox<Produto>('produtos'),
          ]),
          builder: (context, snapshot) {
            // Garante que você não tente acessar a caixa do Hive antes que ela
            // esteja completamente pronta para uso

            if (snapshot.connectionState == ConnectionState.done) {
              if (Hive.isBoxOpen('descontos') && Hive.isBoxOpen('produtos')) {
                return Column(
                  children: [
                    _buildListView<Desconto>('descontos'),
                    _buildListView<Produto>('produtos'),
                  ],
                );
              } else {
                return Center(
                  child: Text('Erro ao abrir uma ou ambas as caixas.'),
                );
              }
            } else {
              // Indicador de carregamento enquanto a caixa do Hive está sendo aberta
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () async {
                var box = Hive.box<Desconto>('descontos');
                for (var i = 0; i < 1000; i++) {
                  await box.add(Desconto(
                    i + 1,
                    'Novo Desconto ${box.length + 1}',
                    0.0,
                    [],
                  ));
                }
              },
              child: Icon(Icons.attach_money),
            ),
            SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () async {
                var box = Hive.box<Produto>('produtos');
                for (var i = 0; i < 1000; i++) {
                  await box.add(Produto(
                    i + 1,
                    'Novo Item ${box.length + 1}',
                    0.0,
                  ));
                }
              },
              child: Icon(Icons.add_circle_sharp),
            ),
            SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () async {
                var boxProdutos = Hive.box<Produto>('produtos');
                var boxDescontos = Hive.box<Desconto>('descontos');
                boxProdutos.clear();
                boxDescontos.clear();
              },
              child: Icon(Icons.delete),
            ),
            SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () async {
                // exportToJSON(Hive.box<Produto>('produtos'));
                // exportToJSON(Hive.box<Desconto>('descontos'));
              },
              child: Icon(Icons.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView<T>(String boxName) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: Hive.box<T>(boxName).listenable(),
        builder: (context, box, widget) {
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              var item = box.getAt(index);
              if (item is Desconto) {
                var produtosString =
                    _getProdutosString(item.produtosAplicaveis);
                return ListTile(
                  title: Text(item.nome),
                  subtitle: Text("Desconto: ${item.desconto}%"),
                  trailing: Text("Produtos: $produtosString"),
                );
              } else if (item is Produto) {
                var descontosAssociados = _getDescontosAssociados(item.id);
                var precoComDesconto = _calcularPrecoComDesconto(item);
                return ListTile(
                  title: Text(item.nome),
                  subtitle: Text("Preço: ${item.preco.toStringAsFixed(2)}"),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Descontos: $descontosAssociados"),
                      Text("Preço com desconto: $precoComDesconto"),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            },
          );
        },
      ),
    );
  }

  String _getProdutosString(List<int> ids) {
    var boxProdutos = Hive.box<Produto>('produtos');
    var produtos =
        boxProdutos.values.where((produto) => ids.contains(produto.id));
    return produtos.map((produto) => produto.nome).join(', ');
  }

  String _getDescontosAssociados(int produtoId) {
    var boxDescontos = Hive.box<Desconto>('descontos');
    var descontos = boxDescontos.values
        .where((desconto) => desconto.produtosAplicaveis.contains(produtoId))
        .map((desconto) => "${desconto.nome} (${desconto.desconto}%)")
        .join(', ');
    return descontos.isEmpty ? 'Nenhum desconto aplicado' : descontos;
  }

  double _calcularPrecoComDesconto(Produto produto) {
    var boxDescontos = Hive.box<Desconto>('descontos');
    var descontosAssociados = boxDescontos.values
        .where((d) => d.produtosAplicaveis.contains(produto.id))
        .map((d) => d.desconto)
        .fold(0.0, (previous, current) => previous + current);

    return produto.preco - (produto.preco * (descontosAssociados / 100));
  }
}
