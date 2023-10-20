import 'dart:io';

import 'package:latlong2/latlong.dart';
import 'package:ukapp/data_util.dart';

class ClassRooms {
  List<String> kanjiList = [];
  List<String> hiraganaList = [];
  List<String> suggestionList = [];
  List<double> xList = [];
  List<double> yList = [];
  List<int> floorList = [];
  List<String> setumeiList = []; //追加分
  void init() {
    Future<File> file = DataUtil.getFileFromAssets("classRoom.csv");

    file.then((value) {
      value.readAsLines().then((texts) {
        for (String text in texts) {
          List<String> list = text.split(',');
          kanjiList.add(list[0]);
          hiraganaList.add(list[1]);
          suggestionList.add(list[2]);
          xList.add(double.parse(list[3]));
          yList.add(double.parse(list[4]));
          floorList.add(int.parse(list[5]));
          setumeiList.add(list[6]); //追加分
        }
      });
    });
  }

  List contains(String text) {
    List result = [];
    for (String value in kanjiList) {
      if (value.contains(text.toUpperCase())) {
        result.add(value);
      }
    }

    for (var value in hiraganaList) {
      if (value.contains(text)) {
        if (!result.contains(kanjiList[hiraganaList.indexOf(value)])) {
          result.add(kanjiList[hiraganaList.indexOf(value)]);
        }
      }
    }
    return result;
  }

  LatLng getLocation(String roomName) {
    return LatLng(
        xList[kanjiList.indexOf(roomName)], yList[kanjiList.indexOf(roomName)]);
  }
}
