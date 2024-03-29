import 'package:flutter/material.dart';
import 'package:pal_video/pal.dart';
import 'package:pal_plugin_example/page_fake.dart';

import 'custom_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Pal pal = Pal.instance;
  await pal.initialize(
    PalOptions(
      apiKey: const String.fromEnvironment('PAL_TOKEN'),
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
        '/page1_2': (context) => const CustomPage(),
        '/user/account/contact': (context) => const CustomPage(
              title: '/user/account/contact',
            ),
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
            onTap: () => Pal.instance.clearSession(),
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
          const Divider(),
          ListTile(
              title: const Text('Complete Demo'),
              subtitle: const Text(
                'Dynamic link',
              ),
              leading: const Icon(Icons.dynamic_feed),
              onTap: () {
                Navigator.of(context).pushNamed('/user/account/contact');
              }),
        ],
      ),
    );
  }

  PalSdk palSdk = PalSdk.fromKey(navigatorKey: navigatorKey);

  Future _showSingleChoiceDemoPopup() {
    return palSdk.showSingleChoiceSurvey(
      videoAsset: 'assets/me.mp4',
      userName: 'Gautier',
      companyTitle: 'Apparence.io CTO',
      question:
          'Choisissez la prochaine feature qui pourrait vous intéresser ?',
      choices: const [
        Choice(code: 'a', text: 'lorem A'),
        Choice(code: 'b', text: 'lorem B'),
        Choice(code: 'c', text: 'lorem C'),
        Choice(code: 'd', text: 'lorem D'),
      ],
      onTapChoice: (choice) {},
      onVideoEndAction: () {},
    );
  }

  Future _showMeeriadDemoPopup() {
    return palSdk.showSingleChoiceSurvey(
      videoAsset: 'assets/meeriad.mp4',
      userName: 'David',
      companyTitle: 'Product manager - Meeriad',
      question: 'Quelle fonctionnalité aimeriez-vous avoir prochainement ?',
      choices: const [
        Choice(code: 'a', text: 'La gestion des challenges'),
        Choice(code: 'b', text: 'L\'ajout de thématiques'),
        Choice(code: 'c', text: 'L\'amélioration des événements'),
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
              videoAsset: 'assets/fridaa.mp4',
              userName: 'David',
              companyTitle: 'Product manager - Fridaa',
              question:
                  'Quelle fonctionnalité aimeriez-vous avoir prochainement ?',
              choices: const [
                Choice(code: 'a', text: 'Ajouter des liens d’annonces'),
                Choice(code: 'b', text: 'Créer un dossier de demande de prêt '),
                Choice(code: 'c', text: 'Gestion des propositions faites'),
              ],
              onTapChoice: (choice) {},
              onVideoEndAction: () {},
            );
          },
          onTapBottom: () async {
            await palSdk.showVideoOnly(
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
