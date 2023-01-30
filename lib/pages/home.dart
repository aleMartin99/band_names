import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active-bands', _handeActiveBand);

    super.initState();
  }

  _handeActiveBand(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _addNewBand,
          elevation: 1,
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: socketService.serverStatus == ServerStatus.online
                  ? Icon(
                      Icons.check_circle_outline_outlined,
                      color: Colors.blue[300],
                    )
                  : const Icon(Icons.error_outline_rounded, color: Colors.red),
            )
          ],
          elevation: 1,
          title: const Text(
            'BandNames',
            style: TextStyle(color: Colors.black87),
          ),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            _showGraph(),
            Expanded(
              child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, i) => _bandTile(bands[i]),
              ),
            ),
          ],
        ));
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      onDismissed: (_) =>
          socketService.socket.emit('delete-band', {'id': band.id}),
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
          onTap: () => socketService.socket.emit('vote-band', {'id': band.id})),
    );
  }

  _addNewBand() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
      ),
    );
  }

  void _addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      socketService.socket.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = {};
    bands.forEach(
      (band) {
        dataMap.putIfAbsent(band.name!, () => band.votes!.toDouble());
      },
    );
    return SizedBox(height: 200, child: PieChart(dataMap: dataMap));
  }
}
