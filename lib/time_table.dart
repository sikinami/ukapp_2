import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ukapp/TrainData.dart';
import 'package:intl/intl.dart';



class TimeTableScreen extends StatefulWidget {
  const TimeTableScreen({Key? key, required String title}) : super(key: key);
  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen>
    with TickerProviderStateMixin {
  late TabController _bottomController;
  final DateFormat _timeFormat = DateFormat("HH:mm:ss");
  final DateFormat _hourMinutes = DateFormat("HH:mm");
  late String _timeString;
  late Timer _timer;
  final TrainDataList _dataList = TrainDataList();

  @override
  void initState() {
    super.initState();
    _timeString = _timeFormat.format(DateTime.now());
    _bottomController = TabController(length: 2, vsync: this);
    _timer = Timer.periodic(const Duration(seconds: 1), adderTime);
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _bottomController.dispose();
  }

  void adderTime(Timer timer) {
    setState(() => {_timeString = _timeFormat.format(DateTime.now())});
  }

  @override
  Widget build(BuildContext context) {
    List<TrainData> noboriList = _dataList.getData(5, true);
    List<TrainData> kudariList = _dataList.getData(5, false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("時刻表"),
        leading: const BackButton(),
      ),
      endDrawer: SizedBox(
          width: 350,
          child: SafeArea(
              child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30)),
                  child: Drawer(
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Container(
                          height: 70,
                          child: const Align(child: Text("列車選択")),
                          decoration:
                              const BoxDecoration(color: Colors.black12),
                        ),
                        const SizedBox(
                          height: 70,
                          child: Card(
                              child: ListTile(
                                  leading: Icon(Icons.train_rounded),
                                  title: Text("湘南新宿ライン・上野東京ライン"))),
                        ),
                        const SizedBox(
                          height: 70,
                          child: Card(
                              child: ListTile(
                                  leading: Icon(Icons.train_rounded),
                                  title: Text("宇都宮線（矢板・黒磯方面）"))),
                        ),
                        const SizedBox(
                          height: 70,
                          child: Card(
                              child: ListTile(
                                  leading: Icon(Icons.train_rounded),
                                  title: Text("日光線"))),
                        ),
                        const SizedBox(
                          height: 70,
                          child: Card(
                              child: ListTile(
                                  leading: Icon(Icons.train_rounded),
                                  title: Text("烏山線"))),
                        ),
                        const SizedBox(
                          height: 70,
                          child: Card(
                              child: ListTile(
                                  leading: Icon(Icons.train_rounded),
                                  title: Text("両毛線"))),
                        ),
                        const SizedBox(
                          height: 70,
                          child: Card(
                              child: ListTile(
                                  leading: Icon(Icons.train_rounded),
                                  title: Text("水戸線"))),
                        ),
                      ],
                    ),
                  )))),
      bottomNavigationBar: BottomAppBar(
        child: TabBar(
          controller: _bottomController,
          tabs: const [
            Tab(
              text: "宇都宮方面",
              icon: Icon(
                Icons.train_rounded,
                color: Colors.lightGreen,
              ),
            ),
            Tab(
                text: "石橋・小山方面",
                icon: Icon(Icons.train_rounded, color: Colors.orange)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _bottomController,
        children: [
          Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.only(right: 18, left: 18, top: 10),
                child: const Icon(
                  Icons.schedule_outlined,
                  size: 70,
                ),
              ),
              Column(
                children: [
                  Container(
                      margin: const EdgeInsets.only(bottom: 10, top: 30),
                      child: const Text("現在の時刻 ",
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.w900))),
                  Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Text(_timeString,
                          style: const TextStyle(fontSize: 40))),
                ],
              ),
            ]),
            const Align(
              alignment: Alignment.topRight,
              child: Text(
                "※3分後の電車を表示しています。",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            kudariList.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: kudariList.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return SizedBox(
                            width: double.infinity,
                            height: 110,
                            child: Card(
                                child: ListTile(
                                    title: Row(children: [
                                      Text(
                                        _hourMinutes.format(kudariList[0].time),
                                        style: const TextStyle(fontSize: 45),
                                      ),
                                      const Image(
                                        image:
                                            AssetImage("assets/images/JU.png"),
                                        width: 60,
                                        height: 45,
                                      )
                                    ]),
                                    subtitle: Text(TrainDataList.getTrainName(
                                            kudariList[0].name) +
                                        " " +
                                        kudariList[0].destination +
                                        "行"),
                                    leading: const Icon(
                                      Icons.train_rounded,
                                      size: 40,
                                    ))));
                      }
                      return Card(
                          child: ListTile(
                              title: Row(
                                children: [
                                  Text(
                                    _hourMinutes.format(kudariList[index].time),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      child: const Image(
                                        image:
                                            AssetImage("assets/images/JU.png"),
                                        width: 35,
                                        height: 30,
                                      ))
                                ],
                              ),
                              subtitle: Text(TrainDataList.getTrainName(
                                      kudariList[index].name) +
                                  " " +
                                  kudariList[index].destination +
                                  "行"),
                              leading: const Icon(Icons.train_rounded)));
                    })
                : const Center(
                    child: Text("読込中..."),
                  ),
          ]),
          Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.only(right: 18, left: 18, top: 10),
                child: const Icon(
                  Icons.schedule_outlined,
                  size: 70,
                ),
              ),
              Column(
                children: [
                  Container(
                      margin: const EdgeInsets.only(bottom: 10, top: 30),
                      child: const Text("現在の時刻 ",
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.w900))),
                  Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Text(_timeString,
                          style: const TextStyle(fontSize: 40))),
                ],
              ),
            ]),
            const Align(
              alignment: Alignment.topRight,
              child: Text(
                "※3分後の電車を表示しています。",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            noboriList.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: noboriList.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return SizedBox(
                            width: double.infinity,
                            height: 110,
                            child: Card(
                                child: ListTile(
                                    title: Row(children: [
                                      Text(
                                        _hourMinutes.format(noboriList[0].time),
                                        style: const TextStyle(fontSize: 45),
                                      ),
                                      const Image(
                                        image:
                                            AssetImage("assets/images/JU.png"),
                                        width: 60,
                                        height: 45,
                                      )
                                    ]),
                                    subtitle: Text(TrainDataList.getTrainName(
                                            noboriList[0].name) +
                                        " " + noboriList[index].service + " " +
                                        noboriList[0].destination +
                                        "行"),
                                    leading: const Icon(
                                      Icons.train_rounded,
                                      size: 40,
                                    ))));
                      }

                      return Card(
                          child: ListTile(
                        title: Row(
                          children: [
                            Text(
                              _hourMinutes.format(noboriList[index].time),
                            ),
                            Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: Image(
                                  image: AssetImage(noboriList[index].name ==
                                          TrainName.shonanShinjukuLine
                                      ? "assets/images/JS.png"
                                      : "assets/images/JU.png"),
                                  width: 35,
                                  height: 30,
                                ))
                          ],
                        ),
                        subtitle: Text(
                            TrainDataList.getTrainName(noboriList[index].name) +
                                " " + noboriList[index].service + " " +
                                noboriList[index].destination +
                                "行"),
                        leading: const Icon(Icons.train_rounded),
                      ));
                    })
                : const Center(
                    child: Text("読込中..."),
                  ),
          ]),
        ],
      ),
    );
  }
}
