import 'package:flutter/material.dart';
import 'package:pal/pal.dart';
import 'package:pal/surveys/single_choice/single_choice.dart';
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
      _showSingleChoicePopup();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pal plugin - demo'),
        ),
        body: Column(
          children: [
            ListTile(
              title: const Text('Pal - feedback'),
              subtitle: const Text('Video then request user feedback'),
              leading: const Icon(Icons.video_camera_back),
              onTap: () {
                _showSingleChoicePopup();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future _showSingleChoicePopup() {
    return PalPlugin.instance.showSingleChoiceSurvey(
      context: context,
      videoAsset: 'assets/me.mp4',
      userName: 'Gautier',
      companyTitle: 'Apparence.io CTO',
      question: 'my question lorem ipsum lorem',
      choices: const [
        Choice(id: 'a', text: 'lorem A'),
        Choice(id: 'b', text: 'lorem B'),
        Choice(id: 'c', text: 'lorem C'),
        Choice(id: 'd', text: 'lorem D'),
      ],
      onTapChoice: (choice) {},
      onVideoEndAction: () {},
    );
  }
}
