import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uber_clone/utils/api.dart';

// const apiKey = '';
class GoogleMapsServices {

  Future<String> getRouteCoordinates(LatLng l1, LatLng l2) async {
    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude}, ${l1.longitude}&destination=${l2.latitude}, ${l2.longitude}&key=$apiKey';
    http.Response response = await http.get(url);

    Map values = json.decode(response.body);
    return values['routes'][0]['overview_polyline']['points'];
  }
}




// void sendRequest(String indendedLocation) async {
  //   List<Placemark> placeMark = await Geolocator().placemarkFromAddress(indendedLocation);
  //   double latitude = placeMark[0].position.latitude;
  //   double longitude = placeMark[0].position.longitude;
  //   LatLng destination = LatLng(latitude, longitude); 
  // }