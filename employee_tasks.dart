import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gradient_textfield/gradient_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'log_in.dart';
import 'registration.dart';
import 'employee_tasks.dart';
import 'completed_tasks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(EmployeeTask());
}

class EmployeeTask extends StatefulWidget {
  @override
  _EmployeeTaskState createState() => _EmployeeTaskState();
}

class _EmployeeTaskState extends State<EmployeeTask> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? userName;
  String? userEmail;
  String? userType;

  @override
  void initState() {
    super.initState();
    getUserInformation();
  }

  Future<void> getUserInformation() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Retrieve additional user information
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        userName = userSnapshot.get('name');
        userEmail = userSnapshot.get('email');
        userType = userSnapshot.get('userType');
      });
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LogIn()),
          (Route<dynamic> route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged out successfully.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      appBar: AppBar(
        title: Text('My Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          if (userName != null)
            Text(
              'Logged in as: $userName',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          if (userType != null)
            Text(
              userType!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                List<Widget> taskList = [];

                snapshot.data!.docs.forEach((doc) {
                  String taskId = doc.id;
                  String task = doc.get('task');

                  taskList.add(
                    ListTile(
                      title: Text(
                        task,
                        style: TextStyle(color: Colors.teal),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.white),
                        onPressed: () {
                          markTaskAsCompleted(taskId);
                        },
                      ),
                    ),
                  );
                });

                return ListView(
                  children: taskList,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void markTaskAsCompleted(String taskId) async {
    // Move the task from 'tasks' collection to 'completed_tasks' collection
    DocumentSnapshot taskSnapshot =
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).get();
    if (taskSnapshot.exists) {
      String task = taskSnapshot.get('task');
      Timestamp timestamp = Timestamp.now();
      User? user = _auth.currentUser;

      if (user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        String userName = userSnapshot.get('name');

        FirebaseFirestore.instance.collection('completed_tasks').doc(taskId).set({
          'task': task,
          'timestamp': timestamp,
          'user': {'name': userName},
        });

        FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task marked as completed.'),
          ),
        );
      }
    }
  }
}