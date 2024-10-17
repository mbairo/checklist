import 'dart:io';
import 'package:checklist/Lixeira.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _controllerTextoDigitado = TextEditingController();
  List _listaDeTarefas = [];
  List _listaDeTarefasRemovidas = [];
  Map<String, dynamic>? _mapUltimaTarefaRemovida;
  int? _ultimoIndexRemovido;
  int _paginaAtual = 0;

  Future<File> _getFile() async {
    final diretorio = await getApplicationCacheDirectory();
    return File("${diretorio.path}/dadosDaLista.json");
  }

  _salvarTarefa() {
    String textoDigitado = _controllerTextoDigitado.text;

    Map<String, dynamic> tarefa = {
      "nomeDaTarefa": textoDigitado,
      "realizada": false,
    };

    setState(() {
      _listaDeTarefas.add(tarefa);
    });
    _salvarArquivo();
    _controllerTextoDigitado.text = "";
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();
    Map<String, dynamic> dados = {
      'tarefas': _listaDeTarefas,
      'tarefasRemovidas': _listaDeTarefasRemovidas,
    };
    String dadosDaLista = json.encode(dados);
    await arquivo.writeAsString(dadosDaLista);
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      final dados = await arquivo.readAsString();
      Map<String, dynamic> dadosDecodificados = json.decode(dados);
      setState(() {
        _listaDeTarefas = dadosDecodificados['tarefas'] ?? [];
        _listaDeTarefasRemovidas = dadosDecodificados['tarefasRemovidas'] ?? [];
      });
    } catch (e) {
      setState(() {
        _listaDeTarefas = [];
        _listaDeTarefasRemovidas = [];
      });
    }
  }

  void _adicionarTarefaRemovida(Map<String, dynamic> tarefaRemovida) {
    setState(() {
      _listaDeTarefasRemovidas.add(tarefaRemovida);
    });
  }

  @override
  void initState() {
    super.initState();
    _lerArquivo();
  }

  Widget criarItemDaLista(context, index) {
    return Dismissible(
      key: Key(_listaDeTarefas[index]['nomeDaTarefa']),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        setState(() {
          _mapUltimaTarefaRemovida = _listaDeTarefas[index];
          _ultimoIndexRemovido = index;
          _listaDeTarefas.removeAt(index);
          _adicionarTarefaRemovida(_mapUltimaTarefaRemovida!);
          _salvarArquivo();
        });

        final snackBar = SnackBar(
          duration: const Duration(seconds: 3),
          content: const Text("Tarefa removida!!!"),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              setState(() {
                if (_mapUltimaTarefaRemovida != null &&
                    _ultimoIndexRemovido != null) {
                  _listaDeTarefas.insert(
                      _ultimoIndexRemovido!, _mapUltimaTarefaRemovida!);
                  _listaDeTarefasRemovidas.remove(_mapUltimaTarefaRemovida);
                  _salvarArquivo();
                }
              });
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.all(16),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ],
        ),
      ),
      child: ListTile(
        title: Text(_listaDeTarefas[index]['nomeDaTarefa']),
        leading: const Icon(Icons.drag_handle),
        trailing: Checkbox(
          value: _listaDeTarefas[index]['realizada'],
          onChanged: (valorAlterado) {
            setState(() {
              _listaDeTarefas[index]['realizada'] = valorAlterado;
            });
            _salvarArquivo();
          },
        ),
      ),
    );
  }

  void _mudarPagina(int index) {
    setState(() {
      _paginaAtual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 54, 244, 197),
        title: Text(_paginaAtual == 0 ? "Checklist" : "Lixeira"),
      ),

      body: _paginaAtual == 0
          ? ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _listaDeTarefas.removeAt(oldIndex);
                  _listaDeTarefas.insert(newIndex, item);
                  _salvarArquivo();
                });
              },
              children: List.generate(_listaDeTarefas.length, (index) {
                return criarItemDaLista(context, index);
              }),
            )
          : Lixeira(
              listaDeTarefasRemovidas: _listaDeTarefasRemovidas,
              listaDeTarefas: _listaDeTarefas,
              salvarArquivo: _salvarArquivo,
            ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: _paginaAtual == 0
          ? FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 54, 244, 197),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Center(
                        child: Text("Adicionar nova tarefa"),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration:
                                InputDecoration(labelText: "Digite sua tarefa"),
                            controller: _controllerTextoDigitado,
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                child: Text("Cancelar"),
                                onPressed: () => Navigator.pop(context),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                child: Text("Salvar"),
                                onPressed: () {
                                  _salvarTarefa();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: const Icon(
                Icons.add,
                color: Colors.black,
              ),
            )
          : FloatingActionButton(
              backgroundColor: Color(0xFFD32F2F),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Center(child: Text("Excluir Histórico?")),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                child: Text("Sim"),
                                onPressed: () {
                                  setState(() {
                                    _listaDeTarefasRemovidas.clear();
                                    _salvarTarefa();
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                child: Text("Cancelar"),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              },
              child: const Icon(
                Icons.delete_forever,
                color: Color(0xFFFFCDD2),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        onTap: _mudarPagina,
        selectedItemColor: Color.fromARGB(255, 14, 187, 144),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete_forever),
            label: 'Lixeira',
          ),
        ],
      ),
    );
  }
}
