import 'package:flutter/material.dart';


void showSnackBar({required BuildContext context, required String text, Color color = Colors.black}) {
  final snackBar = SnackBar(
    content: Text(text),
    backgroundColor: color,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
