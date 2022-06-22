import 'package:flutter/material.dart';
import 'package:lapnitor_mobile/controllers/EventStreamController.dart';
import "package:lapnitor_mobile/models/Event.dart";
import 'package:lapnitor_mobile/pages/switcher.dart';
import 'package:lapnitor_mobile/services/databaseService.dart';
import 'package:lapnitor_mobile/services/storageService.dart';
import 'package:provider/provider.dart';

import '../components/FeedCard.dart';

class FeedPage extends StatefulWidget {
  final void Function(Pages) onSwitchPage;
  const FeedPage({Key? key, required this.onSwitchPage}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late DatabaseService dbService;
  late StorageService storageService;
  late Stream<List<Event>>? feed;
  late List<Event> currentEvents;
  bool isConnected = false;
  bool newData = false;
  EventStreamController? eventStreamController;
  // List<Event> temps = List.generate(
  //     5,
  //     (index) => Event("Human is too close", "https://i.dailymail.co.uk/i/pix/2011/06/01/article-1393117-0C5BFD5800000578-215_472x350.jpg",
  //         Timestamp.now(), 455));

  @override
  void initState() {
    storageService = StorageService();
    dbService = context.read<DatabaseService>();
    feed = dbService.getFeedStream();
    currentEvents = [];
    super.initState();
  }

  void assignFeed() {
    if (eventStreamController == null) {
      feed = dbService.getFeedStream();
      eventStreamController = EventStreamController(feed!);
      eventStreamController!.addListener(() {
        setState(() {
          newData = eventStreamController!.newData;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    isConnected = dbService.id != null;
    assignFeed();
    print("streControllor" + eventStreamController.toString());
    return Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          children: [
            if (newData)
              Expanded(
                flex: 1,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      currentEvents = eventStreamController!.getUpdatedList();
                      newData = false;
                    });
                  },
                  child: const Text("Click for new Info"),
                ),
              ),
            isConnected
                ? Builder(
                    builder: (BuildContext context) {
                      List<Event> events = eventStreamController?.getUpdatedList().reversed.toList() ?? [];
                      print("Data is: ${events.length} long");
                      if (events.isNotEmpty) {
                        return Expanded(
                          flex: 3,
                          child: ListView.builder(
                              itemBuilder: (context, index) {
                                return events[index].evidenceUrl != null
                                    ? FutureBuilder<String>(
                                        future: storageService.getDownloadUrlFromRelativePath(events[index].evidenceUrl!),
                                        builder: (BuildContext context, AsyncSnapshot<dynamic> link) {
                                          if (link.hasData) {
                                            events[index].evidenceUrl = link.data;
                                            // return Center(
                                            //     key: ValueKey<int>(link.hashCode),
                                            //     child: const CircularProgressIndicator(
                                            //       color: Colors.black,
                                            //     ));
                                          }
                                          // print("link is ${link.data}");

                                          return FeedCard(key: ValueKey<int>(link.hashCode), event: events[index]);
                                        },
                                      )
                                    : FeedCard(key: ValueKey<int>(events[index].hashCode), event: events[index]);
                              },
                              itemCount: 4),
                        );
                      }
                      return const Center(
                        child: Text(
                          "No data yet",
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    },
                  )
                : Center(
                    child: OutlinedButton(
                    child: const Text("Connect to a laptop first"),
                    onPressed: () => widget.onSwitchPage(Pages.scanPage),
                  )),
          ],
        ));
  }
}
