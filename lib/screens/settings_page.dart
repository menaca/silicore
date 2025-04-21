  import 'package:computer_control/main.dart';
  import 'package:flutter/material.dart';
  import 'package:computer_control/services/firebase_service.dart';
  import 'package:computer_control/utils/prefs.dart';
  import 'package:computer_control/utils/helpers.dart';
  import '../localization/app_localizations.dart';
  import 'dart:async';

  class SettingsPage extends StatefulWidget {
    SettingsPage({super.key});

    @override
    State<SettingsPage> createState() => _SettingsPageState();
  }

  class _SettingsPageState extends State<SettingsPage> {
    DateTime? connectedAt;
    Locale? currentLocale;
    Timer? _timer;

    void _changeLanguage(String languageCode) async {
      await Prefs.saveLanguageCode(languageCode);
      Locale newLocale = Locale(languageCode);
      MyApp.of(context)?.setLocale(newLocale);
      setState(() {
        currentLocale = newLocale;
      });
    }

    void _getLanguageCode() async {
      final code = await Prefs.getLanguageCode();
      setState(() {
        currentLocale = Locale(code ?? 'tr');
      });
    }

    @override
    void initState() {
      super.initState();
      _getLanguageCode();
      _loadConnectionTime();
      _startTimer();
    }

    void _startTimer() {
      _timer = Timer.periodic(Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {});
        }
      });
    }

    Future<void> _loadConnectionTime() async {
      final clientId = await Prefs.getClientId();
      if (clientId == null) return;

      final DateTime? timestamp = await FirebaseService().getConnectedAt(clientId);
      if (timestamp != null) {
        setState(() {
          connectedAt = timestamp;
        });
      }
    }

    @override
    void dispose() {
      _timer?.cancel();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final t = AppLocalizations.of(context).translate;
      final connectedDuration = connectedAt != null
          ? DateTime.now().difference(connectedAt!)
          : Duration.zero;

      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
          elevation: 0,
          title: Text(
            t('settings'),
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  t('connection_duration'),
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: connectedAt == null
                    ? Text(t('loading'), style: TextStyle(color: Colors.grey[400]))
                    : Text(formatDuration(connectedDuration),
                    style: TextStyle(color: Colors.grey[300])),
                leading: Icon(Icons.timer, color: Colors.grey[400]),
              ),
              ListTile(
                title: Text(
                  t('language'),
                  style: TextStyle(color: Colors.white),
                ),
                leading: Icon(Icons.language, color: Colors.grey[400]),
                trailing: currentLocale == null
                    ? CircularProgressIndicator()
                    : DropdownButton<String>(
                  dropdownColor: Colors.grey[900],
                  style: TextStyle(color: Colors.white),
                  value: currentLocale!.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      _changeLanguage(value);
                    }
                  },
                  items: [
                    DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                ),
              ),
              ListTile(
                title: Text(
                  t('disconnect'),
                  style: TextStyle(color: Colors.redAccent),
                ),
                leading: Icon(Icons.logout, color: Colors.redAccent),
                onTap: () => disconnectClient(context),
              ),
            ],
          ),
        ),
      );
    }
  }
