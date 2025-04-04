import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/Models/ProfileSeller.dart';
import 'package:order_food/View/Page/HomePage/ViewAllProduct.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/ViewModels/Profile_ViewModel.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class NearestStore extends StatefulWidget {
  const NearestStore({super.key});

  @override
  State<NearestStore> createState() => _NearestStoreState();
}

class _NearestStoreState extends State<NearestStore> {
  bool _isLoading = true;
  List<Map<String, dynamic>> listStore = [];
  final Profile_ViewModel profileVM = Profile_ViewModel(); // Khởi tạo ViewModel

  @override
  void initState() {
    super.initState();
    ShowAllData();
  }

  Future<Position> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialogMessage(
          context, "Dịch vụ định vị chưa bật.", DialogType.warning);
      throw Exception();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showDialogMessage(context,
            "Người dùng đã từ chối quyền truy cập vị trí.", DialogType.error);
        throw Exception();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showDialogMessage(context, "Quyền vị trí bị từ chối vĩnh viễn.",DialogType.error);
      throw Exception();
    }
    return await Geolocator.getCurrentPosition();
  }

  void ShowAllData() async {
    try {
      Position locationUser = await _getUserLocation();
      List<Map<String, dynamic>>? locationData =
          await profileVM.ShowStoreNear(locationUser.latitude, locationUser.longitude) ?? [];

      setState(() {
        listStore = locationData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      showDialogMessage(context, "Lỗi khi tải dữ liệu: ${e.toString()}", DialogType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      progressIndicator:
      LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.green,
          title: const Text(
            "Cửa hàng gần nhất",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: listStore.length,
          itemBuilder: (context, index) {
            final store = listStore[index];
            return FutureBuilder<ProfileSeller?>(
              future: profileVM.GetAllDataProfileSeller(store['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingCard();
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return _buildErrorCard(store);
                }
                return _buildStoreCard(store, snapshot.data!);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 200,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCard(Map<String, dynamic> store) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text('Không thể tải thông tin cửa hàng',
                style: TextStyle(color: Colors.red)),
            Text('Khoảng cách: ${store['distance_km']} km'),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard(Map<String, dynamic> store, ProfileSeller data) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh cửa hàng
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              data.image.isNotEmpty
                  ? data.image
                  : "https://via.placeholder.com/150",
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey[200],
                child: const Icon(Icons.store, size: 60, color: Colors.grey),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.storeName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${store['distance_km']} km',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                // Địa chỉ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.address,
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      data.phone,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    // Nút liên hệ
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Ghé tiệm',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  ViewAllProduct(uid: data.uid,)),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}