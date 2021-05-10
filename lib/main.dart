import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riderapp/Views/Splash.dart';
import 'package:riderapp/Views/home.dart';
import 'package:riderapp/Views/login.dart';
import 'package:riderapp/Views/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:riderapp/dataProvider/appData.dart';
import 'dart:io';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp(
    name: 'db2',
    options: Platform.isIOS || Platform.isMacOS
        ? const FirebaseOptions(
      appId: '1:297855924061:ios:c6de2b69b03a5be8',
      apiKey: 'AIzaSyD_shO5mfO9lhy2TVWhfo1VUmARKlG4suk',
      projectId: 'flutter-firebase-plugins',
      messagingSenderId: '297855924061',
      databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
    )
        : const FirebaseOptions(
      appId: '1:780492299038:android:d7aeac8be682882372870f',
      apiKey: 'AIzaSyCzFWpinf2_mgOio38RUTEzxctPvB3_dz4',
      messagingSenderId: '780492299038',
      projectId: 'select-transportation',
      databaseURL: 'https://select-transportation.firebaseio.com',
    ),
  );
  runApp(MyApp());

}



class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=> AppData(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: Splash.id,
          //initialRoute: Login(),
          //home: Login(),
          //home: Signup(),
          routes: {
            Splash.id: (context) => Splash(),
            Login.id: (context) => Login(),
            Home.id: (context)=>Home(),
            Signup.id:(context)=>Signup(),
          }

//home:RecommendRecipe(),);

          ),
    );
  }
}
