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
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    //Pegando o diretorio
    final diretorio = await getApplicationDocumentsDirectory();
    //Criando um arquivo no dispositivo
    return File("${diretorio.path}/dados.json");
  }

  _salvarTarefa() {
    String textoDigitado = _controllerTarefa.text;

    //Criando um map para passar para o arquivo json
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;

    setState(() {
      //Adicionando na lista
      _listaTarefa.add(tarefa);
    });
    _salvarArquivo();
    _controllerTarefa.text = "";
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();

    //Convertendo os dados em json
    String dados = json.encode(_listaTarefa);
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
    _lerArquivo().then((dados) {
      setState(() {
        _listaTarefa = json.decode(dados);
      });
    });
  }

  Widget criarItemLista(context, index) {
    final item = _listaTarefa[index]['titulo'];

    return Dismissible(
      key: Key(item),
      direction: DismissDirection.endToStart,
      onDismissed: (direction){
        _listaTarefa.removeAt(index);
        _salvarArquivo();
      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment:  MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white,)
          ],
        ),
      ),
      child: CheckboxListTile(
          title: Text(_listaTarefa[index]['titulo']),
          value: _listaTarefa[index]['realizada'],
          onChanged: (valorAlterado) {
            setState(() {
              _listaTarefa[index]['realizada'] = valorAlterado;
            });
            _salvarArquivo();
          }),
    );
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
              itemBuilder: criarItemLista,
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
                    controller: _controllerTarefa,
                    decoration: InputDecoration(
                      labelText: "Digite sua tarefa",
                    ),
                    onChanged: (text) {},
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("CANCELAR"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _salvarTarefa();
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
