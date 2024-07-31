import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _listaTarefas = [];
  Map<String, dynamic> _ultimaTarefaRemovida = {};
  final TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File( "${diretorio.path}/dados.json" );

  }

  _salvarTarefa(){
    String textoDigitado = _controllerTarefa.text;

    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;

    setState(() {
      _listaTarefas.add( tarefa );
    });
    _salvarArquivo();

    _controllerTarefa.text = "";
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();

    String dados = json.encode( _listaTarefas );
    arquivo.writeAsString( dados );
  }

  _lerArquivo() async {
    try{
      final arquivo = await _getFile();
      return arquivo.readAsString();
    }catch(e){
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    _lerArquivo().then( (dados){
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    } );
  }

  Widget criarItemLista(context, index){
    return Dismissible(
        key: Key( DateTime.now().millisecondsSinceEpoch.toString() ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction){

          //recuperar último item excluído
          _ultimaTarefaRemovida = _listaTarefas[index];

          //Remove item da lista
          _listaTarefas.removeAt(index);
          _salvarArquivo();

          final snackbar = SnackBar(
            duration: const Duration(seconds: 5),
            content: const Text("Tarefa removida!!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: (){
                  //Insere novamente item removido na lista
                  setState(() {
                    _listaTarefas.insert(index, _ultimaTarefaRemovida);
                  });
                  _salvarArquivo();
                }
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        },
        background: Container(
          color: Colors.red,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const <Widget>[
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(
          title: Text( _listaTarefas[index]['titulo'] ),
          value: _listaTarefas[index]['realizada'],
          onChanged: (valorAlterado){
            setState(() {
              _listaTarefas[index]['realizada'] = valorAlterado;
            });

            _salvarArquivo();
          },
        )
    );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de tarefas"),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.purple,
          onPressed: (){
            showDialog(
                context: context,
                builder: (context){
                  return AlertDialog(
                    title: const Text("Adicionar Tarefa"),
                    content: TextField(
                      controller: _controllerTarefa,
                      decoration: const InputDecoration(
                          labelText: "Digite sua tarefa"
                      ),
                      onChanged: (text){},
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("Cancelar"),
                        onPressed: () => Navigator.pop(context) ,
                      ),
                      TextButton(
                        child: const Text("Salvar"),
                        onPressed: (){
                          //salvar
                          _salvarTarefa();
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );

                }
            );

          },
          child: const Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: _listaTarefas.length,
                itemBuilder: criarItemLista
            ),
          )
        ],
      ),
    );
  }
}