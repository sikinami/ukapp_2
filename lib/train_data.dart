import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'data_util.dart';

class TrainData {
  final DateTime time;
  final TrainName name;
  final String service;
  final String destination;

  TrainData(this.time, this.name, this.service, this.destination);
}

class TrainDataList {
  final List<TrainData> _kudariList = [];
  final List<TrainData> _noboriList = [];

  TrainDataList() {
    Future<File> kudariFile;
    Future<File> noboriFile;
    if (DateTime.now().weekday == DateTime.sunday) {
    } else if (DateTime.now().weekday == DateTime.saturday) {
    } else {}
    kudariFile = DataUtil.getFileFromAssets("h-u.csv");
    noboriFile = DataUtil.getFileFromAssets("h-t.csv");
    _TrainDataFormat dataFormat = _TrainDataFormat();

    kudariFile.then((value) {
      value.readAsLines().then((texts) {
        for (String text in texts) {
          List<String> list = text.split(',');
          if (list.isNotEmpty) {
            _kudariList.add(dataFormat.formatData(list));
          }
        }
      });
    });

    noboriFile.then((value) {
      value.readAsLines().then((texts) {
        for (String text in texts) {
          List<String> list = text.split(',');
          if (list.isNotEmpty) {
            _noboriList.add(dataFormat.formatData(list));
          }
        }
      });
    });
  }

  List<TrainData> getData(int num, bool isNobori) {
    List<TrainData> result = [];
    List<TrainData> array = isNobori ? _noboriList : _kudariList;
    int index = 0;
    for (TrainData data in array) {
      if (data.time.isAfter(kDebugMode
          ? DateTime(2022, 6, 21, 3, 0)
          : DateTime.now().add(const Duration(minutes: 3)))) {
        for (int a = 0; a < num; a++) {
          if (a + index < array.length) {
            result.add(array[a + index]);
          } else {
            break;
          }
        }
        break;
      }
      index++;
    }

    return result;
  }

  static String getTrainName(TrainName trainName) {
    switch (trainName) {
      case TrainName.shonanShinjukuLine:
        return "湘南新宿ライン";
      case TrainName.uenoTokyoLine:
        return "上野東京ライン";
      case TrainName.utsunomiyaLine:
        return "宇都宮線";
      case TrainName.nikkoLine:
        return "日光線";
      case TrainName.ryomoLine:
        return "両毛線";
      case TrainName.mitoLine:
        return "水戸線";
    }
  }
}

enum TrainName {
  shonanShinjukuLine,
  uenoTokyoLine,
  utsunomiyaLine,
  nikkoLine,
  ryomoLine,
  mitoLine
}

class _TrainDataFormat {
  TrainData formatData(List<String> csvLine) {
    TrainName trainName = TrainName.utsunomiyaLine;
    String trainService = "普通";
    String destination = "上野";
    DateFormat format = DateFormat("yyyy/MM/dd HH:mm");

    if (csvLine.length == 1 || csvLine[1] == "") {
      trainName = TrainName.utsunomiyaLine;
      trainService = "普通";
      destination = "宇都宮";
    } else if (csvLine.length > 1 && csvLine[1] != "快") {
      switch (csvLine[1]) {
        case "熱":
          trainName = TrainName.uenoTokyoLine;
          trainService = "普通";
          destination = "熱海";
          break;

        case "船":
          trainName = TrainName.shonanShinjukuLine;
          trainService = "普通";
          destination = "大船";
          break;

        case "上":
          trainName = TrainName.utsunomiyaLine;
          trainService = "普通";
          destination = "上野";
          break;

        case "田":
          trainName = TrainName.uenoTokyoLine;
          trainService = "普通";
          destination = "小田原";
          break;

        case "品":
          trainName = TrainName.uenoTokyoLine;
          trainService = "普通";
          destination = "品川";
          break;

        case "平":
          trainName = TrainName.uenoTokyoLine;
          trainService = "普通";
          destination = "平塚";
          break;

        case "逗":
          trainName = TrainName.shonanShinjukuLine;
          trainService = "普通";
          destination = "逗子";
          break;

        case "国":
          trainName = TrainName.uenoTokyoLine;
          trainService = "普通";
          destination = "国府津";
          break;

        case "伊":
          trainName = TrainName.uenoTokyoLine;
          trainService = "普通";
          destination = "伊東";
          break;

        case "黒":
          trainName = TrainName.utsunomiyaLine;
          trainService = "普通";
          destination = "黒磯";
          break;

        case "光":
          trainName = TrainName.nikkoLine;
          trainService = "普通";
          destination = "日光";
          break;

        case "宮":
          trainName = TrainName.utsunomiyaLine;
          trainService = "普通";
          destination = "大宮";
      }
    } else {
      switch (csvLine[2]) {
        case "逗":
          trainName = TrainName.shonanShinjukuLine;
          trainService = "快速";
          destination = "逗子";
          break;
        case "上":
          trainName = TrainName.utsunomiyaLine;
          trainService = "快速ラビット";
          destination = "上野";
          break;
        case "宇":
          trainName = TrainName.utsunomiyaLine;
          trainService = "快速";
          destination = "宇都宮";
      }
    }
    DateTime nowTime = kDebugMode ? DateTime(2022, 6, 21) : DateTime.now();
    DateTime time = format.parseStrict("${nowTime.year}/${nowTime.month}/${nowTime.day} ${csvLine[0]}");

    if (time.hour < 1) {
      time.add(const Duration(days: 1));
    }
    return TrainData(time, trainName, trainService, destination);
  }
}
