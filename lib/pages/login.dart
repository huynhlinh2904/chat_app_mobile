import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../widgets/custombutton.dart';
import '../widgets/customtextinput.dart';

class ChatLoginPage extends StatefulWidget {
  const ChatLoginPage({super.key});

  @override
  State<ChatLoginPage> createState() => _ChatLoginPageState();
}

class _ChatLoginPageState extends State<ChatLoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;


  String email = 'abc@123';
  String password = '1';
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
                        'Chat App',
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
                    const SizedBox(height: 30),
                    Hero(
                      tag: 'loginbutton',
                      child: CustomButton(
                        text: 'Đăng nhập',
                        textColor: Colors.white,
                        mainColor: Colors.deepPurple,
                        onPress: () async {
                          if (email =='abc@123' && password =='1') {
                            setState(() {
                              loggingIn = false;
                            });
                            Navigator.pushNamed(context, '/main_navigation_menu');
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      child: const Text(
                        'hoặc tạo tài khoản mới',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.deepPurple,
                        ),
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
