import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Nếu dùng Firebase Auth

import '../widgets/custombutton.dart';
import '../widgets/customtextinput.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  String email = '';
  String password = '';
  bool loggingIn = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loggingIn,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Hero(
                      tag: 'avatar',
                      child: Image.asset(
                        'assets/images/logo_docmau.png',
                        height: 120,
                        width: 120,
                        color: Colors.deepPurple[900],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Hero(
                      tag: 'HeroTitle',
                      child: Text(
                        'Đăng Ký',
                        style: TextStyle(
                          color: Colors.deepPurple[900],
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    CustomTextInput(
                      hintText: ' Tài khoản',
                      leading: Icons.account_circle,
                      obscure: false,
                      keyboard: TextInputType.emailAddress,
                      userTyped: (val) => email = val, onChanged: (String value) {  },
                    ),
                    CustomTextInput(
                      hintText: 'Mật khẩu',
                      leading: Icons.lock,
                      obscure: true,
                      keyboard: TextInputType.text,
                      userTyped: (val) => password = val, onChanged: (String value) {  },
                    ),
                    CustomTextInput(
                      hintText: 'Nhập lại Mật khẩu',
                      leading: Icons.lock,
                      obscure: true,
                      keyboard: TextInputType.text,
                      userTyped: (val) => password = val, onChanged: (String value) {  },
                    ),
                    const SizedBox(height: 30),
                    Hero(
                      tag: 'loginbutton',
                      child: CustomButton(
                        text: 'Đăng Ký',
                        textColor: Colors.white,
                        mainColor: Colors.deepPurple,
                        onPress: () async {
                          if (email.isNotEmpty && password.isNotEmpty) {
                            setState(() {
                              loggingIn = true;
                            });
                            try {
                              setState(() {
                                loggingIn = false;
                              });
                              Navigator.pushNamed(context, '/chat');
                                                        } catch (e) {
                              setState(() {
                                loggingIn = false;
                              });

                              print("Tài khoản đã tồn tại hoặc không phù hợp: $e");
                            }
                          } else {
                            print("Vui lòng nhập đủ thông tin");
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
