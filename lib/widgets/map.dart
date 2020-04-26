import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone/shared/colors.dart';

class Map extends StatefulWidget {
  Map({Key key}) : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {

  GoogleMapController mapController;
  static const _initialPosition = LatLng(5.359952, -4.008256);
  LatLng _lastPosition = _initialPosition;

  //set marker on map
  final Set<Marker> _markers = {
    
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Stack(
          children: <Widget>[
            GoogleMap( //google_maps_flutter
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.4746,
              ),
              onMapCreated: onCreated,
              myLocationEnabled: true,
              mapType: MapType.normal,
              compassEnabled: true,
              markers: _markers,
              onCameraMove: onCameraMove,
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
                  // controller: ,
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
                  cursorColor: darkBlue,
                  // controller: ,
                  decoration: InputDecoration(
                    hintText: 'Destination',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                    prefixIcon: Icon(Icons.local_taxi, color: darkBlue,)
                  ),
                ),
              ),
            )

            // Positioned(
            //   top: 80,
            //   right: 20,
            //   child: FloatingActionButton(
            //     onPressed: _onAddMarkerPressed,
            //     tooltip: 'add marker',
            //     backgroundColor: darkBlue,
            //     child: Icon(Icons.add_location, color: white,),

            //   ),
            // )
          ],
        )
      ),
    );
  }

  void onCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void onCameraMove(CameraPosition position) {
    setState(() {
      _lastPosition = position.target;
    });
  }

  void _onAddMarkerPressed() {
    print('FAB pressed');
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(
            _lastPosition.toString()
          ),
          position: _lastPosition,
          infoWindow: InfoWindow(
            title: 'we are here',
            snippet: 'Good Place'
          ),
          icon: BitmapDescriptor.defaultMarker
        )
      );
    });
  }
}