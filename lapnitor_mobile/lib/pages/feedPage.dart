import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import "package:lapnitor_mobile/models/event.dart";
import 'package:lapnitor_mobile/pages/switcher.dart';
import 'package:lapnitor_mobile/services/databaseService.dart';
import 'package:lapnitor_mobile/services/storageService.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatefulWidget {
  final void Function(Pages) onSwitchPage;
  const FeedPage({Key? key, required this.onSwitchPage}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late DatabaseService dbService;
  late StorageService storageService;
  bool isConnected = false;
  late Stream<List<Event>>? feed;
  List<Event> temps = List.generate(
      5,
      (index) => Event("Human is too close", "https://i.dailymail.co.uk/i/pix/2011/06/01/article-1393117-0C5BFD5800000578-215_472x350.jpg",
          Timestamp.now(), 455));

  @override
  void initState() {
    storageService = StorageService();
    dbService = context.read<DatabaseService>();
    feed = dbService.getFeedStream();
    print("dbService $dbService");
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    isConnected = dbService.id != null;
    feed ??= dbService.getFeedStream();

    print("feed ${feed?.first.toString()}");
    return Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: isConnected
            ? StreamBuilder(
                stream: feed,
                builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
                  print("Data is: ${snapshot.data}");
                  if (snapshot.hasData && snapshot.data != null) {
                    List<Event>? data = snapshot.data!.reversed.toList();

                    return ListView.builder(
                        itemBuilder: (context, index) {
                          return data![index].evidenceUrl != null
                              ? FutureBuilder<String>(
                                  future: storageService.getDownloadUrlFromRelativePath(data[index].evidenceUrl!),
                                  builder: (BuildContext context, AsyncSnapshot<dynamic> link) {
                                    if (link.hasData == false) {
                                      return const Center(
                                          child: CircularProgressIndicator(
                                        color: Colors.black,
                                      ));
                                    }
                                    data[index].evidenceUrl = link.data;
                                    return FeedCard(event: data[index]);
                                  },
                                )
                              : FeedCard(event: data[index]);
                        },
                        itemCount: data?.length ?? 0);
                  }
                  return Center(
                    child: Text(
                      snapshot.hasError ? "Error loading data, try again later" : "No data yet",
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                },
              )
            : Center(
                child: OutlinedButton(
                child: const Text("Connect to a laptop first"),
                onPressed: () => widget.onSwitchPage(Pages.scanPage),
              )));
  }
}

class FeedCard extends StatelessWidget {
  FeedCard({Key? key, required this.event}) : super(key: key);
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Row(
            children: [const Text("Activity:"), Text(event.activity)],
          ),
          event.evidenceUrl != null ? Image.network(event.evidenceUrl!) : Text("No image sent"),
          Row(
            children: [const Text("Time: "), Text(DateTime.now().toString())],
          ),
        ],
      ),
    );
  }
}
