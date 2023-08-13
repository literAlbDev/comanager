import 'package:comanager/backend.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _rpasswordController = TextEditingController();
  bool _passwordHidden = true;
  bool _rpasswordHidden = true;
  late SharedPreferences prefs;
  final Backend _backend = Backend();
  bool loading = false;
  String error = "";

  @override
  void initState() {
    super.initState();
    _initAccount().then((value) {
      setState(() {});
    });
  }

  Future<void> _initAccount() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 70),
            TextFormField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15),
                ),
                fillColor: Colors.grey[300],
                filled: true,
                hintText: "Full Name",
                hintStyle: const TextStyle(fontSize: 13),
              ),
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 20),
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
                    _passwordHidden ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _rpasswordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: _rpasswordHidden,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15),
                ),
                fillColor: Colors.grey[300],
                filled: true,
                hintText: "Re-Password",
                hintStyle: const TextStyle(fontSize: 13),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _rpasswordHidden = !_rpasswordHidden;
                    });
                  },
                  icon: Icon(
                    _rpasswordHidden ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
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

                        if (_passwordController.text !=
                            _rpasswordController.text) {
                          setState(() {
                            error = "the 2 password fields did not match";
                            loading = false;
                          });
                          return;
                        }

                        var result = await _backend.signup(_nameController.text,
                            _emailController.text, _passwordController.text);

                        if (_backend.statusCode < 300) {
                          var me = await _backend.me(result);
                          if (_backend.statusCode < 300) {
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
                  "Signup",
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
            Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: "Already have an account ?"),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/signin");
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              error,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
