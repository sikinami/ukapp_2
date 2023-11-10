import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:ukapp/location_data.dart';
import 'package:ukapp/map_search.dart';
import 'package:ukapp/qr_code.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late TabController tabController;
  final LocationData _locationData = LocationData(
    location: LatLng(0, 0),
    floor: 0,
  );
  bool _actionButtonVisible = false;
  Future<bool> data = Future<bool>.delayed(
      const Duration(seconds: 1, milliseconds: 500), () => true);

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    for (int a = 1; a < 4; a++) {
      int seconds = a * 200;
      Future.delayed(
          Duration(milliseconds: seconds), () => tabController.animateTo(a));
    }
    Future.delayed(const Duration(milliseconds: 800), () {
      tabController.animateTo(0);
    });
  }

  void setActionButtonVisible(bool visible) {
    setState(() {
      _actionButtonVisible = visible;
    });
  }

  void setLocation(LocationData locationData) {
    setState(() {
      _locationData.setLocation(locationData.location);
      _locationData.setFloor(locationData.floor);
      _locationData.locationName = locationData.locationName;
      _locationData.explanation = locationData.explanation;
      _locationData.youtubeID = locationData.youtubeID;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = Scaffold(
        appBar: AppBar(
          elevation: 2,
          title: const Text("校内マップ"),
        ),
        extendBodyBehindAppBar: true,
        floatingActionButton: Column(
            verticalDirection: VerticalDirection.up,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: FloatingActionButton(
                    heroTag: "hero2",
                    onPressed: () async {
                      if (_actionButtonVisible == false) {
                        String? uuid = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const QRViewExample()));

                        if (uuid != null) {
                          if (kDebugMode) {
                            print(uuid);
                          }
                        }
                      }
                    },
                    child: const Icon(Icons.my_location),
                  )),
              Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: FloatingActionButton(
                      heroTag: "hero1",
                      onPressed: () async {
                        if (_actionButtonVisible == false) {
                          LocationData? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const MapSearchScreen(title: "search")));
                          if (result != null) {
                            setLocation(result);
                            tabController.animateTo(result.floor - 1);
                          }
                        }
                      },
                      child: const Icon(Icons.search)))
            ]),
        bottomNavigationBar: BottomAppBar(
          child: TabBar(
            labelColor: Colors.white,
            controller: tabController,
            tabs: const [
              Tab(text: "1F"),
              Tab(text: "2F"),
              Tab(text: "3F"),
              Tab(text: "全体配置図"),
            ],
          ),
        ),
        body: TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              FloorMap(
                floor: 1,
                locationData: _locationData,
              ),
              FloorMap(
                floor: 2,
                locationData: _locationData,
              ),
              FloorMap(
                floor: 3,
                locationData: _locationData,
              ),
              FloorMap(floor: 0, locationData: _locationData),
            ]));

    return FutureBuilder(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return screen;
          } else {
            return Scaffold(
                body: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                  SizedBox(
                    child: CircularProgressIndicator(),
                    height: 80.0,
                    width: 80.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "読み込み中...",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ])));
          }
        });
  }
}

class FloorMap extends StatefulWidget {
  const FloorMap(
      {Key? key,
      required this.floor,
      required this.locationData,
      this.controller})
      : super(key: key);

  final int floor;
  final LocationData locationData;
  final MapController? controller;

  @override
  _FloorMap createState() => _FloorMap();
}

class _FloorMap extends State<FloorMap>
    with AutomaticKeepAliveClientMixin<FloorMap>, TickerProviderStateMixin {
  String id = "Tm5q8WUkI8A";
  bool isPanelHide = true;
  late int floor;
  late LocationData locationData;
  late MapController mapController = MapController();
  late YoutubePlayerController youtubePlayerController;

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final middleZoom =
        mapController.zoom <= 3 ? mapController.zoom : mapController.zoom - 0.5;
    final zoomTween = TweenSequence<double>([
      TweenSequenceItem<double>(
          tween: Tween(begin: mapController.zoom, end: middleZoom), weight: 2),
      TweenSequenceItem(
          tween: Tween(begin: middleZoom, end: middleZoom), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween(begin: middleZoom, end: destZoom), weight: 3)
    ]);

    var controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  late double latitude;
  late double longitude;
  late int oldFloor;

  @override
  void initState() {
    super.initState();
    floor = widget.floor;
    locationData = widget.locationData;
    latitude = locationData.location.latitude;
    longitude = locationData.location.longitude;
    oldFloor = 0;
  }

  @override
  didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget as FloorMap);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget map = FlutterMap(
      mapController: mapController,
      options: MapOptions(
        plugins: [],
        center: LatLng(60, -90),
        zoom: 2.0,
        maxZoom: floor == 0 ? 4.0 : 6.0,
        minZoom: 2.0,
        interactiveFlags: InteractiveFlag.doubleTapZoom |
            InteractiveFlag.drag |
            InteractiveFlag.pinchZoom |
            InteractiveFlag.pinchMove,
      ),
      layers: [
        TileLayerOptions(
            tileProvider: AssetTileProvider(),
            urlTemplate: floor == 0
                ? "assets/全体/{z}/{y}/{x}.jpg"
                : "assets/" + floor.toString() + "F/{z}/{y}/{x}.jpg",
            backgroundColor: Colors.white),
        MarkerLayerOptions(markers: [
          locationData.floor == floor
              ? Marker(
                  width: 100,
                  height: 100,
                  point: locationData.location,
                  builder: (ctx) => const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                )
              : Marker(
                  width: 0,
                  height: 0,
                  point: locationData.location,
                  builder: (ctx) => Container(),
                ),
        ]),
      ],
    );

    if (latitude != locationData.location.latitude ||
        longitude != locationData.location.longitude ||
        oldFloor != locationData.floor) {
      if (floor == locationData.floor) {
        latitude = locationData.location.latitude;
        longitude = locationData.location.longitude;
        oldFloor = locationData.floor;
        Future.delayed(const Duration(milliseconds: 500))
            .then((value) => _animatedMapMove(locationData.location, 5));
      }
    } else if (oldFloor != locationData.floor &&
        oldFloor != 0 &&
        floor == locationData.floor) {
      oldFloor = locationData.floor;
      Future.delayed(const Duration(milliseconds: 500))
          .then((value) => _animatedMapMove(locationData.location, 5));
    }

    Widget tab = SlidingUpPanel(
      body: map,
      maxHeight: 500,
      minHeight: 80,
      panelBuilder: (sc) => _panel(sc, context),
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50), topRight: Radius.circular(50)),
      color: const Color(0xFF616161),
      onPanelOpened: () {
        youtubePlayerController.play();
      },
      onPanelClosed: () {
        youtubePlayerController.pause();
      },
    );
    return floor != 0 ? tab : map;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  Widget _panel(ScrollController controller, BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Container(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: ListView(controller: controller, children: [
          const SizedBox(
            height: 12.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius:
                        const BorderRadius.all(Radius.circular(12.0))),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                locationData.floor == floor
                    ? locationData.locationName ?? "部屋情報を取得中..."
                    : "部屋情報を取得中...",
                style: const TextStyle(
                  fontSize: 26,
                ),
              )),
          const SizedBox(
            height: 20,
          ),
          Text(
            oldFloor == floor ? locationData.explanation! : "",
            style: TextStyle(fontSize: 19),
          ),
          const SizedBox(height: 20),
          if (locationData.youtubeID != null &&
              locationData.youtubeID!.isNotEmpty)
            TextButton(
              onPressed: () {
                _launchURL(locationData.youtubeID!);
              },
              child: Text(
                oldFloor == floor ? locationData.youtubeID! : "",
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ]),
      ),
    );
  }

  _launchURL(String youtubeId) async {
    final url = youtubeId;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'URLを開けませんでした：$url';
    }
  }
}
