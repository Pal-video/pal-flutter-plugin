import 'package:flutter/material.dart';
import 'package:pal/api/models/pal_options.dart';
import 'package:pal/api/pal.dart';
import 'package:pal/pal.dart';
import 'package:pal/sdk/navigation_observer.dart';
import 'package:pal_plugin_example/page_fake.dart';

import 'page1.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  final Pal pal = Pal.instance;
  WidgetsFlutterBinding.ensureInitialized();
  await pal.initialize(
    PalOptions(
      apiKey:
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tL2lzc3VlciIsInVwbiI6IjBmZTAwNzMwLTc5ZGItNDRkNS04NjNkLTkxMzk5NzRhYmFmNkBwYWwuaW8iLCJzdWIiOiIwZmUwMDczMC03OWRiLTQ0ZDUtODYzZC05MTM5OTc0YWJhZjYiLCJpYXQiOjE2NTEwNjYzNDYsImdyb3VwcyI6WyJQcm9qZWN0Il0sImV4cCI6MTAyOTEwNjYzNDYsImp0aSI6IjFmMmQ0OGRlLTc2MjctNDliOS04OTZjLTEwZmU4OTU2NmQ4NSJ9.KV4iBBl2Yqt8OMDY2cLapQz1udlCQOxYR0_z_ujXVTObi-KKnc0yJPTfAydd9hOJqFpVXSiyulrCRS8HxfspCfigRTebynnDmJzM7tMZ981AYkYqJNre8JNYxY292m2bXf77qrBlSHAMcgYjRyvig6iyVW1p6DyhNuzNDqdu931k-bgm2s5_MJv9UiWq3FB6TG9E2nKBohR-ScCLlFwvbbpEjwed06RFNkzSShYPk5oYRUv0h4d2DxsjaZnyBf3Gv7zzTbdyqAenLf1A3c_0vUTUOrVvYICGzjUbO3kyKtEPGZlQclYenPYCEKCL84px4SlqQYFjB_o876fbD-pUGg',
    ),
    navigatorKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pal plugin demo',
      navigatorKey: navigatorKey,
      navigatorObservers: [PalNavigatorObserver.create()],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        splashFactory: InkSplash.splashFactory,
      ),
      routes: {
        '/': (context) => const HomePage(),
        '/page1_2': (context) => const Page1(),
      },
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
  Widget build(BuildContext context) {
    debugPrint("--------------------");
    debugPrint("Starting pal demo");
    debugPrint("--------------------");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pal plugin - demo'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Demo - trigger video'),
            subtitle: const Text(
              'Trigger a simple video from server API',
            ),
            leading: const Icon(Icons.cloud_download),
            onTap: () => Navigator.of(context).pushNamed('/page1_2'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Session reset'),
            subtitle: const Text(
              'Force recreate the Pal user session',
            ),
            leading: const Icon(Icons.cloud_download),
            onTap: () => _showSingleChoiceDemoPopup(),
          ),
          const Divider(),
          ListTile(
            title: const Text('SDK Demo - Single choice'),
            subtitle: const Text(
              'Single choice - Video then request user feedback',
            ),
            leading: const Icon(Icons.video_camera_back),
            onTap: () => _showSingleChoiceDemoPopup(),
          ),
          const Divider(),
          ListTile(
            title: const Text('SDK Demo - Meeriad'),
            subtitle: const Text(
              'Single choice - Video then request user feedback',
            ),
            leading: const Icon(Icons.video_camera_back),
            onTap: () => _showMeeriadDemoPopup(),
          ),
          const Divider(),
          ListTile(
            title: const Text('SDK Demo - Fridaa'),
            subtitle: const Text(
              'App immersion',
            ),
            leading: const Icon(Icons.remove_red_eye),
            onTap: () => _showFridaDemo(),
          ),
        ],
      ),
    );
  }

  PalSdk palSdk = PalSdk.fromKey(navigatorKey: navigatorKey);

  Future _showSingleChoiceDemoPopup() {
    return palSdk.showSingleChoiceSurvey(
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

  Future _showMeeriadDemoPopup() {
    return palSdk.showSingleChoiceSurvey(
      context: context,
      videoAsset: 'assets/meeriad.mp4',
      userName: 'David',
      companyTitle: 'Product manager - Meeriad',
      question: 'Quelle fonctionnalité aimeriez-vous avoir prochainement ?',
      choices: const [
        Choice(id: 'a', text: 'La gestion des challenges'),
        Choice(id: 'b', text: 'L\'ajout de thématiques'),
        Choice(id: 'c', text: 'L\'amélioration des événements'),
      ],
      onTapChoice: (choice) {},
      onVideoEndAction: () {},
    );
  }

  Future _showFridaDemo() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FakePage(
          assetImgUrl: "assets/background1.jpeg",
          onTap: () async {
            await palSdk.showSingleChoiceSurvey(
              context: context,
              videoAsset: 'assets/fridaa.mp4',
              userName: 'David',
              companyTitle: 'Product manager - Fridaa',
              question:
                  'Quelle fonctionnalité aimeriez-vous avoir prochainement ?',
              choices: const [
                Choice(id: 'a', text: 'Ajouter des liens d’annonces'),
                Choice(id: 'b', text: 'Créer un dossier de demande de prêt '),
                Choice(id: 'c', text: 'Gestion des propositions faites'),
              ],
              onTapChoice: (choice) {},
              onVideoEndAction: () {},
            );
          },
          onTapBottom: () async {
            await palSdk.showVideoOnly(
              context: context,
              minVideoUrl: 'assets/fridaa.mp4',
              videoUrl: 'assets/fridaa.mp4',
              userName: 'David',
              companyTitle: 'Product manager - Fridaa',
            );
          },
        ),
      ),
    );
  }
}
