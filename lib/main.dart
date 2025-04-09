import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:order_food/View/Page/Login/FirstPage_Page.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/Category_ViewModel.dart';
import 'package:order_food/ViewModels/Order_ViewModel.dart';
import 'package:order_food/ViewModels/Product_ViewModel.dart';
import 'package:order_food/ViewModels/Profile_ViewModel.dart';
import 'package:order_food/ViewModels/ShoppingCart_ViewModel.dart';
import 'package:provider/provider.dart';
import 'Services/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthViewModel()),
      ChangeNotifierProvider(create: (context) => Profile_ViewModel()),
      ChangeNotifierProvider(create: (context) => Category_ViewModel()),
      ChangeNotifierProvider(create: (context) => Product_ViewModel()),
      ChangeNotifierProvider(create: (contex) => ShoppingCart_ViewModel()),
      ChangeNotifierProvider(create: (contex) => Order_ViewModel()),
    ],
    child: CompanyDev(),
  ));
}

class CompanyDev extends StatefulWidget {
  const CompanyDev({super.key});

  @override
  State<CompanyDev> createState() => _CompanyDevState();
}

class _CompanyDevState extends State<CompanyDev> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(useMaterial3: true),
        home: FirstPage());
  }
}
