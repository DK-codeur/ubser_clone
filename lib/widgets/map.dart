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

            Positioned(
              top: 80,
              right: 20,
              child: FloatingActionButton(
                onPressed: _onAddMarkerPressed,
                tooltip: 'add marker',
                backgroundColor: darkBlue,
                child: Icon(Icons.add_location, color: white,),

              ),
            )
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