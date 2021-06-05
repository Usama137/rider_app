//import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:riderapp/dataModels/prediction.dart';
import 'package:riderapp/dataProvider/appData.dart';
import 'package:riderapp/globalVariables.dart';
import 'package:riderapp/helpers/requestHelper.dart';
import 'package:riderapp/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:riderapp/widgets/brandDivider.dart';
import 'package:riderapp/widgets/predictionTile.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  var pickUpController = TextEditingController();
  var destController = TextEditingController();
  var focusDest = FocusNode();

  bool focused = false;
  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDest);
      focused = true;
    }
  }

  List<Prediction> destinationPredictionList = [];

  void searchPlace(String placeName) async {
    if (placeName.length > 1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=123254251&components=country:us|country:pk';
      var response = await RequestHelper.getRequest(url);
      if (response == 'failed') {
        return;
      }

      if (response['status'] == 'OK') {
        var predictionJson = response['predictions'];
        var thisList = (predictionJson as List)
            .map((e) => Prediction.fromJson(e))
            .toList();
        setState(() {
          destinationPredictionList = thisList;
        });
        print(response);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    setFocus();

    String address = Provider.of<AppData>(context).pickupAddress?.placeName;
    pickUpController.text = address;

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: displayHeight(context) * 0.25,
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
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
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 40, bottom: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        child: Icon(Icons.arrow_back),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      Center(
                        child: Text(
                          "Set Destination",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'images/pickIcon.png',
                        height: 20,
                        width: 20,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TextField(
                              controller: pickUpController,
                              decoration: InputDecoration(
                                  hintText: 'Pickup Location',
                                  fillColor: Colors.grey.shade200,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 10, top: 8, bottom: 8)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'images/destIcon.png',
                        height: 20,
                        width: 20,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TextField(
                              onChanged: (value) {
                                searchPlace(value);
                              },
                              focusNode: focusDest,
                              controller: destController,
                              decoration: InputDecoration(
                                  hintText: 'Destination',
                                  fillColor: Colors.grey.shade200,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 10, top: 8, bottom: 8)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          (destinationPredictionList.length > 0)
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListView.separated(
                    padding: EdgeInsets.all(0),
                    itemBuilder: (context, index) {
                      return PredictionTile(
                        prediction: destinationPredictionList[index],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        BrandDivider(),
                    itemCount: destinationPredictionList.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
