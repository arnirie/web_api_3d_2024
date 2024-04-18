import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapsScreen extends StatefulWidget {
  MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
//15.987779581934928, 120.57321759799687
  static final initialPosition = LatLng(15.987779581934928, 120.57321759799687);

  late GoogleMapController mapController;

  Set<Marker> markers = {
    Marker(
      markerId: MarkerId('01'),
      position: initialPosition,
      infoWindow: InfoWindow(title: 'My Current Location'),
      // icon: BitmapDescriptor.
    ),
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  void setToLocation(LatLng position) {
    CameraPosition cameraPosition = CameraPosition(target: position, zoom: 13);
    markers.clear();
    markers.add(Marker(
      markerId: MarkerId('${position.latitude} ${position.longitude}'),
      position: position,
    ));
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setState(() {});
  }

  Future<bool> checkServicePermission() async {
    //checking location service
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location services is disabled. Please enable it in the settings.')),
      );
      return false;
    }
    //check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      //ask for permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location permission is denied. Please accept the location permission of the app to continue.'),
          ),
        );
      }
      return false;
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permission is permanently denied. Please change in the settings to continue.'),
        ),
      );
      return false;
    }
    return true;
  }

  void getCurrentLocation() async {
    if (!await checkServicePermission()) {
      return;
    }
    Geolocator.getPositionStream(
            locationSettings: LocationSettings(
                accuracy: LocationAccuracy.bestForNavigation,
                distanceFilter: 10))
        .listen((position) {
      setToLocation(LatLng(position.latitude, position.longitude));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     IconButton(
      //         onPressed: () {
      //           setToLocation(LatLng(6.735870399174618, 126.17818151170235));
      //         },
      //         icon: Icon(Icons.map))
      //   ],
      // ),
      body: SafeArea(
        child: GoogleMap(
          mapType: MapType.normal,
          zoomControlsEnabled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          initialCameraPosition:
              CameraPosition(target: initialPosition, zoom: 10, tilt: 0),
          onMapCreated: (controller) {
            mapController = controller;
          },
          onTap: (position) {
            setToLocation(position);
          },
          markers: markers,
        ),
      ),
    );
  }
}
