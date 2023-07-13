import 'package:flutter/material.dart';
import 'package:gradient_textfield/gradient_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'log_in.dart';
import 'registration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule Me',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    MyHomePage(),
    Registration(),
    LogIn(),
  ];

  String? userName;
  String? userEmail;

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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Schedule Me'),
        centerTitle: true,
      ),
      body:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (userName != null) Text('$userName'),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Registration()),
              );
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
                  'Registration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 100.0, vertical: 10.0),// Set the primary color as transparent
              elevation: 0, // Remove the elevation
              shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(30)), // Set the shape to match the Container's border radius
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogIn()),
              );
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
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 10.0),// Set the primary color as transparent
              elevation: 0, // Remove the elevation
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Set the shape to match the Container's border radius
            ),
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
    );
  }
}

