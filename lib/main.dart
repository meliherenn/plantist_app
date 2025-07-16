import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const PlantistApp());
}

class PlantistApp extends StatelessWidget {
  const PlantistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Plantist",
        home: const WelcomeScreen(),
        builder: (context, widget) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: widget!,
        ),
      ),
    );
  }
}
