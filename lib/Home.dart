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
  //Lista para armazenar as tarefas
  List _listaTarefa = [];
  //Um Map para armazenar a tarefa excluida
  Map<String, dynamic> _ultimaTarefaRemovida = Map();
  //Armazena a o texto digitado pelo usuário
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    //Pegando o diretorio
    final diretorio = await getApplicationDocumentsDirectory();
    //Criando um arquivo no dispositivo
    return File("${diretorio.path}/dados.json");
  }

  //Função responsavel por salvar a tarefa
  _salvarTarefa() {
    //Esta variável armazena o texto digitado pelo usuário
    String textoDigitado = _controllerTarefa.text;

    //Criando um map para passar para o arquivo json
    Map<String, dynamic> tarefa = Map();
    //Cria a "chave" titulo e o seu valor é o texto digitado
    tarefa["titulo"] = textoDigitado;
    //Cria a "chave" realizada e o seu valor é boolean para controlar sua realização
    tarefa["realizada"] = false;

    setState(() {
      //Adicionando na lista
      _listaTarefa.add(tarefa);
    });
    _salvarArquivo();
    //Limpa o campo texto ao finalizar de salvar a tarefa
    _controllerTarefa.text = "";
  }

  //Função responsável por salvar as informações em um arquivo
  _salvarArquivo() async {
    //Varíavel responsavel por pegar o arquivo
    var arquivo = await _getFile();

    //Convertendo as informações de _listaTarefa em json
    String dados = json.encode(_listaTarefa);
    //Escreve no arquivo as informações no formato json
    arquivo.writeAsString(dados);
  }

  //Função responsável por ler o arquivo
  _lerArquivo() async {
    //Ela tenta abrir o arquivo
    try {
      //Pega o arquivo
      final arquivo = await _getFile();
      //Retorna o arquivo de json para String
      return arquivo.readAsString();
      //Caso não consiga ela emite um erro que é enviado para o console
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //Quando o app é iniciado ele lê o arquivo e convert a string em json
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
    //final item = _listaTarefa[index]['titulo'];

    //Widget responsavel por criar o efeito de deslizar do item e deletar o mesmo
    return Dismissible(
      //Valor diferente deste o chamado da função
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      //A direção que têm que ser feita para remover o item
      direction: DismissDirection.endToStart,
      //Propriedade responsável pela remoção do item
      onDismissed: (direction) {

        //Recuperando o ultimo item excluído
        _ultimaTarefaRemovida = _listaTarefa[index];

        //Remove o item da lista usando o index que é passado
        _listaTarefa.removeAt(index);
        _salvarArquivo();


        //snackbar responsavel por informar a operação de remoção e possibilida o desfazer a remoção
        final snackBar = SnackBar(
          //Texto que é mostrado ao usuário 
          content: Text("Tarefa removida"),
          //Cor da caixa da informação
          backgroundColor: Colors.green,
          //A ação que ésta disponivel no snackBar
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              setState(() {
                //Retorna o item removido da lista na posição que estava
                _listaTarefa.insert(index, _ultimaTarefaRemovida);
              });
              _salvarArquivo();
            },
          ),
        );

        //Mostra o snackBar no Scaffold
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      //Responsavel por gerenciar o que esta atrás do item
      background: Container(
        //Cor que ele possui
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          //O icone vai estar no lado direito da linha
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            )
          ],
        ),
      ),
      //Widget que cria uma lista de informação com uma CheckBox
      child: CheckboxListTile(
          //O titulo que cada Widget vai ter
          title: Text(_listaTarefa[index]['titulo']),
          //O valor da checkBox
          value: _listaTarefa[index]['realizada'],
          onChanged: (valorAlterado) {
            //Atualizando a checkBoa ao ser pressionada
            setState(() {
              _listaTarefa[index]['realizada'] = valorAlterado;
            });
            _salvarArquivo();
          }),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          //Widget que ocupa todo o espaço que lhê é dado
          Expanded(
            child: ListView.builder(
              itemBuilder: criarItemLista,
              itemCount: _listaTarefa.length,
            ),
          )
        ],
      ),
      //Dizendo que localização o floating action button vai ter
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      //Criando o floating action button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Mostrando um dialog, responsavel por pegar e salvar as informações
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
