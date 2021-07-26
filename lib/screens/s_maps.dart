import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../secrets.dart';
import 'package:techsupport/widgets/w_mapbox_search.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/services/base.dart';

import 'package:techsupport/utils/u_color.dart';

import 'package:techsupport/widgets/w_text.dart';

import 'package:techsupport/models/m_customer.dart';

class MyMaps extends StatefulWidget {
  final Customer cust;
  const MyMaps({Key key, this.cust}) : super(key: key);
  @override
  _MyMapsState createState() => _MyMapsState();
}

class _MyMapsState extends State<MyMaps> {
  TextEditingController _place = TextEditingController();

  MapType _currentMapType = MapType.normal;

  LatLng myLocation;
  Timer _timer;
  final Map<String, Marker> _marker = {};

  void getCurrentLocation() async {
    var currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    getTabLocation(LatLng(currentLocation.latitude, currentLocation.longitude));
  }

  void getTabLocation(LatLng _latLng) async {
    _marker.clear();
    var address = await Geocoder.local.findAddressesFromCoordinates(
        new Coordinates(_latLng.latitude, _latLng.longitude));
    _place.text = address.first.addressLine;

    setState(() {
      final myMarker = Marker(
          markerId: MarkerId("loc"),
          position: LatLng(_latLng.latitude, _latLng.longitude),
          infoWindow: InfoWindow(
            title: address.first.featureName,
          ));
      _marker["Current Location"] = myMarker;
      myLocation = LatLng(_latLng.latitude, _latLng.longitude);
    });

    _mapController.moveCamera(CameraUpdate.newLatLng(myLocation));
  }

  void periodicMethod() async {
    _timer = Timer.periodic(Duration(seconds: 2), (test) async {
      if (this.mounted) {
        setState(() {
          getCurrentLocation();
          print("Get Location Ke ${test.tick}");
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.cust != null) {
      List<String> gps = widget.cust.customerGps.split("|");
      if (widget.cust.customerGps != "") {
        getTabLocation(LatLng(double.parse(gps[0]), double.parse(gps[1])));
      } else if (widget.cust.customerGps == "") {
        getCurrentLocation();
      }
    } else {
      getCurrentLocation();
    }

    // periodicMethod();
  }

  @override
  void dispose() {
    super.dispose();
    //  _timer.cancel();
    //   periodicMethod();
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onCameraMove(CameraPosition position) {
    myLocation = position.target;
  }

  GoogleMapController _mapController;

  void _onMapCreated(GoogleMapController controller) {
    //_controller.complete(controller);

    _mapController = controller;
    _mapController.moveCamera(CameraUpdate.newLatLng(myLocation));
  }

  Widget getLocationWithMapBox() {
    return MapBoxPlaceSearchWidget(
      popOnSelect: true,
      apiKey: Secrets.MAPBOX_API_KEY,
      searchHint: 'Search around',
      onSelected: (place) {
        // setState(() {
        //   _pickedLocationText = place.geometry.coordinates;
        getTabLocation(LatLng(
            place.geometry.coordinates.last, place.geometry.coordinates.first));
        //   print(myLocation);
        // });
      },
      country: "ID",
      context: context,
    );
  }

  void _sendCustomer(BuildContext context) {
    List<String> gmap = new List<String>();
    gmap.add(
        myLocation.latitude.toString() + "|" + myLocation.longitude.toString());
    gmap.add(_place.text);
    Navigator.pop(context, gmap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   brightness: Theme.of(context).brightness,
        //   backgroundColor: MColors.backgroundColor(context),
        //   elevation: 2,
        //   title:
        //        Text(
        //         _place.text,
        //         style: CText.primarycustomText(2.5, context, "CircularStdBold"),
        //       ),

        //   actions: [
        //     IconButton(
        //         icon: Icon(Icons.search),
        //         onPressed: () {
        //           showDialog(
        //             context: context,
        //             builder: (BuildContext context) {
        //               return Scaffold(
        //                   backgroundColor: Colors.transparent,
        //                   body: MapBoxPlaceSearchWidget(
        //                     // fontSize: "16",
        //                     // height: 50.0,
        //                     popOnSelect: true,
        //                     apiKey: Secrets.MAPBOX_API_KEY,
        //                     searchHint: 'Cari Lokasi...',
        //                     onSelected: (place) {
        //                       getTabLocation(LatLng(
        //                           place.geometry.coordinates.last,
        //                           place.geometry.coordinates.first));
        //                     },
        //                     country: "ID",
        //                     context: context,
        //                   ));
        //             },
        //           );
        //         })
        //   ],
        // ),
        body: SafeArea(
      child: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            onTap: (latlang) {
              //if (_marker.length >= 1) {
              //      _marker.clear();
              //   }
              getTabLocation(latlang);
            },
            initialCameraPosition:
                CameraPosition(target: myLocation, zoom: 18.0),
            mapType: _currentMapType,
            //   onCameraMove: _onCameraMove,
            markers: _marker.values.toSet(),
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
              Factory<OneSequenceGestureRecognizer>(
                () => ScaleGestureRecognizer(),
              )
            ].toSet(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100.0, right: 16),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: _onMapTypeButtonPressed,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: MColors.buttonColor(),
                    child: const Icon(Icons.map, size: 36.0),
                  ),
                  SizedBox(height: 16.0),
                  FloatingActionButton(
                    onPressed: () => getCurrentLocation(),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: MColors.buttonColor(),
                    child: const Icon(Icons.gps_fixed, size: 36.0),
                  ),
                  SizedBox(height: 16.0),
                  FloatingActionButton(
                    onPressed: () => _sendCustomer(context),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: MColors.buttonColor(),
                    child: const Icon(Icons.save, size: 36.0),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 15.0,
            left: 10.0,
            right: 60.0,
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: <Widget>[
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: Text(
                  //     "New York",
                  //     style: TextStyle(
                  //       fontSize: 20.0,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_place.text),
                  )
                ],
              ),
            ),
          ),
          MapBoxPlaceSearchWidget(
            //    fontSize: "16",
            //   height: 50.0,
            popOnSelect: true,
            apiKey: Secrets.MAPBOX_API_KEY,
            searchHint: 'Cari Lokasi...',
            onSelected: (place) {
              getTabLocation(LatLng(place.geometry.coordinates.last,
                  place.geometry.coordinates.first));
            },
            country: "ID",
            context: context,
          ),
        ],
      ),
    ));
  }
}
