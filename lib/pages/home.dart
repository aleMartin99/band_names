import 'dart:developer';

import 'package:band_names/models/band.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '0', name: 'Papa Roach', votes: 1),
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Bon Jovi', votes: 2),
    Band(id: '3', name: 'Linkin Park', votes: 7),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBand,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        elevation: 1,
        title: const Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, i) => _bandTile(bands[i]),
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      onDismissed: (direction) {
        //TODO llamar delete
        log('direction: $direction');
      },
      direction: DismissDirection.startToEnd,
      background: Container(
        color: Colors.red,
        child: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Delete Band',
                style: TextStyle(color: Colors.white),
              )),
        ),
      ),
      key: Key(band.id!),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name!.substring(0, 2)),
        ),
        title: Text(band.name!),
        trailing: Text(
          '${band.votes}',
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () {},
      ),
    );
  }

  _addNewBand() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New band name'),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              onPressed: (() => _addBandToList(textController.text)),
              elevation: 5,
              color: Colors.blue,
              child: const Text('Add'),
            )
          ],
        );
      },
    );
  }

  void _addBandToList(String name) {
    if (name.length > 1) {
      bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
    }
    Navigator.pop(context);
  }

  void _incrementVote(int i) {
    bands[i].votes = (bands[i].votes! + 1);
  }
}
