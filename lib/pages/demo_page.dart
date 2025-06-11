import 'package:flutter/material.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
    return Scaffold(
      appBar: AppBar(
        title:
        Align(
          alignment: Alignment.centerRight,
          child: Text("data"),
        ),
        backgroundColor: Colors.amber,),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
        [
          Image.asset("assets/images/logo_docmau.png",
              width: 100,
              height: 150,
              fit:BoxFit.fill),
          Image.asset("assets/images/logo_docmau.png",
              width: 100,
              height: 150,
              fit:BoxFit.fill),
          Image.asset("assets/images/logo_docmau.png",
              width: 100,
              height: 150,
              fit:BoxFit.fill),
        ],
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title:
    //     Text("data"),
    //     centerTitle: true,
    //     backgroundColor: Colors.amber,
    //     // leadingWidth: 200,
    //
    //
    //   ),
    // );
  }
}
