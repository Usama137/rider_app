import 'package:flutter/material.dart';
import 'package:riderapp/Views/Splash.dart';
import 'package:riderapp/Views/home.dart';
import 'package:riderapp/Views/login.dart';
import 'package:riderapp/Views/signup.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: Splash.id,
        routes: {
          Splash.id: (context) => Splash(),
          Login.id: (context) => Login(),
          Home.id: (context)=>Home(),
          Signup.id:(context)=>Signup(),
        }

//home:RecommendRecipe(),);

        );
  }
}
