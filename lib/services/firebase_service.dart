import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;


  Future<bool> checkCode(String code) async {
    final snapshot = await _firestore
        .collection('computers')
        .where('connection_code', isEqualTo: code)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      await doc.reference.update({'connectedStatus': 'connected', 'connected_at':DateTime.now().toString()});
      return true;
    }
    return false;
  }

  Future<String?> getClientIdFromCode(String code) async {
    final snapshot = await _firestore
        .collection('computers')
        .where('connection_code', isEqualTo: code)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getComputerData(String clientId) async {
    final doc = await _firestore.collection('computers').doc(clientId).get();
    if (doc.exists) return doc.data();
    return null;
  }

  Stream<Map<String, dynamic>?> streamComputerData(String clientId) {
    return _firestore.collection('computers').doc(clientId).snapshots().map(
          (snapshot) {
        if (snapshot.exists) {
          return snapshot.data();
        }
        return null;
      },
    );
  }


  Future<Map<String, dynamic>?> deleteScreenshot(String clientId) async {
      final docRef = FirebaseFirestore.instance.collection('computers').doc(clientId);
      await docRef.update({
        'screenshot_base64': FieldValue.delete(),
        'screenshot_taken_at': FieldValue.delete(),
      });
  }

  Future<void> disconnectClientFromFirebase(String clientId) async {
    await _firestore.collection('computers').doc(clientId).update({
      'connectedStatus': 'disconnected',
    });
  }

  Future<void> sendCommand(String clientId, String command) async {
    await _firestore.collection('computers').doc(clientId).update({
      'command': command,
    });
  }

  Future<DateTime?> getConnectedAt(String clientId) async {
    final doc = await _firestore.collection('computers').doc(clientId).get();
    if (doc.exists && doc.data()!.containsKey('connected_at')) {
      final raw = doc['connected_at'];
      if (raw is Timestamp) {
        return raw.toDate();
      } else if (raw is String) {
        try {
          return DateTime.parse(raw);
        } catch (e) {
          print('Tarih parse edilemedi: $e');
        }
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> getTaskList(String clientId) async {
    final doc = await _firestore.collection('computers').doc(clientId).get();
    if (doc.exists && doc.data()!.containsKey('process_list')) {
      final list = doc.data()!['process_list'];
      return List<Map<String, dynamic>>.from(list);
    }
    return null;
  }

  Future<void> killSelectedProcesses(String clientId, List<int> pids) async {
    await _firestore.collection('computers').doc(clientId).update({
      'command': 'kill_process',
      'target_pid_list': pids,
    });
  }



}
