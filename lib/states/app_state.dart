import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone/resquests/google_maps_services.dart';
import 'package:uber_clone/shared/colors.dart';

class AppState with ChangeNotifier {

  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  bool locationServiceActive = true;

  //set marker on map
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  GoogleMapController  _mapController;

  //get
  Set<Marker> get markers => _markers;
  Set<Polyline> get polyline => _polylines;
  LatLng get initialPosition => _initialPosition;
  LatLng get lastPosition => _lastPosition;
  GoogleMapsServices get googleMapsServices => _googleMapsServices;
  GoogleMapController get mapController => _mapController;


  AppState() {
    _getUserLocation();
    _loadingInitialPosition();
  }
  

  void _getUserLocation() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
      _initialPosition = LatLng(position.latitude, position.longitude);
      locationController.text = placeMark[0].name;
      notifyListeners();
  }

  //Covert double to LatLng: create LatLng list
  List<LatLng> _convertToLatLng(List points) {
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

  //to create route
  void createRoute(String encodedPoly) {
      _polylines.add(
        Polyline(
          polylineId: PolylineId(_lastPosition.toString()),
          points: _convertToLatLng(_decodePoly(encodedPoly)),
          width: 10,
          color: darkBlue,
        )
      );
      notifyListeners();
  }

  //Add marker on the Map
  void _addMarker(LatLng location, String adresse) {
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
      notifyListeners();
  }

  // decode polyline
  List _decodePoly(String poly) {
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
        result = ~result;
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


  // Send request
  void sendRequest(String indendedLocation) async {
    List<Placemark> placemark = await Geolocator().placemarkFromAddress(indendedLocation);
    double latitude = placemark[0].position.latitude;
    double longitude = placemark[0].position.longitude;

    LatLng destination = LatLng(latitude, longitude);

    _addMarker(destination, indendedLocation);
    String route = await googleMapsServices.getRouteCoordinates(_initialPosition, destination);
    createRoute(route);
    notifyListeners();
  }

  //On camera move
    void onCameraMove(CameraPosition position) {
      _lastPosition = position.target;
      notifyListeners();
  }

  //on create
  void onCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  //loading initial position
  void _loadingInitialPosition() async {
    await Future.delayed(Duration(seconds: 3)).then((v) {
        if (_initialPosition == null) {
          locationServiceActive = false;
          notifyListeners();
        }
      });
  }

}