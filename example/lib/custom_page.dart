import 'package:flutter/material.dart';

class CustomPage extends StatelessWidget {
  final String? title;

  const CustomPage({Key? key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(title ?? 'custom page'),
      ),
    );
  }
}
