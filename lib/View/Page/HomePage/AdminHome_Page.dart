import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:order_food/Models/ProfileUser.dart';
import 'package:order_food/View/Screen/FavoriteUser_Screen.dart';
import 'package:order_food/View/Screen/ProfileUser_Screen.dart';
import 'package:order_food/View/Screen/OrderUser_Screen.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import '../../../ViewModels/Profile_ViewModel.dart';
import '../../Screen/CartUser_Screen.dart';
import '../../Screen/HomeUser_Screen.dart';
import '../../Widget/DrawerAdmin_Form.dart';
import 'package:provider/provider.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  late String uid;
  String email = "";
  String role = "Unknow";
  String fullName = "Loading...";
  String avatar = "";

  final List<Widget> _screens = [
    HomeUserScreen(),
    FavoriteUserScreen(),
    CartUserScreen(),
    OrderUserScreen(),
    ProfileUserScreen()
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final profileVM = Provider.of<Profile_ViewModel>(context, listen: false);
      final authVM = Provider.of<AuthViewModel>(context, listen: false);

      if (authVM.uid != null) {
        ProfileUser? user = await profileVM.GetAllDataProfileUser(authVM.uid!);
        if (user != null && mounted) {
          setState(() {
            email = user.email;
            role = user.role;
            fullName = user.fullName;
            avatar = user.image;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      drawer: role == "Admin"
          ? DrawerAdminScreen(
              email: email,
              fullName: fullName,
              image: avatar,
            )
          : null,
      body: (fullName == "Loading..." ||
              role == "Unknow" ||
              avatar == "" ||
              email == "")
          ? Center(child: CircularProgressIndicator())
          : _screens[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.white,
        buttonBackgroundColor: const Color(0xFF4CAF50),
        height: 50,
        index: _selectedIndex,
        items: [
          Icon(Icons.home,
              size: 25,
              color:
                  _selectedIndex == 0 ? Colors.white : const Color(0xFF4CAF50)),
          Icon(Icons.favorite_outlined,
              size: 25,
              color:
                  _selectedIndex == 1 ? Colors.white : const Color(0xFF4CAF50)),
          Icon(Icons.shopping_cart,
              size: 25,
              color:
                  _selectedIndex == 2 ? Colors.white : const Color(0xFF4CAF50)),
          Icon(Icons.assignment,
              size: 25,
              color:
                  _selectedIndex == 3 ? Colors.white : const Color(0xFF4CAF50)),
          Icon(Icons.person,
              size: 25,
              color:
                  _selectedIndex == 4 ? Colors.white : const Color(0xFF4CAF50)),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  AppBar? _buildAppBar() {
    if (_selectedIndex != 0) return null;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 20,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade300,
            child: ClipOval(
              child: avatar.isNotEmpty
                  ? Image.network(
                      avatar,
                      fit: BoxFit.cover,
                      width: 48,
                      height: 48,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('asset/images/avatar_default.jpg',
                            fit: BoxFit.cover, width: 48, height: 48);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50));
                      },
                    )
                  : Image.asset('asset/images/avatar_default.jpg',
                      fit: BoxFit.cover, width: 48, height: 48),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Welcome",
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text(fullName,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50))),
            ],
          ),
        ],
      ),
      actions: [
        if (role == "Admin")
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.green, size: 25),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
      ],
    );
  }
}
