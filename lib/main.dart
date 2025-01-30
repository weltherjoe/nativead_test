import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Color backgroundColor = Colors.white;
Color textColor = Colors.black;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize();
  MobileAds.instance.setAppMuted(true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'NativeAd Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                        backgroundColor = Colors.black;
                      }),
                      child: const Text("Black Background"),
                    ),
                    FilledButton(
                        onPressed: () => setState(() {
                              backgroundColor = Colors.white;
                            }),
                        child: const Text("White Background")),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FilledButton(
                      onPressed: () =>
                          setState(() => backgroundColor = Colors.purple),
                      child: const Text("Purple Background"),
                    ),
                    FilledButton(
                        onPressed: () =>
                            setState(() => backgroundColor = Colors.amber),
                        child: const Text("Amber Background")),
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
