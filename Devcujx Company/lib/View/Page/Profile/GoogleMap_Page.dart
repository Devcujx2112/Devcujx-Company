import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../ViewModels/Auth_ViewModel.dart';
import '../../../ViewModels/Profile_ViewModel.dart';
import '../../Widget/DialogMessage_Form.dart';

class GoogleMapScreenPage extends StatefulWidget {
  const GoogleMapScreenPage({super.key});

  @override
  State<GoogleMapScreenPage> createState() => _GoogleMapScreenPageState();
}

class _GoogleMapScreenPageState extends State<GoogleMapScreenPage> {
  late GoogleMapController mapController;
  Marker? location;
  final LatLng _initialPosition = LatLng(21.0285, 105.8542);
  late String uid;
  List<double>? dataLocation;

  Future<void> LoadLocationStore() async {}

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final profileVM = Provider.of<Profile_ViewModel>(context, listen: false);
      if (authVM.uid != null) {
        uid = authVM.uid!;
      }
      dataLocation = await profileVM.LoadLocationStore(uid);
      if (dataLocation != null) {
        print("Vi tri Loading location $dataLocation}");
        setState(() {
          location = Marker(
              markerId: const MarkerId("Save_Location"),
              position: LatLng(dataLocation![0], dataLocation![1]),
              infoWindow: const InfoWindow(title: "Vị trí của cửa hàng"),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
          );
        });
        mapController.animateCamera(CameraUpdate.newLatLng(
            LatLng(dataLocation![0], dataLocation![1])
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<Profile_ViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "GoogleMap",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: "Poppins",
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 13,
            ),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: location != null ? {location!} : {},
            onTap: (LatLng chosePoint) {
              setState(() {
                location = Marker(
                  markerId: const MarkerId('Selected Location'),
                  position: chosePoint,
                  infoWindow: const InfoWindow(title: 'Cửa hàng của bạn'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                );
              });
            },
          ),
          Positioned(
            bottom: 40,
            left: 30,
            child: profileVM.isLoading
                ? const CircularProgressIndicator()
                : FloatingActionButton(
                    onPressed: () async {
                      if (location == null) {
                        showDialogMessage(context, "Vui lòng chọn vị trí cửa hàng",DialogType.warning);
                      } else {
                        bool success = await profileVM.SaveLocationStore(
                            uid,
                            location!.position.latitude,
                            location!.position.longitude);
                        if (success) {
                          Navigator.pop(context);
                          showDialogMessage(
                              context, "Lưu vị trí cửa hàng thành công",DialogType.success);
                        } else {
                          showDialogMessage(context,
                              "Lỗi khi lưu vị trí cửa hàng : ${profileVM.errorMessage}",DialogType.error);
                        }
                      }
                    },
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.save, color: Colors.green),
                  ),
          ),
        ],
      ),
    );
  }
}
