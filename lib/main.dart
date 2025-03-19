import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:order_food/View/Page/Login/FirstPage.dart';
import 'Services/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(CompanyDev());
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
      home: FirstPage()
    );
  }
}
