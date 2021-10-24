import 'package:flutter/material.dart';
import 'package:laptopmonitor/components/control_button.dart';
import 'package:laptopmonitor/components/qr_code_dailogue.dart';
import 'package:laptopmonitor/components/video_feed.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ControlButton(
                  buttonText: "Connect Phone",
                  onTap: () {
                    createAndShowDynamic("Hii", context);
                  }),
              ControlButton(buttonText: "Start Monitoring", onTap: () {}),
              ControlButton(buttonText: "End Monitoring", onTap: () {})
            ],
          ),
          const Divider(
            height: 10,
            color: Colors.amberAccent,
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: MediaQuery.of(context).size.height * .50,
            padding: const EdgeInsets.all(5),
            child: VideoMediaDisplay(),
          )
        ],
      ),
    );
  }
}
