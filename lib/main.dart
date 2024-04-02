import 'package:flutter/material.dart';
import 'package:web_api_3d/screens/register.dart';

void main() {
  runApp(const WebAPI());
}

class WebAPI extends StatelessWidget {
  const WebAPI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, home: RegisterScreen());
  }
}
