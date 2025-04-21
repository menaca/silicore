import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:computer_control/localization/app_localizations.dart';
import 'package:computer_control/services/firebase_service.dart';
import 'package:computer_control/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ScreenshotPage extends StatefulWidget {
  final String base64Image;
  final String takenAt;
  final String clientId;

  const ScreenshotPage({
    Key? key,
    required this.base64Image,
    required this.takenAt,
    required this.clientId,
  }) : super(key: key);

  @override
  State<ScreenshotPage> createState() => _ScreenshotPageState();
}

class _ScreenshotPageState extends State<ScreenshotPage> {
  late Uint8List imageBytes;
  bool isSaving = false;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    imageBytes = base64Decode(widget.base64Image);
  }

  Future<void> _deleteScreenshot(String success, error) async {
    try {
      await _firebaseService.deleteScreenshot(widget.clientId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success),
          backgroundColor: Colors.green[600],
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Text(
              "Sili",
              style: TextStyle(
                color: Color(0xffe5e8ca),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              "core",
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async{await _deleteScreenshot(t("success_delete_photo"), t("error_delete_photo"));  },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PhotoView(
              imageProvider: MemoryImage(imageBytes),
              backgroundDecoration: BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              formatReadableDate(DateTime.parse(widget.takenAt)),
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
