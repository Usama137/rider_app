//import 'dart:io';

import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:riderapp/Views/search.dart';
import 'package:riderapp/components/constants.dart';
import 'package:riderapp/components/rounded_button.dart';
import 'package:riderapp/components/styles.dart';
import 'package:riderapp/dataModels/directionDetails.dart';
import 'package:riderapp/dataModels/nearbyDriver.dart';
import 'package:riderapp/dataProvider/appData.dart';
import 'package:riderapp/globalVariables.dart';
import 'package:riderapp/helpers/firehelper.dart';
import 'package:riderapp/helpers/helperMethods.dart';
import 'dart:async';

import 'package:riderapp/sizes_helpers.dart';
import 'package:riderapp/widgets/ProgressDialog.dart';
import 'package:riderapp/widgets/brandDivider.dart';
import 'package:riderapp/widgets/ProgressDialog.dart';

class Home extends StatefulWidget {
  static const String id = 'home_screen';
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  double searchSheetHeight = screenHeight * 0.32;
  double rideDetailsSheetHeight = 0;
  double requestSheetHeight = 0; //(Platform.isAndroid)?195:220

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapBottomPadding = 0;

  List<LatLng> polyLineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _Markers = {};
  Set<Circle> _Circles = {};

  BitmapDescriptor nearbyIcon;

  var geoLocator = Geolocator();
  Position currentPosition;
  DirectionDetails tripDirectionDetails;

  bool drawerCanOpen = true;

  DatabaseReference rideRef;

  bool nearyDriversKeysLoaded=false;

  void setupPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

    String address =
        await HelperMethods.findCoordinateAddress(position, context);
    //print(address);

    startGeofireListener();
  }

  void showDetailSheet() async {
    await getDirection();
    setState(() {
      searchSheetHeight = 0;
      rideDetailsSheetHeight = screenHeight * 0.29;
      mapBottomPadding = screenHeight * 0.31;
      drawerCanOpen = false;
    });
  }

  void showRequestSheet() {
    setState(() {
      rideDetailsSheetHeight = 0;
      requestSheetHeight = 195;
      mapBottomPadding = 200;
      drawerCanOpen = true;
    });
    createRideRequest();
  }

  void createMarker(){
   if(nearbyIcon==null){
     ImageConfiguration imageConfiguration=createLocalImageConfiguration(context, size:Size(2,2));
     BitmapDescriptor.fromAssetImage(imageConfiguration,(Platform.isIOS)
         ?'images/car_ios.png'
         :'images/car_android.png'
     ).then((icon) {
       nearbyIcon=icon;
     });
   }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //setupPositionLocator();
    HelperMethods.getCurrentUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    createMarker();
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      drawer: Container(
        width: 250,
        color: Colors.white,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.all(0),
            children: [
              Container(
                height: 160,
                color: Colors.white,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Name of rider",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "View Profile",
                        style: TextStyle(color: Colors.deepOrange),
                      )
                    ],
                  ),
                ),
              ),
              BrandDivider(),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Icon(Icons.credit_card),
                title: Text(
                  'Payments',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  'Ride History',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(Icons.contact_support),
                title: Text(
                  'Support',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(
                  'About',
                  style: kDrawerItemStyle,
                ),
              )
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapBottomPadding, top: 30),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: _polylines,
            markers: _Markers,
            circles: _Circles,
            initialCameraPosition: googlePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              setState(() {
                mapBottomPadding = displayHeight(context) * 0.34;
              });

              setupPositionLocator();
            },
          ),
          Positioned(
            top: 44,
            left: 20,
            child: GestureDetector(
              onTap: () {
                if (drawerCanOpen) {
                  scaffoldKey.currentState.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          spreadRadius: 0.5,
                          offset: Offset(
                            0.7,
                            0.7,
                          ))
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(
                    (drawerCanOpen) ? Icons.menu : Icons.arrow_back,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            ),
          ),

          //Search Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: searchSheetHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15.0,
                          spreadRadius: 0.5,
                          offset: Offset(
                            0.7,
                            0.7,
                          ))
                    ]),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: displayHeight(context) * 0.005,
                      ),
                      Text(
                        "Nice to see you!",
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(
                        "Where are you going?",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      //SizedBox(height: 20,),
                      SizedBox(
                        height: displayHeight(context) * 0.02,
                      ),
                      GestureDetector(
                        onTap: () async {
                          var response = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Search()));
                          if (response == 'getDirection') {
                            //await getDirection();
                            showDetailSheet();
                          }
                        },
                        child: Container(
                          height: displayHeight(context) * 0.05,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5.0,
                                    spreadRadius: 0.5,
                                    offset: Offset(
                                      0.7,
                                      0.7,
                                    ))
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Search Destination',
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: displayHeight(context) * 0.022,
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons.home,
                            color: splashTextColor,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text((Provider.of<AppData>(context).pickupAddress.placeName!=null)?Provider.of<AppData>(context).pickupAddress.placeName:'Add Home'),
                              Text("Add Home"),
                              SizedBox(
                                height: displayHeight(context) * 0.003,
                              ),
                              Text(
                                'Your residential address',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.black12),
                              )
                            ],
                          )
                        ],
                      ),

                      // SizedBox(height: 10,),
                      SizedBox(
                        height: displayHeight(context) * 0.01,
                      ),
                      BrandDivider(),
                      // SizedBox(height: 16,),
                      SizedBox(
                        height: displayHeight(context) * 0.016,
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons.work,
                            color: splashTextColor,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add Work'),
                              SizedBox(
                                height: displayHeight(context) * 0.003,
                              ),
                              Text(
                                'Your office address',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.black12),
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //Ride details sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15.0,
                          spreadRadius: 0.5,
                          offset: Offset(
                            0.7,
                            0.7,
                          ))
                    ]),
                // height: displayHeight(context) * 0.29,
                height: rideDetailsSheetHeight,

                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Column(
                    children: [
                      Container(
                        color: Colors.orange.shade50,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_taxi,
                                color: Colors.deepOrange,
                                size: 50,
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Taxi",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    (tripDirectionDetails != null)
                                        ? tripDirectionDetails.distanceText
                                        : '',
                                    style: TextStyle(fontSize: 15),
                                  )
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                (tripDirectionDetails != null)
                                    ? '\$${HelperMethods.estimateFares(tripDirectionDetails)}'
                                    : '',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.moneyBillAlt,
                              size: 24,
                            ),
                            SizedBox(
                              width: 18,
                            ),
                            Text(
                              'Cash',
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                            ),
                            SizedBox(width: 35),
                            Image(
                              alignment: Alignment.center,
                              height: 40,
                              width: 40,
                              image: AssetImage('images/stripe.png'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RoundedButton(
                        buttonColor: splashTextColor,
                        textColor: Colors.white,
                        title: 'Request CAB',
                        buttonWidth: displayWidth(context) * 0.80,
                        onPressed: () {
                          showRequestSheet();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          //request Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15.0,
                          spreadRadius: 0.5,
                          offset: Offset(
                            0.7,
                            0.7,
                          ))
                    ]),
                height: requestSheetHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextLiquidFill(
                          text: 'Requesting a Ride..',
                          waveColor: Colors.grey,
                          boxBackgroundColor: Colors.white,
                          textStyle: TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                          boxHeight: 40.0,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(width: 1.0, color: Colors.grey),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 25,
                          ),
                        ),
                        onTap: () {
                          cancelRequest();
                          resetApp();
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Text(
                          'Cancel Ride',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 12, color: Colors.deepOrange),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getDirection() async {
    var pickUp = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    var pickLatLng = LatLng(pickUp.latitude, pickUp.longitude);
    var destinationLatLng = LatLng(destination.latitude, destination.longitude);

    /*
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context)=>CircularProgressIndicator(),
    );


    */

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              status: 'Please wait..',
            ));

    var thisDetails =
        await HelperMethods.getDirectionDetails(pickLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetails = thisDetails;
    });

    Navigator.pop(context);
    print(thisDetails.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);

    polyLineCoordinates.clear();
    if (results.isNotEmpty) {
      results.forEach((PointLatLng point) {
        polyLineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyId'),
        color: Colors.blue,
        points: polyLineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polylines.add(polyline);
    });

    LatLngBounds bounds;
    if (pickLatLng.latitude > destinationLatLng.latitude &&
        pickLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);
    } else if (pickLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, pickLatLng.longitude));
    } else if (pickLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickLatLng.longitude),
          northeast: LatLng(pickLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickLatLng, northeast: destinationLatLng);
    }

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickUp.placeName, snippet: 'My Location'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: destination.placeName, snippet: 'Destination'),
    );

    setState(() {
      _Markers.add(pickupMarker);
      _Markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: Colors.green,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: Colors.purpleAccent,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: Colors.purpleAccent,
    );

    setState(() {
      _Circles.add(pickupCircle);
      _Circles.add(destinationCircle);
    });
  }

  void startGeofireListener() {
    Geofire.initialize('driversAvailable');

    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 20)
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];
            FireHelper.nearbyDriverList.add(nearbyDriver);

            if(nearyDriversKeysLoaded){
              updateDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            FireHelper.removeFromList(map['key']);
            updateDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            // Update your key's location

            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];

            FireHelper.updateNearbyLocation(nearbyDriver);
            updateDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded

            nearyDriversKeysLoaded=true;
            updateDriversOnMap();
            print('FireHelper length: ${FireHelper.nearbyDriverList.length}');

            break;
        }
      }
    });
  }

  void updateDriversOnMap() {

    setState(() {
      _Markers.clear();
    });

    Set<Marker> tempMarker=Set<Marker>();
    for(NearbyDriver driver in FireHelper.nearbyDriverList){
      LatLng driverPosition=LatLng(driver.latitude, driver.longitude);
      Marker thisMarker=Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverPosition,
        icon: nearbyIcon,
        rotation: HelperMethods.generateRandomNumber(360),
      );
      tempMarker.add(thisMarker);
    }

    setState(() {
      _Markers=tempMarker;
    });
  }

  void createRideRequest() {
    rideRef = FirebaseDatabase.instance.reference().child('rideRequest').push();
    var pickUp = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    Map pickupMap = {
      'latitude': pickUp.latitude.toString(),
      'longitude': pickUp.longitude.toString(),
    };

    Map destinationMap = {
      'latitude': destination.latitude.toString(),
      'longitude': destination.longitude.toString(),
    };

    Map rideMap = {
      'created_at': DateTime.now().toString(),
      'rider_name': currentUserInfo.fullName,
      'rider_phone': currentUserInfo.phone,
      'pickup_address': pickUp.placeName,
      'destination_address': destination.placeName,
      'location': pickupMap,
      'destination': destinationMap,
      'payment_method': 'card',
      'driver_id': 'waiting',
    };
    rideRef.set(rideMap);
  }

  void cancelRequest() {
    rideRef.remove();
  }

  resetApp() {
    setState(() {
      polyLineCoordinates.clear();
      _polylines.clear();
      _Markers.clear();
      _Circles.clear();
      rideDetailsSheetHeight = 0;
      requestSheetHeight = 0;
      searchSheetHeight = screenHeight * 0.32;
      mapBottomPadding = screenHeight * 0.31;
      drawerCanOpen = true;
    });

    setupPositionLocator();
  }
}
