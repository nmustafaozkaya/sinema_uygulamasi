import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/rounded_button.dart';
import 'package:sinema_uygulamasi/components/rounded_input_field.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:sinema_uygulamasi/components/user_preferences.dart';
import 'package:sinema_uygulamasi/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var emailController = TextEditingController();
  var nameController = TextEditingController();
  var passwordController = TextEditingController();
  var RepasswordController = TextEditingController();

  Future<void> registerAndSaveUserRecord() async {
    var body = jsonEncode({
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
      'password_confirmation': RepasswordController.text.trim(),
    });

    try {
      var res = await http.post(
        Uri.parse(ApiConnection.signUp),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      var resBodyofSignUp = jsonDecode(res.body);

      if (res.statusCode == 200) {
        if (resBodyofSignUp['status'] == true) {
          Fluttertoast.showToast(msg: 'Successfully registered!');

          var userData = resBodyofSignUp['data'];
          User user = User.fromJson(userData);
          await RememberUserPrefs.saveRememberUser(user);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );

          setState(() {
            nameController.clear();
            emailController.clear();
            passwordController.clear();
            RepasswordController.clear();
          });
        } else {
          Fluttertoast.showToast(
            msg: 'Error occurred: ${resBodyofSignUp['error']}',
          );
        }
      } else if (res.statusCode == 422) {
        // Validation errors
        if (resBodyofSignUp['errors'] != null) {
          if (resBodyofSignUp['errors']['email'] != null) {
            Fluttertoast.showToast(
              msg: 'Email error: ${resBodyofSignUp['errors']['email'][0]}',
            );
          }
          if (resBodyofSignUp['errors']['password'] != null) {
            Fluttertoast.showToast(
              msg:
                  'Password error: ${resBodyofSignUp['errors']['password'][0]}',
            );
          }
        } else {
          Fluttertoast.showToast(msg: 'Validation error');
        }
      } else if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Unauthorized. Check your request.');
      } else {
        Fluttertoast.showToast(msg: 'Server error: ${res.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('assets/images/logo.png', height: 150, width: 150),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    RoundedInputField(
                      controller: nameController,
                      hintText: 'Name',
                      icon: Icons.person,
                      isEmail: false,
                      isPassword: false,
                      onChange: (value) {},
                    ),
                    RoundedInputField(
                      controller: emailController,
                      hintText: 'E-mail',
                      icon: Icons.mail,
                      isEmail: true,
                      isPassword: false,
                      onChange: (value) {},
                    ),
                    RoundedInputField(
                      controller: passwordController,
                      hintText: 'Password',
                      icon: Icons.lock,
                      isEmail: false,
                      isPassword: true,
                      onChange: (value) {},
                    ),
                    RoundedInputField(
                      controller: RepasswordController,
                      hintText: 'Repeat Password',
                      icon: Icons.lock,
                      isEmail: false,
                      isPassword: true,
                      onChange: (value) {},
                    ),
                    RoundedButton(
                      text: 'Register',
                      onPressed: () {
                        if (RepasswordController.text.trim() !=
                            passwordController.text.trim()) {
                          Fluttertoast.showToast(msg: 'Passwords are not same');
                        } else {
                          registerAndSaveUserRecord();
                        }
                      },
                      color: const Color(0xFF5FCFAF),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: const Text("Already have an account? Login"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
