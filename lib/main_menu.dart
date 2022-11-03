import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:ukapp/map_screen.dart';
import 'package:ukapp/time_table.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  Map<String, Widget> hashMap = HashMap();

  @override
  void initState() {
    super.initState();
    hashMap["map"] = const MapScreen(title: "mapScreen");
    hashMap["timeTable"] = const TimeTableScreen(title: "TimeTable");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MENU"),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MapScreen(title: "mapScreen"))),
                child: Card(
                  child: SizedBox(
                    width: 180,
                    height: 180,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.map,
                          size: 60,
                        ),
                        Text(
                          "校内マップ",
                          style: TextStyle(fontSize: 30),
                        ),
                        Text("学校内の地図を表示します。",style: TextStyle(fontSize: 13,color: Colors.white70),)
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const TimeTableScreen(title: "mapScreen"))),
                child: Card(
                  child: SizedBox(
                    width: 180,
                    height: 180,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.train,
                          size: 60,
                        ),
                        Text(
                          "時刻表",
                          style: TextStyle(fontSize: 30),
                        ),
                        Text("雀宮駅からの各方面の時刻表を表示します。",style: TextStyle(fontSize: 13,color: Colors.white70),)
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
