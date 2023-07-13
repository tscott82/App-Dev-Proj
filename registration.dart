import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradient_textfield/gradient_textfield.dart';
import 'main.dart';
import 'log_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(LogIn());
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = result.user;
      if (user != null) {
        final name = user.displayName;
        final email = user.email;
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

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  int count = 0;
  int _currentIndex = 0;
  final List<Widget> _pages = [
    Registration(),
    LogIn(),
  ];
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule Me',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Registration'),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 150.0, vertical: 10.0),
              child: Text('Name',
                style: TextStyle(fontSize: 26, color: Colors.lightBlueAccent),
              ),
            ),
            Gradienttextfield(
              controller: name,
              radius: 40,
              height: 60,
              width: 400,
              colors: const [Colors.lightBlueAccent, Colors.green],
              text: "First and Last Name",
              fontColor: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.normal,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 150.0, vertical: 10.0),
              child: Text('Email',
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
              padding: EdgeInsets.symmetric(horizontal: 130.0, vertical: 10.0),
              child: Text('Password',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: null,
                  child: Text(''),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 50.0),
                  child: Text(
                      'Manager',
                      style: TextStyle(
                          fontSize: 24, color: Colors.lightBlueAccent)),
                ),
                ElevatedButton(
                  onPressed: null,
                  child: Text(''),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlueAccent),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 30.0),
                  child: Text('Employee',
                      style: TextStyle(
                          fontSize: 24, color: Colors.lightBlueAccent)),
                ),
              ],
            ),
            FloatingActionButton(
              backgroundColor: Colors.lightBlueAccent,
              child: const Text('Create'),
              onPressed: () async {
                final String? uid = await AuthService()
                    .registerWithEmailAndPassword(
                  email.text.trim(), // assuming name field is used for email
                  password.text.trim(), // provide a default password or use a separate password field
                );

                if (uid != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LogIn()),
                  ); // Registration successful
                  // Save additional user data to Firestore if needed
                  // Redirect to another screen or perform any other actions
                } else {
                  // Registration failed
                  // Display an error message or handle the error appropriately
                }
              },
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
            if (index == 0){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            }else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Registration()),
              );
            }else if (index == 2) {
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