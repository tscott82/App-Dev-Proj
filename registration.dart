import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradient_textfield/gradient_textfield.dart';
import 'main.dart';
import 'log_in.dart';
import 'manager_tasks.dart';
import 'employee_tasks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Registration());
}

enum UserType{
  Regular,
  Admin,
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> registerWithEmailAndPassword(
      String name, String email, String password, UserType userType) async {
    try {
      if (password.length > 12) {
        print('Password cannot exceed 12 characters');
        return null;
      }
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = result.user;
      if (user != null) {
        //additional user information
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'name': name,
          'email': email,
          'userType': userType == UserType.Admin ? 'admin' : 'regular',
        });
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
  String _errorMessage = '';
  final List<Widget> _pages = [
    Registration(),
    LogIn(),
  ];
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  UserType _selectedUserType = UserType.Regular;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule Me',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Registration'),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 150.0, vertical: 10.0),
              child: Text(
                'Name',
                style: TextStyle(fontSize: 26, color: Colors.lightBlueAccent),
              ),
            ),
            Gradienttextfield(
              controller: name,
              radius: 40,
              height: 60,
              width: 400,
              colors: const [Colors.lightBlueAccent, Colors.green],
              text: "Enter Name",
              fontColor: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.normal,
            ),
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
              padding: EdgeInsets.symmetric(horizontal: 130.0, vertical: 10.0),
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
              text: "Enter a password",
              fontColor: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.normal,
            ),
            if(_errorMessage.isNotEmpty)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ListTile(
              title: Text('User Type',
              style: TextStyle(color: Colors.teal)),
              subtitle: Row(
                children: <Widget>[
                  Radio<UserType>(
                    value: UserType.Regular,
                    groupValue: _selectedUserType,
                    onChanged: (UserType? value) {
                      setState(() {
                        _selectedUserType = value!;
                      });
                    },
                  ),
                  Text('Regular',
                      style: TextStyle(color: Colors.teal)),
                  Radio<UserType>(
                    value: UserType.Admin,
                    groupValue: _selectedUserType,
                    onChanged: (UserType? value) {
                      setState(() {
                        _selectedUserType = value!;
                      });
                    },
                  ),
                  Text('Admin',
                  style: TextStyle(color: Colors.teal)),
                ],
              ),
            ),
            FloatingActionButton(
              backgroundColor: Colors.lightBlueAccent,
              child: const Text('Create'),
              onPressed: () async {
                String trimmedPassword = password.text.trim();
                if (trimmedPassword.length < 6 || trimmedPassword.length > 12) {
                  setState(() {
                    _errorMessage = 'Password must be between 6 and 12 characters';
                  });
                } else {
                  final String? uid = await AuthService()
                      .registerWithEmailAndPassword(
                    name.text.trim(),
                    email.text.trim(), // assuming email field is used for email
                    password.text.trim(),
                    _selectedUserType, // Retrieves password from TextEditingControl
                  );

                  if (uid != null) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _selectedUserType == UserType.Admin
                            ? AdminManagerTasks()
                            : EmployeeTask(),
                      ),
                          (Route<dynamic> route) => false,
                    );
                    // Registration successful
                    // Save additional user data to Firestore if needed
                    // Redirect to another screen or perform any other actions
                  } else {
                    // Registration failed
                    // Display an error message or handle the error appropriately
                  }
                }
                },
            )
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