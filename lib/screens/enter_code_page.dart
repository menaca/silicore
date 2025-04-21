import 'package:computer_control/localization/app_localizations.dart';
import 'package:computer_control/screens/home_page.dart';
import 'package:computer_control/services/firebase_service.dart';
import 'package:computer_control/utils/prefs.dart';
import 'package:flutter/material.dart';
import 'package:computer_control/main.dart';

class EnterCodePage extends StatefulWidget {
  const EnterCodePage({super.key});

  @override
  State<EnterCodePage> createState() => _EnterCodePageState();
}

class _EnterCodePageState extends State<EnterCodePage> with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  bool _loading = false;
  String? _error;
  bool _showWelcome = true;
  Locale? _currentLocale;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _getLanguageCode();
    _checkIfAlreadyConnected();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  void _getLanguageCode() async {
    final code = await Prefs.getLanguageCode();
    setState(() {
      _currentLocale = Locale(code ?? 'tr');
    });
  }

  void _changeLanguage(String languageCode) async {
    await Prefs.saveLanguageCode(languageCode);
    Locale newLocale = Locale(languageCode);
    MyApp.of(context)?.setLocale(newLocale);
    setState(() {
      _currentLocale = newLocale;
    });
  }

  Future<void> _checkIfAlreadyConnected() async {
    final clientId = await Prefs.getClientId();
    if (clientId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(clientId: clientId)),
      );
    }
  }

  Future<void> _connectWithCode() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final code = _codeController.text.trim().toUpperCase();
    final clientId = await _firebaseService.getClientIdFromCode(code);
    final success = await _firebaseService.checkCode(code);

    if (clientId != null && success) {
      await Prefs.saveClientId(clientId);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(clientId: clientId)),
      );
    } else {
      setState(() => _error = "error_text");
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
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
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: Offset(1, 0),
                    end: Offset(0, 0),
                  ).animate(animation);
                  return SlideTransition(position: offsetAnimation, child: child);
                },
                child: _showWelcome
                    ? _buildWelcomeScreen(t("welcome_text"), t("continue_with_code"))
                    : _buildCodeEntryScreen(
                  t("enter_code_prompt"),
                  t("enter_code"),
                  t("connect"),
                  t("back"),
                  t("error_text")
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                t("info_text"),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ),
            SizedBox(height: 20),
            if (_currentLocale != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.language, color: Colors.white70),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    dropdownColor: Colors.grey[900],
                    style: TextStyle(color: Colors.white),
                    value: _currentLocale!.languageCode,
                    onChanged: (value) {
                      if (value != null) _changeLanguage(value);
                    },
                    items: [
                      DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                  ),
                ],
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(String welcomeText, String continueWithCode) {
    return Column(
      key: ValueKey("welcome"),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/logo_transparent.png", height: 150),
        SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            welcomeText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _showWelcome = false;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan,
            padding: EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(continueWithCode, style: TextStyle(color: Colors.black, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildCodeEntryScreen(String prompt, String hintText, String connect, String back, String error) {
    return Column(
      key: ValueKey("code_entry"),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/enter_code.png", height: 150),
        SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              Text(
                prompt,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.cyan),
                  ),
                ),
              ),
              if (_error != null) ...[
                SizedBox(height: 12),
                Text(error, style: TextStyle(color: Colors.redAccent)),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _connectWithCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  padding: EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                    : Text(connect, style: TextStyle(color: Colors.black, fontSize: 16)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showWelcome = true;
                    _error = null;
                    _codeController.clear();
                  });
                },
                child: Text(back, style: TextStyle(color: Colors.white70)),
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}