import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _listaTarefa = [];

  Future<File> _getFile() async {
    //Pegando o diretorio
    final diretorio = await getApplicationDocumentsDirectory();
    //Criando um arquivo no dispositivo
    return File("${diretorio.path}/dados.json");
  }
  

  _salvarArquivo() async {

    var arquivo = await _getFile();

    //Criando um map para passar para o arquivo json
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = "Ir ao mercado";
    tarefa["realizada"] = false;
    //Adicionando na lista
    _listaTarefa.add(tarefa);

    //Convertendo os dados em json
    String dados =json.encode(_listaTarefa);
    //Escrevendo no arquivo
    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {

    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      print(e.toString());
      return null;
    }

  }

  @override
  void initState() {
    super.initState();
    _lerArquivo().then( (dados){
      setState(() {
        _listaTarefa = json.decode(dados);
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    //_salvarArquivo();

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                print(_listaTarefa.toString());
                return ListTile(
                  title: Text(_listaTarefa[index]['titulo']),
                );
              },
              itemCount: _listaTarefa.length,
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Adicionar tarefa"),
                  content: TextField(
                    decoration: InputDecoration(labelText: "Digite sua tarefa"),
                    onChanged: (text) {},
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("CANCELAR"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("SALVAR"),
                    )
                  ],
                );
              });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        elevation: 8,
      ),
    );
  }
}
