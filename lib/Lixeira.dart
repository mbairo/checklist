import 'package:flutter/material.dart';

class Lixeira extends StatefulWidget {
  final List listaDeTarefasRemovidas;
  final List listaDeTarefas;
  final Function salvarArquivo;

  Lixeira({
    required this.listaDeTarefasRemovidas,
    required this.listaDeTarefas,
    required this.salvarArquivo,
  });

  @override
  _LixeiraState createState() => _LixeiraState();
}

class _LixeiraState extends State<Lixeira> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lixeira"),
        backgroundColor: const Color.fromARGB(255, 54, 244, 197),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, widget.listaDeTarefas);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: widget.listaDeTarefasRemovidas.length,
        itemBuilder: (context, index) {
          final tarefaNoHistorico = widget.listaDeTarefasRemovidas[index];
          return Dismissible(
            key: Key('${index}_${tarefaNoHistorico['nomeDaTarefa']}'),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              setState(() {
                final tarefaRestaurada = {
                  ...tarefaNoHistorico,
                  'realizada': false
                };

                widget.listaDeTarefas.add(tarefaRestaurada);
                widget.listaDeTarefasRemovidas.removeAt(index);
                widget.salvarArquivo();
              });

              // Aqui você pode adicionar a função de salvar arquivo, se necessário
              // _salvarArquivo();
            },
            background: Container(
              color: Colors.green,
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.restore,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            child: ListTile(
              title: Text(tarefaNoHistorico['nomeDaTarefa']),
            ),
          );
        },
      ),
    );
  }
}
