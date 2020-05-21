import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/states/app_state.dart';
import 'package:uber_clone/utils/api.dart';
import '../shared/colors.dart';

class Map extends StatefulWidget {
  Map({Key key}) : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final appState = Provider.of<AppState>(context);

    // (appState.initialPosition == null) 
    

    return SafeArea(
      child: (appState.initialPosition == null) 
      ? Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
              ],
            ),
            SizedBox(height: 40.0),
              Visibility(
                visible: appState.locationServiceActive = false,
                child: Text(
                  'Check if your location services are enabled !',
                  style: TextStyle(
                    color: Colors.black,
                    // fontSize: 18.0
                  ),
                ),
              )
          ],
        ),
      )
      : Stack(
        children: <Widget>[
          GoogleMap( //google_maps_flutter
            initialCameraPosition: CameraPosition(
              target: appState.initialPosition,
              zoom: 10,
            ),
            onMapCreated: appState.onCreated,
            myLocationEnabled: true,
            mapType: MapType.normal,
            compassEnabled: true,
            markers: appState.markers,
            onCameraMove: appState.onCameraMove,
            polylines: appState.polyline,
          ),

          new Positioned(
            top: 50.0,
            right: 15.0,
            left: 15.0,
            child: new Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: white,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(1.0, 5.0),
                    color: grey,
                    blurRadius: 10.0,
                    spreadRadius: 3
                  ),
                ]
              ),
              
              child: TextField(
                cursorColor: darkBlue,
                controller: appState.locationController,
                decoration: InputDecoration(
                  hintText: 'Pick up',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                  prefixIcon: Icon(Icons.location_on, color: darkBlue,)
                ),
              ),
            ),
          ),

          new Positioned(
            top: 105.0,
            right: 15.0,
            left: 15.0,
            child: new Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: white,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(1.0, 5.0),
                    color: grey,
                    blurRadius: 10.0,
                    spreadRadius: 3
                  ),
                ]
              ),
              
              child: TextField(
                onTap: () async {
                  Prediction p = await PlacesAutocomplete.show(
                    context: context,
                    apiKey: apiKey,
                    overlayBorderRadius: BorderRadius.circular(12.0),
                    language: 'fr',
                    components: [
                      new Component(Component.country, 'ci')
                    ]
                  );
                },
                cursorColor: darkBlue,
                controller: appState.destinationController,
                textInputAction: TextInputAction.go,
                onSubmitted: (value) {
                  appState.sendRequest(value);
                },
                decoration: InputDecoration(
                  hintText: 'Destination',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                  prefixIcon: Icon(Icons.local_taxi, color: darkBlue,)
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}