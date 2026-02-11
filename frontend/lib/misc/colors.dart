import 'package:flutter/material.dart';

const Color softRed = Color.fromARGB(255, 248, 66, 66);

/// palette
const Color primaryColor = Color(0xFF394053);
const Color accentColor = Color(0xFF4E4A59);
const Color accentColor2 = Color(0xFF6E6362);
const Color clickableColor = Colors.indigo;
const Color lightGrey = Color.fromARGB(255, 145, 145, 145);
const Color darkGrey = Color.fromARGB(255, 110, 110, 110);
const Color statsBGCol = Color.fromARGB(255, 237, 227, 233);
const Color statsPrimaryColor = primaryColor;
const Color statsAccent = Color.fromARGB(255, 216, 30, 91);

Color statusColor(String? status) {
  switch (status) {
    case 'not_settled':
      return const Color.fromARGB(255, 0, 0, 0);
    case 'partially_settled':
      return Colors.orange;
    case 'settled':
      return const Color.fromARGB(255, 115, 172, 117);
    default:
      return Colors.grey;
  }
}
