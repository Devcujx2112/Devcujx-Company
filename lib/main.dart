import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:order_food/FirstPage.dart';

void main(){
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
      theme: ThemeData.light(useMaterial3: true),
      home: Firstpage(),);
  }
}
