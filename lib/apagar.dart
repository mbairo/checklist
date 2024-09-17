import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 97, 136, 126),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Ação ao pressionar o ícone
                  },
                ),
              ),
            ),
            const Text(
              'Checklist',
              style: TextStyle(fontSize: 20), // Ajuste o tamanho da fonte se necessário
            ),
          ],
        ),
        // centerTitle: true, // Removido, pois o alinhamento é feito manualmente
      ),
      body: Center(
        child: Text('Conteúdo da página'),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: Home()));

