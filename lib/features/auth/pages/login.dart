import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../core/widgets/custombutton.dart';
import '../../../core/widgets/customtextinput.dart';
import '../authServices/login_notifier.dart';

class ChatLoginPage_DEV extends ConsumerStatefulWidget {
  const ChatLoginPage_DEV({super.key});

  @override
  ConsumerState<ChatLoginPage_DEV> createState() => _ChatLoginPageState();
}

class _ChatLoginPageState extends ConsumerState<ChatLoginPage_DEV> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginNotifierProvider);

    return ModalProgressHUD(
      inAsyncCall: loginState.isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'avatar',
                        child: Image.asset(
                          'assets/images/logo_docmau.png',
                          height: 120,
                          width: 120,
                          color: Colors.deepPurple[900],
                        ),
                      ),
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 16),
                      CustomTextInput(
                        hintText: 'Tài khoản',
                        leading: Icons.account_circle,
                        obscure: false,
                        keyboard: TextInputType.text,
                        controller: usernameController,
                        onChanged: (_) {},
                      ),
                      CustomTextInput(
                        hintText: 'Mật khẩu',
                        leading: Icons.lock,
                        obscure: true,
                        keyboard: TextInputType.text,
                        controller: passwordController,
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 30),
                      Hero(
                        tag: 'loginbutton',
                        child: CustomButton(
                          text: 'Đăng nhập',
                          textColor: Colors.white,
                          mainColor: Colors.deepPurple,
                          onPress: () {
                            final user = usernameController.text.trim();
                            final pass = passwordController.text.trim();

                            if (user.isEmpty || pass.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (_) => const AlertDialog(
                                  title: Text('Lỗi'),
                                  content: Text('Vui lòng nhập tài khoản và mật khẩu'),
                                ),
                              );
                              return;
                            };

                            ref.read(loginNotifierProvider.notifier).login(context, user, pass);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
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
      ),
    );
  }
}
