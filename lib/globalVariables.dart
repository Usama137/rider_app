
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riderapp/dataModels/user.dart';

String mapKey='AIzaSyBBdMTXGcPdWKJbiQBCe5-SKIOKGeDlWdo';

 final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

User currentFirebaseUser;

UserFire currentUserInfo;