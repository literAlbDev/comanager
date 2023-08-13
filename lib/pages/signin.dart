import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:comanager/backend.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late SharedPreferences prefs;
  final Backend _backend = Backend();
  bool loading = false;
  bool _passwordHidden = true;
  String error = "";

  @override
  void initState(){
    super.initState();
    _initAccount().then((value){
      setState((){});
    });
  }

  Future<void> _initAccount() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString("token") != null) {
      Navigator.pushReplacementNamed(context, "/${prefs.getString("role")!}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hi,\n Welcome Back!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
            ),
            SizedBox(height: 70),
            Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    fillColor: Colors.grey[300],
                    filled: true,
                    hintText: "Email",
                    hintStyle: const TextStyle(fontSize: 13),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _passwordHidden,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    fillColor: Colors.grey[300],
                    filled: true,
                    hintText: "Password",
                    hintStyle: const TextStyle(fontSize: 13),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _passwordHidden = !_passwordHidden;
                        });
                      },
                      icon: Icon(
                        _passwordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: FilledButton(
                    onPressed: loading
                        ? null
                        : () async {
                            setState(() {
                              loading = true;
                              error = '';
                            });

                            var result = await _backend.login(
                                _emailController.text,
                                _passwordController.text);

                            if (_backend.statusCode == 200) {
                              var me = await _backend.me(result);
                              if (_backend.statusCode == 200) {
                                print(me);
                                if (me['data']['attributes'].containsKey('manager'))
                                  prefs.setString("role", "worker");
                                else
                                  prefs.setString("role", "manager");
                              } else {
                                setState(() {
                                  error = me;
                                });
                              }
                              prefs.setString("token", result);
                              Navigator.pushReplacementNamed(
                                  context, "/${prefs.getString("role")!}");
                            } else {
                              setState(() {
                                error = result;
                              });
                            }
                            setState(() {
                              loading = false;
                            });
                          },
                    child: const Text(
                      "Login",
                      style: TextStyle(fontSize: 20),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                Text.rich(
                  TextSpan(children: [
                    const TextSpan(text: "Don't have an account"),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/signup");
                        },
                        child: Text(
                          "Signup",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
                Text(
                  error,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
