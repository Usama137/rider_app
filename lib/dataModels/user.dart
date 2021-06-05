import 'package:firebase_database/firebase_database.dart';

class UserFire {
  String fullName;
  String email;
  String phone;
  String id;

  UserFire({this.id, this.phone, this.email, this.fullName});

   UserFire.fromSnapshot(DataSnapshot snapshot){
     id=snapshot.key;
     phone=snapshot.value['phone'];
     email=snapshot.value['email'];
     fullName=snapshot.value['name'];

   }

}
