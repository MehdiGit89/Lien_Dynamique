//@Code by EL IDRISSI Mehdi, mobile device app R&D 2023, for "Go'Place"

import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:lien_dynamique/route_generator.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:uri/uri.dart';

Future<void> main() async {
  //----Remove these 2 lines if you upload the code on the web
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  //----

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );


  // --Check if you received the link via `getInitialLink` first--
  // PendingDynamicLinkData = Link between the "sms" sent and the app.
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  // deepLink = Link to navigate inside the app.
  final Uri? deepLink = initialLink?.link;

  // This function checks if the app received a link.
  FirebaseDynamicLinks.instance.onLink.listen(
        (pendingDynamicLinkData) {
      // Set up the `onLink` event listener next as it may be received here
      if (pendingDynamicLinkData != null) {
        final Uri deepLink = pendingDynamicLinkData.link;
      }
    },
  );

  //Everything is sent in the app.
  runApp(MyApp(initialLink: initialLink, deepLink: deepLink));


  //Use instead this line if you host the code on the web
  //runApp(MyApp());
}


class MyApp extends StatefulWidget {

  //These 2 datas are initialised and sent in the app
  final PendingDynamicLinkData? initialLink;
  final Uri? deepLink;
  MyApp({Key? key, this.initialLink, this.deepLink}) : super(key: key);

  //Use instead this line if you host the code on the web
  //MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const InitialPage(),

      //The routes for each page.
      //This is an example for 4 pages : if you use more pages, create a list instead with each routes strings
      routes: {
        'home' : (_) => InitialPage(),
        '/second' :(_) => SecondPage(),
        '/third' :(_) => ThirdPage(),
        '/fourth' :(_) => FourthPage(),
      },
    );
  }
}

//The function to generate the DynLink, with the url of the page in parameter
Future<Uri> generateDynamicLink(String url) async {

  //add the '#' to the url to match with the domain template given by firebase
  if(url != '') {
    url = '#' +url;
  }

  final dynamicLinkParams = DynamicLinkParameters(
    link: Uri.parse("https://lien-dynamique-7fb7b.web.app"+url),
    uriPrefix: "https://liendynamique.page.link/",

    //-----To activate if the app is the put in Google play store and AppStore : androidParameteres and iosparameters

    /*
    androidParameters: const AndroidParameters(
      //Change the name of the package
      packageName: "com.example.lien_dynamique",
      minimumVersion: 1,
    ),
    iosParameters: const IOSParameters(
      //idem
      bundleId: "com.example.lienDynamique",
      appStoreId: "123456789",
      minimumVersion: "1.0.1",
    ),
     */
    //------
    //If we want to analyse the ratio of clicks in Google Analytics
    googleAnalyticsParameters: const GoogleAnalyticsParameters(
      source: "twitter",
      medium: "social",
      campaign: "go-place-promo",
    ),
    socialMetaTagParameters: SocialMetaTagParameters(
      title: "Regardez le divertissement près de chez vous : trouvé sur Go'Place",
      imageUrl: Uri.parse("https://pro.cultureasy.com/wp-content/uploads/2022/02/cultureasy-divertissement-culturel-heresie-home.jpeg"),
    ),
  );

  final dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
  return dynamicLink.shortUrl;
}

//The function to share the link (NOT WORKING ON THE WEB because of social networks new policies !
//MUST USE OTHER PLUGIN THAN "share_plus")
void shareDynamicLink(String url) async {
  final Uri dynamicUrl = await generateDynamicLink(url);
  //print(dynamicUrl.toString());
  Share.share(dynamicUrl.toString());
}

class InitialPage extends StatelessWidget {

  final PendingDynamicLinkData? initialLink;
  final Uri? deepLink;

  const InitialPage({Key? key, this.initialLink, this.deepLink}) : super(key: key);

  //Use instead this line if you host the code on the web
  //const InitialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    //Navigate through the app if the link is open, to the page corresponding
    if (initialLink != null) {
      Navigator.pushNamed(context, deepLink.toString());
    }

    //Each page has a current url and next url : if you use a list of routes (as said line 75), define the current ID of the list matching with this page, and the next
    String url = '';
    String nextUrl = '/second';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo test'),
      ),
      body: Center(
        child: Column(
          children: [
            new Container(
              height: 300.0,
              width: 20.0,
              decoration: new BoxDecoration(
                  color: Colors.indigoAccent, shape: BoxShape.rectangle),
            ),
            Text(
              "Page d'accueil",
              textScaleFactor: 3,
            ),
            ElevatedButton(
              onPressed: () {
                //We go in the next page.
                Navigator.of(context).pushNamed(nextUrl);
              },
              child: const Text('Page suivante'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    //idem for a list of routes
    String url = '/second';
    String nextUrl = '/third';

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(children: [
          new Container(
            height: 200.0,
            width: 200.0,
            decoration:
            new BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
          ),
          Text(
            'Page 2',
            textScaleFactor: 3,
          ),
          ElevatedButton(
            onPressed: () {
              //We go in the next page.
              Navigator.of(context).pushNamed(nextUrl);
            },
            child: const Text('Page suivante'),
          ),
        ]),
      ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  const ThirdPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    //idem for a list of routes
    String url = '/third';
    String nextUrl = '/fourth';

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(children: [
          new Container(
            height: 60.0,
            width: 150.0,
            decoration: new BoxDecoration(
                color: Colors.deepOrange, shape: BoxShape.rectangle),
          ),
          Text(
            'Page 3',
            textScaleFactor: 3,
          ),
          ElevatedButton(
            onPressed: () {
              //We call the function to share the link, that generates it firstly
              shareDynamicLink(url);
            },
            child: Text('Générer le lien dynamique'),
          ),
          ElevatedButton(
            onPressed: () {
              //We go in the next page.
              Navigator.of(context).pushNamed(nextUrl);
            },
            child: const Text('Page suivante'),
          ),
        ]),
      ),
    );
  }
}

class FourthPage extends StatelessWidget {
  const FourthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //idem if you use a list of routes instead
    String url ='/fourth';

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text('Page 4', textScaleFactor: 4),
            ElevatedButton(
              onPressed: () {
                //We call the function to share the link, that generates it firstly
                shareDynamicLink(url);
              },
              child: Text('Générer le lien dynamique'),
            ),
          ],
        ),
      ),
    );
  }
}