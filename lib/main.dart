import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_teste/telaInicial.dart';

//  modelo que será armazenada no Hive
@HiveType(typeId: 0)
class Produto extends HiveObject {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late String nome;

  @HiveField(2)
  late double preco;

  Produto(this.id, this.nome, this.preco);
}

@HiveType(typeId: 1)
class Desconto extends HiveObject {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late String nome;

  @HiveField(2)
  late double desconto;

  @HiveField(3)
  late List<int> produtosAplicaveis;

  Desconto(this.id, this.nome, this.desconto, this.produtosAplicaveis);
}

void main() async {
  await Hive.deleteFromDisk();
  await Hive.initFlutter();
  Hive.registerAdapter(ProdutoAdapter());
  Hive.registerAdapter(DescontoAdapter());
  await Future.wait([
    Hive.openBox<Produto>('produtos'),
    Hive.openBox<Desconto>('descontos'),
  ]);

  var boxProdutos = Hive.box<Produto>('produtos');
  var boxDescontos = Hive.box<Desconto>('descontos');

  if (boxProdutos.isEmpty) {
    boxProdutos.add(Produto(1, 'Churros', 5.00));
    boxProdutos.add(Produto(2, 'Burguer', 10.00));
    boxProdutos.add(Produto(3, 'Nachos', 7.00));
    boxProdutos.add(Produto(4, 'Coca', 5.00));
    boxProdutos.add(Produto(5, 'Gilete', 15.00));
    boxProdutos.add(Produto(6, 'Old Spice', 20.00));

    List<String> subCategorias = [
      'Churros',
      'Burger',
      'Nachos',
      'Coca',
      'Gilete',
      'Old Spice'
    ];

    for (var i = 7; i < 10; i++) {
      boxProdutos.add(Produto(
          i,
          subCategorias[Random().nextInt(subCategorias.length - 1)] + ' $i',
          (i) * 10 + (i + 1)));
    }
  }

  if (boxDescontos.isEmpty) {
    boxDescontos.add(Desconto(1, 'Descontaço de comida', 50, [1, 5, 3]));
    boxDescontos.add(Desconto(2, 'Descontaço de banheiro', 25, [4, 5]));
  }

  runApp(MyApp());
}

class ProdutoAdapter extends TypeAdapter<Produto> {
  @override
  final int typeId = 0;

  @override
  Produto read(BinaryReader reader) {
    return Produto(
      reader.read(),
      reader.read(),
      reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Produto obj) {
    writer.write(obj.id);
    writer.write(obj.nome);
    writer.write(obj.preco);
  }
}

class DescontoAdapter extends TypeAdapter<Desconto> {
  @override
  final int typeId = 1;

  @override
  Desconto read(BinaryReader reader) {
    return Desconto(reader.read(), reader.read(), reader.read(),
        List<int>.from(reader.readList()));
  }

  @override
  void write(BinaryWriter writer, Desconto obj) {
    writer.write(obj.id);
    writer.write(obj.nome);
    writer.write(obj.desconto);
    writer.writeList(obj.produtosAplicaveis);
  }
}
