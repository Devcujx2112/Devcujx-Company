import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatelessWidget {
  const Contact({super.key});

  void _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw 'Không thể mở liên kết: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liên hệ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
        backgroundColor: Colors.green,
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildContactTile(
            icon: Icons.email,
            label: "Email",
            value: "dev.duongvu2112@gmail.com",
            onTap: () => _launchURL("mailto:dev.duongvu2112@gmail.com"),
          ),
          _buildContactTile(
            icon: Icons.phone,
            label: "Số điện thoại",
            value: "0364 703 365",
            onTap: () => _launchURL("tel:0364703365"),
          ),
          _buildContactTile(
            icon: Icons.facebook,
            label: "Facebook",
            value: "facebook.com",
            onTap: () => _launchURL("https://www.facebook.com/profile.php?id=100025377165179"),
          ),
          _buildContactTile(
            icon: Icons.discord,
            label: "Discord",
            value: "discord.gg/devcujx",
            onTap: () => _launchURL("https://discord.gg/example"),
          ),
          _buildContactTile(
            icon: Icons.code,
            label: "GitHub",
            value: "github.com/Devcujx2112",
            onTap: () => _launchURL("https://github.com/Devcujx2112"),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: Icon(icon, color: Colors.green),
        ),
        title: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.green)),
        subtitle: Text(value),
        trailing: const Icon(Icons.chevron_right, color: Colors.green),
        onTap: onTap,
      ),
    );
  }
}
