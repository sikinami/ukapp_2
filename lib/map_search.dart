import 'package:flutter/material.dart';
import 'package:ukapp/classrooms.dart';
import 'package:ukapp/location_data.dart';

class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  List result = [];
  ClassRooms rooms = ClassRooms();

  void setText(List text) {
    setState(() {
      result = text;
    });
  }

  @override
  void initState() {
    super.initState();
    rooms.init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    result = rooms.contains("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AppBar(
              title: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                    hintText: "ここで教室を検索",
                  ),
                  onChanged: (text) => setText(rooms.contains(text)),
                ),
              ),
            )),
        body: Scrollbar(
            child: ListView.builder(
          itemCount: result.length,
          itemBuilder: (context, index) {
            return SizedBox(
              height: 59,
              width: double.infinity,
              child: ListTile(
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(result[index]),
                      const Icon(
                        Icons.north_west_rounded,
                        size: 25,
                      )
                    ]),
                subtitle: Container(
                  decoration:
                      const BoxDecoration(border: Border(bottom: BorderSide())),
                  child: Text(rooms
                      .suggestionList[rooms.kanjiList.indexOf(result[index])]),
                ),
                onTap: () => {
                  Navigator.pop(
                    context,
                    LocationData(
                        location: rooms.getLocation(result[index]),
                        floor: rooms
                            .floorList[rooms.kanjiList.indexOf(result[index])],
                        locationName: result[index],
                        explanation: rooms.setumeiList[
                            rooms.kanjiList.indexOf(result[index])],
                        youtubeID: rooms.urlList[
                            rooms.kanjiList.indexOf(result[index])]), //追加分1110
                  )
                },
                leading: const Icon(Icons.location_pin),
              ),
            );
          },
        )));
  }
}
