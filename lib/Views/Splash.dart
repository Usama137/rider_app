import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riderapp/components/constants.dart';
import 'package:riderapp/Views/login.dart';

class Splash extends StatefulWidget {
  static const String id = 'splash_screen';
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> offsetAnimation;
  final splashDelay = 5;

  @override
  void initState() {
    super.initState();
    _loadWidget();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(1.2, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));
  }

  _loadWidget() async {
    var _duration = Duration(seconds: splashDelay);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => Login()));
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SlideTransition(
            position: offsetAnimation,
            child: Center(
              child: Container(
                  height: 180,
                  width: 180,
                  child: Image.asset("images/OriginalonTransparentLogo.png")),
            ),
          ),
          Text(
            "SELECT TRANSPORTATION",
            style: TextStyle(
                color: splashTextColor,
                fontSize: 23,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "We provide all your transportaion needs",
            style: TextStyle(color: splashTextColor, fontSize: 16),
          )
        ],
      ),
    );
  }
}
