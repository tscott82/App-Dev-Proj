import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gradient_textfield/gradient_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'log_in.dart';
import 'registration.dart';
import 'employee_tasks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(AdminManagerTasks());
}

class AdminManagerTasks extends StatefulWidget {
  @override
  _AdminManagerTasksState createState() => _AdminManagerTasksState();
}

class _AdminManagerTasksState extends State<AdminManagerTasks> {
  TextEditingController taskController = TextEditingController();

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
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
    return Container(
      color: Colors.black45,
      child: Scaffold(
        backgroundColor: Colors.black45,
        appBar: AppBar(
          title: Text('Manager Tasks'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Task',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              Gradienttextfield(
                controller: taskController,
                radius: 40,
                height: 60,
                width: 400,
                colors: const [Colors.lightBlueAccent, Colors.green],
                text: "Enter Task",
                fontColor: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  addTask();
                },
                child: Container(
                  width: 200.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.lightBlueAccent, Colors.green],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Center(
                    child: Text(
                      'Add Task',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Completed Tasks',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('completed_tasks')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  List<Widget> completedTasks = [];

                  snapshot.data!.docs.forEach((doc) {
                    String taskId = doc.id;
                    String task = doc.get('task');
                    Timestamp timestamp = doc.get('timestamp');

                    completedTasks.add(
                      ListTile(
                        title: Text(
                          task,
                          style: TextStyle(color: Colors.teal),
                        ),
                        subtitle: Text(timestamp.toDate().toString(),
                        style: TextStyle(color: Colors.teal),),
                        trailing: Container(
                          color: Colors.black45, // Change the color here
                          child: IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.white, // Change the color here
                            onPressed: () {
                              deleteTask(taskId);
                            },
                          ),
                        ),
                      ),
                    );
                  });

                  return Column(
                    children: completedTasks,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addTask() {
    String task = taskController.text;

    if (task.isNotEmpty) {
      // Add task to Firestore
      FirebaseFirestore.instance.collection('completed_tasks').add({
        'task': task,
      });

      // Clear the task text field
      taskController.clear();

      // Show a notification or perform any other action for admin
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task added successfully.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a task description.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void deleteTask(String taskId) {
    FirebaseFirestore.instance
        .collection('completed_tasks')
        .doc(taskId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task deleted successfully.'),
      ),
    );
  }
}