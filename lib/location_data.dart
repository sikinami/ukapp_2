import 'package:latlong2/latlong.dart';

class LocationData {
  LatLng location;
  int floor;
  String? locationName;
  String? explanation;
  String? youtubeID;

  LocationData({
    required this.location,
  required this.floor,
  this.locationName,
  this.explanation,
    this.youtubeID});

  void setFloor(int floor) {
    this.floor = floor;
  }

  void setLocation(LatLng location) {
    this.location = location;
  }
}
