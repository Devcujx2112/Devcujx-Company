import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:order_food/Models/ProfileUser.dart';
import 'package:provider/provider.dart';

import '../../../ViewModels/Profile_ViewModel.dart';
import '../../Widget/DialogMessage_Form.dart';

class ProfileDetailSeller extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfileDetailSeller({super.key, required this.user});

  @override
  State<ProfileDetailSeller> createState() => _ProfileDetailSellerState();
}

class _ProfileDetailSellerState extends State<ProfileDetailSeller> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
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
                radius: 50,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: (widget.user['Avatar'] != null &&
                        widget.user['Avatar']!.isNotEmpty)
                    ? NetworkImage(widget.user['Avatar']!)
                    : null,
                child: (widget.user['Avatar'] == null ||
                        widget.user['Avatar']!.isEmpty)
                    ? Image.asset(
                        'asset/images/avatar_default.jpg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

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
                  flex: 1,
                  child: _buildDropdownField(
                      "Trạng thái",
                      widget.user['Status'],
                      statusOptions,
                      Icons.library_add_check),
                ),
              ],
            ),

            _buildReadOnlyTextField("Ngày tạo",
                formatDate(widget.user['CreateAt']), Icons.calendar_today),
            _buildReadOnlyTextField(
                "Bio", widget.user['Bio'] ?? "", Icons.info_outline,
                maxLines: 3),

            const SizedBox(height: 30),

            _buildUpdateButton(),
          ],
        ),
      ),

      /// Floating Buttons
    );
  }

  Widget _buildReadOnlyTextField(String label, String value, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        child: TextField(
          style: TextStyle(fontFamily: "Poppins", fontSize: 13),
          readOnly: true,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins"),
            prefixIcon: Icon(icon, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none, // Không viền
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        borderRadius: BorderRadius.circular(20),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
                fontSize: 13,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins"),
            prefixIcon: Icon(icon, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none, // Không viền
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
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
                  child: Text(value, style: const TextStyle(fontSize: 14)),
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
          if (success) {
            Navigator.pop(context, true);
            showDialogMessage(
                context, "Chỉnh sửa thông tin thành công", DialogType.success);
          } else {
            showDialogMessage(
                context,
                "Chỉnh sửa thông tin thất bại ${profileVM.errorMessage}",
                DialogType.error);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: profileVM.isLoading
            ? const SizedBox(width: 25, height: 25,child:  CircularProgressIndicator(color: Colors.white,),)
            : const Text("Cập nhật thông tin",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
      ),
    );
  }
}
