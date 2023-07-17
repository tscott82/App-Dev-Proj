import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gradient_textfield/gradient_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(CompletedTasks());
}

class CompletedTasks extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final DateFormat _timeFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Completed Tasks',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('completed_tasks').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final completedTasks = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: completedTasks.length,
                    itemBuilder: (context, index) {
                      final task = completedTasks[index].get('task');
                      final timestamp = completedTasks[index].get('timestamp');
                      final user = completedTasks[index].get('user');
                      final userName = user['name'];

                      final formattedDate = _dateFormat.format(timestamp.toDate());
                      final formattedTime = _timeFormat.format(timestamp.toDate());

                      return ListTile(
                        title: Text(
                          task,
                          style: TextStyle(color: Colors.teal),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Completed by: $userName',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              formattedTime,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error.toString()}'),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}