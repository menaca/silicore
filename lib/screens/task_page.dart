import 'package:computer_control/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:computer_control/services/firebase_service.dart';

class TaskListSheet extends StatefulWidget {
  final String clientId;
  TaskListSheet({super.key, required this.clientId});

  @override
  State<TaskListSheet> createState() => _TaskListSheetState();
}

class _TaskListSheetState extends State<TaskListSheet> {
  final FirebaseService _firebaseService = FirebaseService();

  List<dynamic> _processList = [];
  List<dynamic> _filteredList = [];
  Set<int> _selectedPIDs = {};
  bool _loading = true;

  final TextEditingController _searchController = TextEditingController();
  String _sortCriteria = "none"; // 'cpu', 'memory', 'none'

  @override
  void initState() {
    super.initState();
    _sendCommandAndListen();

    _searchController.addListener(() {
      _applyFilters();
    });
  }

  void _sendCommandAndListen() async {
    await _firebaseService.sendCommand(widget.clientId, "update_tasklist");

    _firebaseService.firestore
        .collection("computers")
        .doc(widget.clientId)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.data();
      if (data != null && data['process_list'] != null) {
        setState(() {
          _processList = List<Map<String, dynamic>>.from(data['process_list']);
          _applyFilters();
          _loading = false;
        });
      }
    });
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();

    List<Map<String, dynamic>> tempList = List<Map<String, dynamic>>.from(_processList);
    if (_sortCriteria == "cpu") {
      tempList.sort((a, b) => (b['cpu'] as num).compareTo(a['cpu']));
    } else if (_sortCriteria == "memory") {
      tempList.sort((a, b) => (b['memory'] as num).compareTo(a['memory']));
    }

    setState(() {
      _filteredList = tempList
          .where((p) => p['name'].toString().toLowerCase().contains(query))
          .toList();
    });
  }

  void _killSelectedProcesses(String title) async {
    await _firebaseService.killSelectedProcesses(widget.clientId, _selectedPIDs.toList());
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: _loading
              ? Center(
            child: Text(
              t("please_wait"),
              style: TextStyle(color: Colors.white),
            ),
          )
              : Column(
            children: [
              Row(
                children: [
                  Text(
                    t("task_list"),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.filter_list, color: Colors.white),
                    onSelected: (value) {
                      setState(() {
                        _sortCriteria = value;
                        _applyFilters();
                      });
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'none',
                        child: Row(
                          children: [
                            if (_sortCriteria == 'none') Icon(Icons.check, size: 16),
                            SizedBox(width: 5),
                            Text(t("no_sort")),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'cpu',
                        child: Row(
                          children: [
                            if (_sortCriteria == 'cpu') Icon(Icons.check, size: 16),
                            SizedBox(width: 5),
                            Text(t("cpu_sort")),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'memory',
                        child: Row(
                          children: [
                            if (_sortCriteria == 'memory') Icon(Icons.check, size: 16),
                            SizedBox(width: 5),
                            Text(t("memory_sort")),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: t("search_hint"),
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filteredList.length,
                  itemBuilder: (context, index) {
                    final process = _filteredList[index];
                    final pid = process['pid'];
                    final name = process['name'];
                    return CheckboxListTile(
                      activeColor: Colors.deepPurple,
                      checkColor: Colors.white,
                      value: _selectedPIDs.contains(pid),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedPIDs.add(pid);
                          } else {
                            _selectedPIDs.remove(pid);
                          }
                        });
                      },
                      title: Text(name, style: TextStyle(color: Colors.white)),
                      subtitle: Text(
                        "PID: $pid - CPU: ${process['cpu']}% - RAM: ${process['memory'].toStringAsFixed(2)}%",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: _selectedPIDs.isEmpty ? null : () => _killSelectedProcesses(t("task_sent")),
                child: Text(t("kill_selected_processes"), style: TextStyle(color: Colors.white),),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
