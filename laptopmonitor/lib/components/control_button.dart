import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  const ControlButton({Key? key, required this.buttonText, required this.onTap}) : super(key: key);
  final String buttonText;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: OutlinedButton(
        child: Text(buttonText),
        onPressed: () => onTap(),
      ),
    );
  }
}
