import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

bool isDarkMode = false;
Color backgroundColor = Colors.white;
Color textColor = Colors.black;
const Color backgroundColorLight = Colors.white;
const Color textColorLight = Colors.black;
const Color backgroundColorDark = Colors.black;
const Color textColorDark = Colors.white;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize();
  MobileAds.instance.setAppMuted(true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'NativeAd Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (_, index) {
                final MyNativeAdmobTweet myNativeAd = MyNativeAdmobTweet();
                myNativeAd.loader();

                if (index == 2 || index == 12) {
                  return Column(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: myNativeAd,
                        builder: (_, value, child) {
                          return Visibility(
                            visible: value,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 320, // minimum recommended width
                                minHeight: 320, // minimum recommended height
                                maxWidth: 400,
                                maxHeight: 400,
                              ),
                              child: value
                                  ? AdWidget(ad: myNativeAd.nativeAd!)
                                  : const SizedBox.shrink(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, color: Colors.grey),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      SizedBox(
                          height: 40,
                          child: Text(
                            'Item $index',
                            style: TextStyle(color: textColor),
                          )),
                      const Divider(height: 1, color: Colors.grey),
                    ],
                  );
                }
              },
            ),
          ),
          SizedBox(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FilledButton(
                        onPressed: () => setState(() {
                              isDarkMode = true;
                              textColor = textColorDark;
                              backgroundColor = backgroundColorDark;
                            }),
                        child: const Text("Dark Mode")),
                    FilledButton(
                        onPressed: () => setState(() {
                              isDarkMode = false;
                              textColor = textColorLight;
                              backgroundColor = backgroundColorLight;
                            }),
                        child: const Text("Light Mode")),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FilledButton(
                        onPressed: () =>
                            setState(() => textColor = Colors.black),
                        child: const Text("Black Text")),
                    FilledButton(
                        onPressed: () =>
                            setState(() => textColor = Colors.white),
                        child: const Text("White Text")),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FilledButton(
                        onPressed: () =>
                            setState(() => textColor = Colors.purple),
                        child: const Text("Purple Text")),
                    FilledButton(
                        onPressed: () =>
                            setState(() => textColor = Colors.amber),
                        child: const Text("Amber Text")),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MyNativeAdmobTweet extends ValueNotifier<bool> {
  NativeAd? nativeAd;

  MyNativeAdmobTweet() : super(false);

  loader() {
    NativeAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/2247696110'
          : 'ca-app-pub-3940256099942544/3986624511',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdClicked: (ad) => developer.log('Ad clicked: ${ad.adUnitId}.'), //
        onAdClosed: (ad) => developer.log('Ad closed: ${ad.adUnitId}.'), //
        onAdFailedToLoad: (ad, error) {
          developer.log('Ad failed to load: ${ad.adUnitId}, $error.');
          ad.dispose();
        },
        onAdImpression: (ad) =>
            developer.log('Ad impression: ${ad.adUnitId}.'), //
        onAdLoaded: (ad) {
          nativeAd = ad as NativeAd;
          developer.log('Ad loaded: ${ad.adUnitId}.'); //
          value = true;
        },
        onAdOpened: (ad) => developer.log('Ad opened: ${ad.adUnitId}.'), //
        onAdWillDismissScreen: (ad) =>
            developer.log('Ad dismiss screen: ${ad.adUnitId}.'), //
        onPaidEvent: (ad, doub, precision, str) => developer.log(
            'Native Ad paid event: ${ad.adUnitId}, $doub, $precision, $str.'), //
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        // Required: Choose a template.
        templateType: TemplateType.medium,
        // Optional: Customize the ad's style.
        mainBackgroundColor: backgroundColor,
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: textColor,
          style: NativeTemplateFontStyle.bold,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: textColor,
          style: NativeTemplateFontStyle.bold,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: textColor,
          style: NativeTemplateFontStyle.bold,
        ),
      ),
    ).load();
  }
}
