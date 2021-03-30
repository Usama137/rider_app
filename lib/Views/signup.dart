import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riderapp/sizes_helpers.dart';
import 'package:riderapp/components/constants.dart';
import 'package:riderapp/components/tracking_text_input.dart';
import 'package:riderapp/components/rounded_button.dart';
import 'login.dart';

class Signup extends StatefulWidget {
  static const String id = 'signup_screen';
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String email;
  String password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          Container(
            height: displayHeight(context)*0.28,
            width: double.infinity,
            //color: splashTextColor,
            decoration: BoxDecoration(
                color: splashTextColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                )
            ),
            child: Column(
              children: [
                SizedBox(
                  height: displayHeight(context)*0.04,
                ),
                Row(
                  children: [
                    Container(

                      width: 60,
                      child: InkWell(
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onTap: (){
                          Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (BuildContext context) => Login()));
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: displayHeight(context)*0.02,
                ),
                Text(
                  "SignUp",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 40
                  ),
                ),
                SizedBox(height: 30,),

                Text(
                  "SELECT TRANSPORTATION",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  ),
                ),
                Text(

                  "We provide all your transportaion needs",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                )

              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text("Create a new account", style: TextStyle(
              color: Colors.black87,
              fontSize: 18
            ),),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Container(
              height: displayHeight(context)*0.07,
              width: displayWidth(context)*0.8,

              decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey,
                      width: 2
                  ),
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    child: Icon(
                      Icons.email,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: TrackingTextInput(

                      hint: "Enter Email",
                      colour: Colors.grey,
                      onTextChanged: (String value) {
                        email = value;
                      },
                    ),
                  ),
                ],
              ),





            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
            child: Container(
              height: displayHeight(context)*0.07,
              width: displayWidth(context)*0.8,

              decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey,
                      width: 2
                  ),
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    child: Icon(
                      Icons.vpn_key,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: TrackingTextInput(

                      hint: "Enter Password",
                      colour: Colors.grey,
                      onTextChanged: (String value) {
                        email = value;
                      },
                    ),
                  ),
                ],
              ),





            ),
          ),
          RoundedButton(
            title: 'SignUp',
            textColor: Colors.white,
            buttonColor: Colors.deepOrange,
            buttonHeight: 30,
            buttonWidth: displayWidth(context)*0.4,
            onPressed: (){
             // Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Login()));
            },
          ),
        ],
      ),
    );
  }
}
