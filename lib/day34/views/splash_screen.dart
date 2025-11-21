import 'package:absensi_ppkd_b4/day34/preferences/preference_handler.dart';
import 'package:absensi_ppkd_b4/day34/views/dashboard_screen.dart';
import 'package:absensi_ppkd_b4/day34/views/login_screen.dart';
import 'package:absensi_ppkd_b4/day34/widgets/copyright_widget.dart';
import 'package:flutter/material.dart';

class SplashScreenDay18 extends StatefulWidget {
  const SplashScreenDay18({super.key});

  @override
  State<SplashScreenDay18> createState() => _SplashScreenDay18State();
}

class _SplashScreenDay18State extends State<SplashScreenDay18> {
  @override
  void initState() {
    super.initState();
    isLoginFunction();
  }

  isLoginFunction() async {
    Future.delayed(Duration(seconds: 3)).then((value) async {
      var isLogin = await SharedPrefHandler.isLoggedIn();
      print(isLogin);
      if (isLogin != null && isLogin == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DashboardPageDay34()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff176B87), Color(0xff86B6F6), Color(0xffB4D4FF)],
            begin: AlignmentGeometry.topCenter,
            end: AlignmentGeometry.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset("assets/images/Absen_Si_Logo.png", scale: 3),
            ),

            SizedBox(height: 20),
            Text(
              "Absen Si",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xff176B87),
              ),
            ),

            SizedBox(height: 10),
            Text(
              "Absen jadi easy, tinggal tap langsung ready",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Color(0xff176B87),
              ),
            ),
            const SizedBox(height: 20),
            CopyrightWidget(
              companyName: 'Created by Windu Wulandari',
              startYear: 2025,
              textStyle: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
