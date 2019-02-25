import 'package:drivezy_app/ui/routes/auth.dart';
import 'package:flutter/material.dart';

void main() => runApp(DrivezyApp());

class DrivezyApp extends StatelessWidget {

  static int getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.brown,
      ),
      home: AuthScreen(),
    );
  }

  static MaterialColor black = MaterialColor(
    getColorFromHex("#232323"),
    <int, Color> {
      50:  Color(getColorFromHex("#e5e5e5")),
      100: Color(getColorFromHex("#bdbdbd")),
      200: Color(getColorFromHex("#919191")),
      300: Color(getColorFromHex("#656565")),
      400: Color(getColorFromHex("#444444")),
      500: Color(getColorFromHex("#232323")),
      600: Color(getColorFromHex("#1f1f1f")),
      700: Color(getColorFromHex("#1a1a1a")),
      800: Color(getColorFromHex("#151515")),
      900: Color(getColorFromHex("#0c0c0c")),
    },
  );

}


class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}