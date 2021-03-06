

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riderapp/dataModels/address.dart';
import 'package:riderapp/dataModels/directionDetails.dart';
import 'package:riderapp/dataModels/user.dart';
import 'package:riderapp/dataProvider/appData.dart';
import 'package:riderapp/globalVariables.dart';
import 'package:riderapp/helpers/requestHelper.dart';
import 'package:provider/provider.dart';


class HelperMethods{


  static void getCurrentUserInfo()async{
    currentFirebaseUser=await FirebaseAuth.instance.currentUser;
    String userid=currentFirebaseUser.uid;
    DatabaseReference userRef=FirebaseDatabase.instance.reference().child('users/$userid');
    
    userRef.once().then((DataSnapshot snapshot) {
      if(snapshot.value!=null){
         currentUserInfo=UserFire.fromSnapshot(snapshot);
        print("my name is ${currentUserInfo.fullName}");
      }
    });
  }

  static Future<String> findCoordinateAddress(Position position, context)async{
    String placeAddress='';
    var connectivityResult=await Connectivity().checkConnectivity();
    if(connectivityResult!=ConnectivityResult.mobile && connectivityResult!=ConnectivityResult.wifi){
      return placeAddress;
    }
    String url='https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';
    //String url='https://maps.googleapis.com/maps/api/geocode/json?latlng=,30.297279,73.070641&key=$mapKey';

    var response= await RequestHelper.getRequest(url);
    if(response!='failed'){
      placeAddress=response['results'][0]['formatted_address'];
      print(placeAddress);
      Address pickupAddress=new Address();
      pickupAddress.longitude=position.longitude;
      pickupAddress.latitude=position.latitude;
      pickupAddress.placeName=placeAddress;
      
      Provider.of<AppData>(context, listen: false).updatePickupAddress(pickupAddress);

    }
    return placeAddress;
  }


  static Future<DirectionDetails> getDirectionDetails(LatLng startPosition, LatLng endPosition ) async{
    String url='https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKey';

    var response=await RequestHelper.getRequest(url);
    if(response=='failed'){
      return null;
    }
    DirectionDetails directionDetails=DirectionDetails();

    directionDetails.durationText=response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue=response['routes'][0]['legs'][0]['duration']['value'];

    directionDetails.distanceText=response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue=response['routes'][0]['legs'][0]['distance']['value'];

    directionDetails.encodedPoints=response['routes'][0]['overview_polyline']['points'];

    return directionDetails;
  }

  static int estimateFares(DirectionDetails details){
    //per km=0.3
    //per minute= 0.2
    //base fare = 3
     double baseFare=3;
     double distanceFare=(details.distanceValue/1000)*0.3;
     double timeFare=(details.durationValue/60)*0.2;

     double totalFare=baseFare+distanceFare+timeFare;


    return totalFare.truncate();

  }


  static double generateRandomNumber (int max){
    var randomGenerator=Random();
    int radInt=randomGenerator.nextInt(max);
    return radInt.toDouble();
  }

}