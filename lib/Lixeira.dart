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
      body: ListView.builder(
        itemCount: widget.listaDeTarefasRemovidas.length,
        itemBuilder: (context, index) {
          final tarefaNoHistorico = widget.listaDeTarefasRemovidas[index];

          return Dismissible(
            key: Key('${index}_${tarefaNoHistorico['nomeDaTarefa']}'),
            direction: DismissDirection.horizontal,
            onDismissed: (direction) {
              setState(() {
                if (direction == DismissDirection.startToEnd) {
                  setState(() {
                    widget.listaDeTarefasRemovidas.removeAt(index);
                    widget.salvarArquivo();
                  });
                } else if (direction == DismissDirection.endToStart) {
                  setState(() {
                    final tarefaRestaurada = {
                      ...tarefaNoHistorico,
                      'realizada': false
                    };
                    widget.listaDeTarefas.add(tarefaRestaurada);
                    widget.listaDeTarefasRemovidas.removeAt(index);
                    widget.salvarArquivo();
                  });
                }
              });
            },
            background: Container(
              color: Colors.red,
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            secondaryBackground: Container(
              color: Colors.green,
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.restore,
                    color: Colors.white,
                  )
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
