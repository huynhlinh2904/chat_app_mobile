import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../core/widgets/custombutton.dart';
import '../../../core/widgets/customtextinput.dart';
import '../authServices/login_provider.dart';

class ChatLoginPage extends ConsumerStatefulWidget {
  const ChatLoginPage({super.key});

  @override
  ConsumerState<ChatLoginPage> createState() => _ChatLoginPageState();
}

class _ChatLoginPageState extends ConsumerState<ChatLoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  String user = 'spadmin';
  String password = '1';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // Lắng nghe login state
    // Future.microtask(() {
    //
    // });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginNotifierProvider);
    ref.listen(loginNotifierProvider, (previous, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/main_navigation_menu');
        Future.delayed(Duration(milliseconds: 500), () {
          ref.read(loginNotifierProvider.notifier).reset();
        });
      });

      if (next.error != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Lỗi đăng nhập'),
              content: Text(next.error!),
              actions: [
                TextButton(
                  onPressed: () {
                    ref.read(loginNotifierProvider.notifier).reset();
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        });
      }
    });

    return ModalProgressHUD(
      inAsyncCall: loginState.isLoading,
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
                      hintText: 'Tài khoản',
                      leading: Icons.account_circle,
                      obscure: false,
                      keyboard: TextInputType.emailAddress,
                      userTyped: (val) => user = val,
                      onChanged: (_) {},
                    ),
                    CustomTextInput(
                      hintText: 'Mật khẩu',
                      leading: Icons.lock,
                      obscure: true,
                      keyboard: TextInputType.text,
                      userTyped: (val) => password = val,
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 30),
                    Hero(
                      tag: 'loginbutton',
                      child: CustomButton(
                        text: 'Đăng nhập',
                        textColor: Colors.white,
                        mainColor: Colors.deepPurple,
                        onPress: () async {
                          await ref.read(loginNotifierProvider.notifier).login(user, password);
                          print('Login thành công, chuyển sang /main_navigation_menu');
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
