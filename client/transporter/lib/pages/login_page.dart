import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:transporter/utils/mycolors.dart';
import 'package:transporter/utils/route.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? email;
  String? password;

  bool passwordVisible = false;
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    login() async {
      if (_formkey.currentState!.validate()) {
        var data = jsonEncode({'email': email, 'password': password});
        var url = "http://10.0.2.2:7000/users/transporter";
        var response = await http.post(Uri.parse(url),
            headers: {'Content-Type': 'application/json'}, body: data);
        var responseBody = await jsonDecode(response.body);
        if (responseBody["message"] == "Login sucessfull") {
          var data = responseBody["data"];
          Navigator.pushNamed(context, "/homepage", arguments: data);
        } else {
          return showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Login Failed'),
                  content: Text('E-mail or username not valid'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK')),
                  ],
                );
              });
        }
      }
    }

    Size size = MediaQuery.of(context).size;
    return Material(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Column(
            children: <Widget>[
              Container(
                width: 85,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80),
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 15)]),
                child: const Center(
                  child: CircleAvatar(
                    maxRadius: 40,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: size.width / 2 + 60,
                  child: Form(
                    key: _formkey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return "* E-mail cannot be empty";
                            } else if (!EmailValidator.validate(value)) {
                              return "* Invalid Email";
                            }
                            return null;
                          }),
                          onChanged: (value) {
                            setState(() {
                              email = value;
                            });
                          },
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40)),
                            prefixIcon: Icon(Icons.mail_outline),
                            hintText: "E-mail",
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "* Password required";
                            } else if (value.length < 6) {
                              return "* Password too short. Must be 6-10 characters";
                            }
                            return null;
                          },
                          onChanged: ((value) => password = value),
                          obscureText: !passwordVisible,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40)),
                            prefixIcon: Icon(Icons.lock_outline),
                            hintText: "Password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                passwordVisible
                                    ? (Icons.visibility_off_outlined)
                                    : (Icons.visibility_outlined),
                              ),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                  child: TextButton(
                onPressed: () {
                  login();
                  // Navigator.pushNamed(context, MyRoutes.homepage);
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.blue.shade400)),
                child: Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
              )),
              const SizedBox(height: 20),
              const Text("Or",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(left: 18, right: 18),
                child: Divider(
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              SignInButton(
                Buttons.Google,
                onPressed: () {},
                elevation: 5,
              ),
              SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(text: "Do not have an account?"),
                    TextSpan(
                        text: "Sign Up",
                        style: TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, MyRoutes.signupPhone);
                          }),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}