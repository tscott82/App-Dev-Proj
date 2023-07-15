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
      appBar: AppBar(
        title: Text('My Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
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
                title: Text(task),
                trailing: IconButton(
                  icon: Icon(Icons.check_circle),
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
    );
  }

  void markTaskAsCompleted(String taskId) async {
    // Move the task from 'tasks' collection to 'completed_tasks' collection
    DocumentSnapshot taskSnapshot = await FirebaseFirestore.instance.collection('tasks').doc(taskId).get();
    if (taskSnapshot.exists) {
      String task = taskSnapshot.get('task');
      Timestamp timestamp = Timestamp.now();
      User? user = _auth.currentUser;

      if (user != null) {
        String userName = user.displayName ?? user.email ?? '';

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