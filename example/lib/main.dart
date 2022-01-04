import 'package:flutter/material.dart';
import 'package:pal/pal.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        splashFactory: InkSplash.splashFactory,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () async {
      // await PalPlugin.instance.showVideoAsset(context, 'assets/me.mp4');
      await PalPlugin.instance.showExpandedVideoAsset(context, 'assets/me.mp4');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            const ListTile(title: Text('Lorem ipsum')),
            const ListTile(title: Text('Lorem ipsum')),
            const ListTile(title: Text('Lorem ipsum')),
            const ListTile(title: Text('Lorem ipsum')),
            const ListTile(title: Text('Lorem ipsum')),
            ListTile(
              title: const Text('Lorem ipsum'),
              onTap: () {
                print("pressed");
              },
            ),
          ],
        ),
      ),
    );
  }
}
