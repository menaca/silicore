import 'package:computer_control/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:computer_control/screens/task_page.dart';
import 'package:computer_control/screens/screenshot_page.dart';
import 'package:computer_control/services/firebase_service.dart';
import 'package:computer_control/screens/settings_page.dart';
import 'package:computer_control/utils/helpers.dart';

class HomePage extends StatefulWidget {
  final String clientId;
   const HomePage({super.key, required this.clientId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _sendCommand(String command, text) async {
    await _firebaseService.sendCommand(widget.clientId, command);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$text: $command")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;

    return StreamBuilder<Map<String, dynamic>?> (
      stream: _firebaseService.streamComputerData(widget.clientId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return  Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data!;
        final cpu = data['cpu'];
        final ram = data['ram'];
        final disk = data['disk'];
        final battery = data['battery'];
        final screen = data['screen'];
        final network = data['network'];

        final lastUploadDate = DateTime.parse(data['timestamp']);

        final String status = data['status'] ?? 'offline';
        final bool isOnline = status == "online";

        final double cpuUsage = (cpu['usage_percent'] ?? 0).toDouble();
        final double ramUsage = (ram['usage_percent'] ?? 0).toDouble();
        final double diskUsage = (disk['used_percent'] ?? 0).toDouble();

        final Color diskColor = diskUsage > 85 ? Colors.redAccent : Colors.greenAccent;
        final Color batteryColor = (battery['percent'] > 30 || battery['plugged']) ? Colors.greenAccent : Colors.redAccent;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title:  Row(
              children: [
                Text(
                  "Sili",
                  style: TextStyle(
                    color: Color(0xffe5e8ca),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  "core",
                  style: TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage())),
                icon:  Icon(Icons.settings, color: Colors.white),
              ),
            ],
          ),
          body: ListView(
            padding:  EdgeInsets.all(16),
            children: [
              Image.asset("assets/icons/computer.png", height: 120, color: Colors.white70,),
              Center(
                child: Text(
                  data['computer_name'] ?? t("device"),
                  style:  TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isOnline ? Icons.circle : Icons.circle_outlined, color: isOnline ? Colors.green : Colors.grey, size: 14),
                  SizedBox(width: 5),
                  Text(isOnline ? t("online") : t("offline"), style: TextStyle(color: isOnline ? Colors.green : Colors.grey, fontSize: 15)),

                  Text(" · "),

                  battery['plugged'] ? Image.asset("assets/icons/battery_charging.png", color: Colors.greenAccent, height: 20) : Image.asset("assets/icons/battery.png", color: batteryColor, height: 20),
                   SizedBox(width: 8),
                  Text("${battery['percent']}%", style: TextStyle(color: batteryColor, fontWeight: FontWeight.bold)),
                   SizedBox(width: 8),

                ],
              ),
              SizedBox(height: 20),

              _silentInfoText("${t("last_update")}: ${formatReadableDate(lastUploadDate)}"),

              SizedBox(height: 20),

              if (data['os'].toString().isNotEmpty) _infoText("assets/icons/os.png",data['os']),
              _infoText("assets/icons/processor.png","${cpu['brand'] ?? '-'}"),
              _infoText("assets/icons/ram.png","${ram['total_gb'] ?? '-'} GB Ram · ${disk['total_gb'] ?? '-'} GB ${t("memory")}"),
              _infoText("assets/icons/screen.png","${screen['resolution'] ?? '-'}"),
              SizedBox(height: 12),


              Row(
                children: [
                  Expanded(child: _circularIndicator("CPU", cpuUsage, subText: "", suffix: "%")),
                   SizedBox(width: 12),
                  Expanded(child: _circularIndicator("RAM", ramUsage, subText: "${ram['used_gb']} / ${ram['total_gb']} GB")),
                ],
              ),
               SizedBox(height: 20),

              _diskCard(t("disk_usage"),diskUsage, disk['used_gb'], disk['total_gb'], diskColor),
               SizedBox(height: 20),

              _infoText("assets/icons/network.png","${t("network_ip")}: ${network['ip']}"),
              _infoText("assets/icons/mac.png","${t("mac_address")}: ${network['mac']}"),

              SizedBox(height: 24),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _softIconButton(
                    imagePath: "assets/icons/screenshot_view.png",
                    label: t("last_screenshot"),
                    onTap: data['screenshot_base64'] != null
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScreenshotPage(
                            base64Image: data['screenshot_base64'],
                            takenAt: data['screenshot_taken_at'],
                            clientId: widget.clientId,
                          ),
                        ),
                      );
                    }
                        : null,
                  ),
                  _softIconButton(
                    imagePath: "assets/icons/screenshot_take.png",
                    label: t("take_screenshot"),
                    onTap: () => _sendCommand(t("take_screenshot"), t("command_sent")),
                  ),
                  _softIconButton(
                    imagePath: "assets/icons/tasks.png",
                    label: t("task_list"),
                    onTap: () => _showTaskListBottomSheet(widget.clientId),
                  ),
                  _softIconButton(
                    imagePath: "assets/icons/shutdown.png",
                    label: t("shutdown"),
                    onTap: () => _sendCommand(t("shutdown"),t("command_sent")),
                    color: Colors.redAccent,
                  ),
                ],
              ),

              SizedBox(height: 24),

            ],
          ),
        );
      },
    );
  }

  Widget _infoText (String assetPath,String text) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(assetPath, height: 18, color: Colors.white,),
          SizedBox(width: 10),
          Text(text, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _silentInfoText (String text) {
    return Center(
      child: Text(text, style: TextStyle(color: Colors.white38, fontSize: 14)),
    );
  }

  Widget _circularIndicator(String title, double value, {String? subText, String suffix = "%"}) {
    return Container(
      padding:  EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style:  TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 90,
                width: 90,
                child: CircularProgressIndicator(
                  value: value / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                ),
              ),
              Text("${value.toStringAsFixed(0)}$suffix", style:  TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          if (subText != null) ...[
            SizedBox(height: 6),
            Text(subText, style: TextStyle(color: Colors.white60, fontSize: 12)),
          ]
        ],
      ),
    );
  }

  Widget _diskCard(String title, double usage, dynamic used, dynamic total, Color color) {
    return Container(
      padding:  EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset("assets/icons/disk.png", height: 18, color: Colors.white,),
              SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
              Spacer(),
              Text("${usage.toStringAsFixed(0)}%", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
           SizedBox(height: 12),
          LinearProgressIndicator(
            value: usage / 100,
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
           SizedBox(height: 8),
          Text("${used} GB / ${total} GB", style:  TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _softIconButton({required String imagePath,required String label,VoidCallback? onTap,Color? color}) {
    final isDisabled = onTap == null;
    final effectiveColor = color ?? Colors.cyanAccent.withOpacity(isDisabled ? 0.4 : 1);

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 24,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: effectiveColor, width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: isDisabled ? 0.4 : 1,
              child: Image.asset(imagePath, height: 40, color: effectiveColor),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: effectiveColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskListBottomSheet(String clientId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskListSheet(clientId: clientId),
    );
  }
}
