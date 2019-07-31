import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivezy_app/utils/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_esri/flutter_map_esri.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

class MainScreen extends StatefulWidget {
  final GoogleSignInAccount googleUser;
  final FirebaseUser firebaseUser;

  MainScreen({Key key, @required this.googleUser, @required this.firebaseUser})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MainScreenState(googleUser: googleUser, firebaseUser: firebaseUser);
  }
}

class MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  Location location;
  LatLng newLocation = new LatLng(34.0231688, -118.2874995);
  final GoogleSignInAccount googleUser;
  final FirebaseUser firebaseUser;
  MapController mapController;
  Animation<double> _animateIcon;
  AnimationController _animationController;
  bool isOpened = false;

  MainScreenState({@required this.googleUser, @required this.firebaseUser});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void initState() {
    super.initState();
    mapController = new MapController();
    this.setState(() {});
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {
              print("location updating");
            });
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  animate() {
    if (isOpened) {
      _animationController.reverse();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
            content: Text("Stopping Location Updates..."),
            duration: Duration(milliseconds: 500)),
      );
    } else {
      _animationController.forward();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Starting Location Updates..."),
          duration: Duration(milliseconds: 500),
        ),
      );
    }
    isOpened = !isOpened;
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = new Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = new Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween =
        new Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a new animation controller that has a duration and a TickerProvider.
    AnimationController controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      // Note that the mapController.move doesn't seem to like the zoom animation. This may be a bug in flutter_map.
      mapController.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      print("$status");
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    initLocation();
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          animate();
        },
        child: AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: _animateIcon,
        ),
        mini: true,
      ),
      appBar: AppBar(
        elevation: 4.0,
        leading: Padding(
          padding: EdgeInsets.all(8.0),
          child: Offstage(
            offstage: googleUser.photoUrl == null,
            child: CircleAvatar(
                backgroundImage: NetworkImage(googleUser.photoUrl)),
          ),
        ),
        centerTitle: false,
        title: Text(googleUser.displayName),
      ),
      body: Container(
        child: new FlutterMap(
          mapController: mapController,
          options: new MapOptions(
            center: newLocation,
            zoom: 17.0,
          ),
          layers: [
            new EsriBasemapOptions(esriBasemapType: EsriBasemapType.streets),
            new MarkerLayerOptions(markers: [
              new Marker(
                width: 50.0,
                height: 50.0,
                point: newLocation,
                builder: (ctx) => new Container(
                    child: new CircleAvatar(
                        backgroundImage:
                            NetworkImage(this.googleUser.photoUrl))),
              )
            ])
          ],
        ),
      ),
    );
  }

  void initLocation() async {
    if (location == null) {
      location = Location();
      location.onLocationChanged().listen((locationData) {
        print("DataReceived: " + locationData.toString());
        handleNewLocation(locationData);
      }, onDone: () {
        print("Task Done");
      }, onError: (error) {
        print("Some Error");
        if (error.code == 'PERMISSION_DENIED') {
          print('Permission denied');
        }
      });

      // Platform messages may fail, so we use a try/catch PlatformException.
      try {
        var currentLocation = await location.getLocation();
        handleNewLocation(currentLocation);
      } on PlatformException catch (e) {
        if (e.code == 'PERMISSION_DENIED') {
          print('Permission denied');
        }
      }
    }
  }

  void handleNewLocation(LocationData currentLocation) {
    print(currentLocation.latitude);
    print(currentLocation.longitude);
    print(currentLocation.accuracy);
    print(currentLocation.altitude);
    print(currentLocation.speed);
    print(currentLocation.speedAccuracy); // Will always be 0 on iOS
    print("heading "+currentLocation.heading.toString());
    newLocation =
        new LatLng(currentLocation.latitude, currentLocation.longitude);
    _animatedMapMove(newLocation, 17);
    if(isOpened){
      updateLocation(newLocation);
    }
    setState(() {
      print("location updating");
    });
  }

  Map<String, String> prepareLocationModel(LatLng newLocation) {
    return {
      "latitude": newLocation.latitude.toString(),
      "longitude": newLocation.longitude.toString()
    };
  }

  void updateLocation(LatLng newLocation) async {
    await Firestore.instance
        .collection(AppConstants.FIRE_STORE_COLLECTION_LOCATION)
        .document(firebaseUser.phoneNumber)
        .setData(prepareLocationModel(newLocation));
  }
}
