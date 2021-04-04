

import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:riderapp/dataModels/address.dart';
import 'package:riderapp/dataProvider/appData.dart';
import 'package:riderapp/globalVariables.dart';
import 'package:riderapp/helpers/requestHelper.dart';
import 'package:provider/provider.dart';


class HelperMethods{

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
}