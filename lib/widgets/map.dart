import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../resquests/google_maps_services.dart';
import '../shared/colors.dart';

class Map extends StatefulWidget {
  Map({Key key}) : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {

  static LatLng _initialPosition ;
  LatLng _lastPosition = _initialPosition;

  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  GoogleMapController mapController;
  GoogleMapsServices _googleMapsService = GoogleMapsServices();

  //set marker on map
  final Set<Marker> _markers = {};

  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    _getUserLocation();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: (_initialPosition == null) 
        ? Container(
          alignment: Alignment.center,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ) 
        : Stack(
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
              polylines: _polylines,
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
                  controller: locationController,
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
                  controller: destinationController,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (value) {
                    sendRequest(value);
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

            // Positioned(
            //   top: 80,
            //   right: 20,
            //   child: FloatingActionButton(
            //     onPressed: _addMarker,
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

  void _addMarker(LatLng location, String adresse) {
    print('FAB pressed');
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(
            _lastPosition.toString()
          ),
          position: location,
          infoWindow: InfoWindow(
            title: adresse,
            snippet: 'Go here'
          ),
          icon: BitmapDescriptor.defaultMarker
        )
      );
    });
  }

  void createRoute(String encodedPoly) {
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId(_lastPosition.toString()),
          points: convertToLatLng(decodePoly(encodedPoly)),
          width: 10,
          color: darkBlue,
        )
      );
    });
  }


  //user Location 
  void _getUserLocation() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      locationController.text = placeMark[0].name;
    });
  }

  void sendRequest(String indendedLocation) async {
    List<Placemark> placemark = await Geolocator().placemarkFromAddress(indendedLocation);
    double latitude = placemark[0].position.latitude;
    double longitude = placemark[0].position.longitude;

    LatLng destination = LatLng(latitude, longitude);

    _addMarker(destination, indendedLocation);
    String route = await _googleMapsService.getRouteCoordinates(_initialPosition, destination);
    createRoute(route);

  }


  // decode polyline
  List decodePoly(String poly) {
    //decode string
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;

    //répéter jusqu'à ce que tous les attributs soient décodés
    do {
      var shift = 0;
      int result = 0;

      //for decoding value of one attribute
      do {
        c = list[index]-63;
        result |= (c & 0x1F) << (shift*5);
        index++;
        shift++;
      } while(c >= 32);

      //if value is negative then bitwise not the value
      if (result & 1==1) {
        result =~ result;
      }

      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);

    } while(index < len);

    //adding to previous value as done in encoding
    for(var i=2; i<lList.length; i++) {
      lList[i]+= lList[i-2];
    }

    print(lList.toString());
    return lList;
  }

  //Covert double to LatLng
  List<LatLng> convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];

    for (var i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(
          LatLng(points[i-1], points[i])
        );
      }
    }
    return result;
  }

}