import 'package:flutter/material.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  void dispose() {
    _emailcontroller.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/login.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(left: 35, top: 130),
              child: Text(
                'Welcome\nBack',
                style: TextStyle(color: Colors.white, fontSize: 33),
              ),
            ),
            SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 300),
                    Form(
                      key: _formKey,
                      child: Container(
                        margin: EdgeInsets.only(left: 35, right: 35),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailcontroller,
                              decoration: InputDecoration(
                                fillColor: Colors.grey.shade200,
                                filled: true,
                                hintText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                hintText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 27,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Color(0xff4c505b),
                                  child: IconButton(
                                    color: Colors.white,
                                    onPressed: () {
                                      final email = _emailcontroller.text
                                          .trim();
                                      final pass = _passwordController.text
                                          .trim();

                                      String? message;
                                      if (email.isEmpty) {
                                        message = 'Please enter your email';
                                      } else if (!RegExp(
                                        r'^[^@]+@[^@]+\.[^@]+',
                                      ).hasMatch(email)) {
                                        message =
                                            'Please enter a valid email address';
                                      } else if (pass.isEmpty) {
                                        message = 'Please enter your password';
                                      } else if (pass.length < 6) {
                                        message =
                                            'Password must be at least 6 characters long';
                                      }

                                      if (message != null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(message)),
                                        );
                                        return;
                                      }

                                      Navigator.pushNamed(context, 'home');
                                    },
                                    icon: Icon(Icons.arrow_forward),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  icon: Image.asset(
                                    'assets/google_logo.png',
                                    width: 20,
                                    height: 45,
                                    errorBuilder: (c, e, s) => Icon(Icons.login, size: 20),
                                  ),
                                  label: Text('Sign in with Google'),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Google Sign-In in progress')),
                                    );
                                  },
                                ),
                              ),
                            SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, 'signup');
                                  },
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: 18,
                                      color: Color(0xff4c505b),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Forgot Password',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: 18,
                                      color: Color(0xff4c505b),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}