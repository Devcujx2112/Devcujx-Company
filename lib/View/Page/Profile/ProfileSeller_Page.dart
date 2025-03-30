import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:order_food/Models/ProfileUser.dart';
import 'package:provider/provider.dart';

import '../../../ViewModels/Profile_ViewModel.dart';
import '../../Widget/DialogMessage_Form.dart';

class ProfileSellerPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfileSellerPage({super.key, required this.user});

  @override
  State<ProfileSellerPage> createState() => _ProfileSellerPageState();
}

class _ProfileSellerPageState extends State<ProfileSellerPage> {
  final List<String> statusOptions = ["Active", "Ban"];

  String formatDate(String? isoString) {
    if (isoString == null) return "Không xác định";
    try {
      DateTime dateTime = DateTime.parse(isoString);
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
    } catch (e) {
      return "Không xác định";
    }
  }

  void showDialogMessage(BuildContext context, String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(20),
          content: IntrinsicHeight(
            child: DialogMessageForm(message: message,intValue: Colors.blueAccent,),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title:
            const Text("Hồ sơ cá nhân", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Avatar
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(widget.user['Avatar'] ?? ""),
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 20),

            /// Thông tin cá nhân
            _buildReadOnlyTextField(
                "Tên cửa hàng", widget.user['StoreName'], Icons.store),
            _buildReadOnlyTextField(
                "Chủ cửa hàng", widget.user['OwnerName'], Icons.person),
            _buildReadOnlyTextField("Email", widget.user['Email'], Icons.email),

            Row(
              children: [
                Expanded(
                    child: _buildReadOnlyTextField(
                        "Vai trò", widget.user['Role'], Icons.badge)),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildReadOnlyTextField(
                        "SĐT", widget.user['Phone'], Icons.phone)),
              ],
            ),

            Row(
              children: [
                Expanded(
                    child: _buildReadOnlyTextField("Địa chỉ",
                        "${widget.user['Address']}", Icons.location_on)),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildReadOnlyTextField(
                      "Ngày tạo",
                      formatDate(widget.user['CreateAt']),
                      Icons.calendar_today),
                ),
              ],
            ),
            _buildDropdownField("Trạng thái", widget.user['Status'],
                statusOptions, Icons.library_add_check),

            _buildReadOnlyTextField(
                "Bio", widget.user['Bio'] ?? "", Icons.info_outline,
                maxLines: 3),

            const SizedBox(height: 30),

            _buildUpdateButton(),
          ],
        ),
      ),

      /// Floating Buttons
      floatingActionButton: _buildFloatingButtons(),
    );
  }

  Widget _buildReadOnlyTextField(String label, String value, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: TextField(
          readOnly: true,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins"),
            prefixIcon: Icon(icon, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none, // Không viền
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
          ),
          controller: TextEditingController(text: value),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      String label, String selectedValue, List<String> options, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold,
                fontFamily: "Poppins"),
            prefixIcon: Icon(icon, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none, // Không viền
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
              onChanged: (newValue) {
                setState(() {
                  widget.user['Status'] = newValue!;
                });
              },
              items: options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    final profileVM = Provider.of<Profile_ViewModel>(context, listen: true);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          bool success = await profileVM.UpdateStatusAccount(
              widget.user["Uid"], widget.user["Status"]);
          showDialogMessage(
              context,
              success
                  ? "Chỉnh sửa thành công"
                  : "Chỉnh sửa thất bại: ${profileVM.errorMessage}");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: profileVM.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Cập nhật thông tin",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "edit",
          onPressed: () {},
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.edit),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
