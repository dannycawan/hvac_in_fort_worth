import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Listing App with Ads',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Ads
  BannerAd? _topBanner;
  BannerAd? _bottomBanner;
  InterstitialAd? _interstitialAd;
  AppOpenAd? _appOpenAd;
  int _clickCount = 0;

  // Filters
  double _rating = 3;
  RangeValues _reviews = const RangeValues(0, 1000);

  // Dummy data
  final List<Map<String, dynamic>> _items = List.generate(
    20,
    (index) => {
      "title": "Item ${index + 1}",
      "rating": (1 + (index % 5)).toDouble(),
      "reviews": (index + 1) * 123,
    },
  );

  @override
  void initState() {
    super.initState();
    _loadBanners();
    _loadInterstitial();
    _loadAppOpenAd();
    Future.delayed(const Duration(seconds: 3), () {
      _showAppOpenAd();
    });
  }

  void _loadBanners() {
    _topBanner = BannerAd(
      adUnitId: "ca-app-pub-3940256099942544/6300978111", // ganti dengan punyamu
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();

    _bottomBanner = BannerAd(
      adUnitId: "ca-app-pub-3940256099942544/6300978111", // ganti dengan punyamu
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-3940256099942544/1033173712", // ganti dengan punyamu
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  void _showInterstitial() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _loadInterstitial();
    }
  }

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: "ca-app-pub-3940256099942544/3419835294", // ganti dengan punyamu
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) => _appOpenAd = ad,
        onAdFailedToLoad: (error) => _appOpenAd = null,
      ),
    );
  }

  void _showAppOpenAd() {
    if (_appOpenAd != null) {
      _appOpenAd!.show();
      _appOpenAd = null;
    }
  }

  @override
  void dispose() {
    _topBanner?.dispose();
    _bottomBanner?.dispose();
    _interstitialAd?.dispose();
    _appOpenAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((item) {
      return item["rating"] >= _rating &&
          item["reviews"] >= _reviews.start &&
          item["reviews"] <= _reviews.end;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Listing App with Ads")),
      body: Column(
        children: [
          if (_topBanner != null)
            SizedBox(height: 50, child: AdWidget(ad: _topBanner!)),

          // Filter UI
          ExpansionTile(
            title: const Text("Filters"),
            children: [
              ListTile(
                title: const Text("Minimum Rating"),
                subtitle: Slider(
                  min: 1,
                  max: 5,
                  divisions: 4,
                  value: _rating,
                  label: _rating.toString(),
                  onChanged: (val) {
                    setState(() => _rating = val);
                  },
                ),
              ),
              ListTile(
                title: const Text("Reviews Range"),
                subtitle: RangeSlider(
                  min: 0,
                  max: 5000, // besar supaya fleksibel
                  values: _reviews,
                  labels: RangeLabels(
                    _reviews.start.round().toString(),
                    _reviews.end.round().toString(),
                  ),
                  onChanged: (val) {
                    setState(() => _reviews = val);
                  },
                ),
              ),
            ],
          ),

          // List with ads
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(item["title"]),
                      subtitle: Text(
                          "⭐ ${item["rating"]} | ${item["reviews"]} reviews"),
                      onTap: () {
                        _clickCount++;
                        if (_clickCount % 3 == 0) {
                          _showInterstitial();
                        }
                      },
                    ),
                    SizedBox(
                      height: 120,
                      child: AdWidget(
                        ad: BannerAd(
                          adUnitId:
                              "ca-app-pub-3940256099942544/6300978111", // ganti dengan punyamu
                          size: AdSize.mediumRectangle,
                          request: const AdRequest(),
                          listener: const BannerAdListener(),
                        )..load(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          if (_bottomBanner != null)
            SizedBox(height: 50, child: AdWidget(ad: _bottomBanner!)),
        ],
      ),
    );
  }
}
