import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/Models/ProfileSeller.dart';
import 'package:order_food/ViewModels/Profile_ViewModel.dart';
import 'package:provider/provider.dart';

class GoogleMapManagement extends StatefulWidget {
  const GoogleMapManagement({super.key});

  @override
  State<GoogleMapManagement> createState() => _GoogleMapManagementState();
}

class _GoogleMapManagementState extends State<GoogleMapManagement> {
  bool _isLoading = true;
  late GoogleMapController mapController;
  final LatLng _initialPosition = const LatLng(21.0285, 105.8542);
  List<Map<String, dynamic>> dataLocation = [];
  Set<Marker> _marker = {};

  @override
  void initState() {
    super.initState();
    LoadAllData();
  }

  void LoadAllData() async {
    final location = Provider.of<Profile_ViewModel>(context, listen: false);
    List<Map<String, dynamic>>? data = await location.ShowAllLocationStore();
    if (data != null) {
      setState(() {
        dataLocation = data;
        _addMarkers();
      });
    }
  }

  void _addMarkers() async {
    final profileVM = Provider.of<Profile_ViewModel>(context, listen: false);
    Set<Marker> newMarkers = {};

    for (var location in dataLocation) {
      final lat = location['latitude'] as double;
      final lng = location['longitude'] as double;
      ProfileSeller? seller =
          await profileVM.GetAllDataProfileSeller(location["id"]);
      if (seller != null) {
        String storeName = seller.storeName;
        final name = storeName;
        newMarkers.add(
          Marker(
            markerId: MarkerId(UniqueKey().toString()),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    }

    setState(() {
      _marker = newMarkers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ModalProgressHUD(
        progressIndicator: LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50),
        inAsyncCall: _isLoading,
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 12,
              ),
              mapType: MapType.normal,
              myLocationEnabled: true,
              markers: _marker,
              myLocationButtonEnabled: true,
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.green,
                    size: 28, // Tăng kích thước
                    weight: 700, // Độ đậm (Flutter 3.0+)
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
