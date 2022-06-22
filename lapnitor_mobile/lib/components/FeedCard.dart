import 'package:flutter/material.dart';
import 'package:lapnitor_mobile/models/Event.dart';

class FeedCard extends StatelessWidget {
  FeedCard({Key? key, required this.event}) : super(key: key);
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        color: Colors.grey.shade50,
        padding: const EdgeInsets.all(2),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  "Activity: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                  event.activity + " " + event.distanceFromCamera!.floor().toString() + "m from camera",
                  softWrap: true,
                )
              ],
            ),
            event.evidenceUrl != null
                ? event.evidenceUrl!.contains("://")
                    ? Image.network(
                        event.evidenceUrl!,
                        errorBuilder: (context, object, trace) {
                          return const Text("Error loading image");
                        },
                      )
                    : const LinearProgressIndicator()
                : const Text("No image sent"),
            Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "@" + event.time.toDate().toString(),
                  style: const TextStyle(fontSize: 20),
                )),
          ],
        ),
      ),
    );
  }
}
