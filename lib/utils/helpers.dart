import 'package:computer_control/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:computer_control/screens/enter_code_page.dart';
import 'package:computer_control/utils/prefs.dart';

Future<void> disconnectClient(BuildContext context) async {
  final clientId = await Prefs.getClientId();
  if (clientId != null) {
    await FirebaseService().disconnectClientFromFirebase(clientId);
  }

  await Prefs.clearClientId();

  if (context.mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => EnterCodePage()),
          (route) => false,
    );
  }
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return '$hours:$minutes:$seconds';
}

String formatReadableDate(DateTime dateTime) {
  final days = [
    'Paz', 'Pzt', 'Salı', 'Çar', 'Per', 'Cum', 'Cmt'
  ];
  final months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  final dayName = days[dateTime.weekday % 7];
  final monthName = months[dateTime.month - 1];
  final day = dateTime.day;
  final hour = twoDigits(dateTime.hour);
  final minute = twoDigits(dateTime.minute);
  final second = twoDigits(dateTime.second);

  return '$day $monthName $dayName, $hour:$minute:$second';
}


