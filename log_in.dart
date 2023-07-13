import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gradient_textfield/gradient_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'registration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(LogIn());
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> loginWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = result.user;
      if (user != null) {
        final userSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        final userName = userSnapshot.get('name');
        final userEmail = userSnapshot.get('email');
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
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
            ElevatedButton(
              onPressed: () async {
                final String? uid = await AuthService().loginWithEmailAndPassword(
                  email.text.trim(),
                  password.text.trim(),
                );

                if (uid != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                  );// Login successful
                  // Redirect to another screen or perform any other actions
                } else {
                  // Login failed
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
    if (index == 0){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }else if(index == 1) {
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