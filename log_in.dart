import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gradient_textfield/gradient_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'registration.dart';
import 'manager_tasks.dart';
import 'employee_tasks.dart';
import 'completed_tasks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(LogIn());
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> loginWithEmailAndPassword(
      String email,
      String password
      ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = result.user;
      if (user != null) {
        return user.uid;
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    MyHomePage(),
    Registration(),
    LogIn(),
  ];
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  UserType _selectedUserType = UserType.Regular;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        backgroundColor: Colors.black45,
        appBar: AppBar(
          title: Text('Login'),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 150.0, vertical: 10.0),
              child: Text(
                'Email',
                style: TextStyle(fontSize: 26, color: Colors.lightBlueAccent),
              ),
            ),
            Gradienttextfield(
              controller: email,
              radius: 40,
              height: 60,
              width: 400,
              colors: const [Colors.lightBlueAccent, Colors.green],
              text: "example@gmail.com",
              fontColor: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.normal,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 130.0),
              child: Text(
                'Password',
                style: TextStyle(fontSize: 26, color: Colors.lightBlueAccent),
              ),
            ),
            Gradienttextfield(
              controller: password,
              radius: 40,
              height: 60,
              width: 400,
              colors: const [Colors.lightBlueAccent, Colors.green],
              text: "password123",
              fontColor: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.normal,
            ),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  errorMessage = null; // Reset the error message
                });

                final String? uid = await AuthService().loginWithEmailAndPassword(
                  email.text.trim(),
                  password.text.trim(),
                );

                if (uid != null) {
                  // Retrieve the user's profile from Firestore
                  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .get();

                  String profileType = userSnapshot.get('userType');

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => profileType == 'admin'
                          ? AdminManagerTasks()
                          : EmployeeTask(),
                    ),
                        (Route<dynamic> route) => false,
                  );
                  // Redirect to another screen or perform any other actions
                } else {
                  setState(() {
                    errorMessage = 'Invalid email or password.';
                  });
                  // Display an error message or handle the error appropriately
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.teal,
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Registration()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogIn()),
              );
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_add),
              label: 'Registration',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.login),
              label: 'Login',
            ),
          ],
        ),
      ),
    );
  }
}