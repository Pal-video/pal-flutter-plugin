import 'package:flutter/material.dart';
import 'package:pal/pal.dart';

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
    // Future.delayed(const Duration(milliseconds: 500), () async {
    //   _showSingleChoiceDemoPopup();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pal plugin - demo'),
        ),
        body: ListView(
          children: [
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Demo - Single choice'),
              subtitle: const Text(
                'Single choice - Video then request user feedback',
              ),
              leading: const Icon(Icons.video_camera_back),
              onTap: () => _showSingleChoiceDemoPopup(),
            ),
            const Divider(),
            ListTile(
              title: const Text('Demo - Happy'),
              subtitle: const Text(
                'Single choice - Video then request user feedback',
              ),
              leading: const Icon(Icons.video_camera_back),
              onTap: () => _showHappyDemoPopup(),
            ),
          ],
        ),
      ),
    );
  }

  Future _showSingleChoiceDemoPopup() {
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

  Future _showHappyDemoPopup() {
    return PalPlugin.instance.showSingleChoiceSurvey(
      context: context,
      videoAsset: 'assets/happy.mp4',
      userName: 'David',
      companyTitle: 'Product manager - Hapii',
      question: 'Quelle fonctionnalité aimeriez-vous avoir prochainement ?',
      choices: const [
        Choice(id: 'a', text: 'Gestion des facturations'),
        Choice(id: 'b', text: 'Système de paiement'),
        Choice(id: 'c', text: 'Signature électronique'),
      ],
      onTapChoice: (choice) {},
      onVideoEndAction: () {},
    );
  }
}
