import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

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
      debugShowCheckedModeBanner: false,
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

  // Filter values
  double minRating = 0;
  double maxRating = 5;
  int minReviews = 0;
  int maxReviews = 1000000; // sangat besar biar unlimited

  // Sample data
  final List<Map<String, dynamic>> items = [
    {"title": "Product A", "rating": 4.8, "reviews": 1200},
    {"title": "Product B", "rating": 4.2, "reviews": 500},
    {"title": "Product C", "rating": 3.5, "reviews": 200},
    {"title": "Product D", "rating": 5.0, "reviews": 2500},
    {"title": "Product E", "rating": 4.0, "reviews": 100},
  ];

  @override
  void initState() {
    super.initState();
    _loadTopBanner();
    _loadBottomBanner();
    _loadInterstitial();
    _loadAppOpen();
  }

  void _loadTopBanner() {
    _topBanner = BannerAd(
      adUnitId: "ca-app-pub-6721734106426198/5259469376",
      request: const AdRequest(),
      size: AdSize.banner,
      listener: const BannerAdListener(),
    )..load();
  }

  void _loadBottomBanner() {
    _bottomBanner = BannerAd(
      adUnitId: "ca-app-pub-6721734106426198/5259469376",
      request: const AdRequest(),
      size: AdSize.banner,
      listener: const BannerAdListener(),
    )..load();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-6721734106426198/7710531994",
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  void _loadAppOpen() {
    AppOpenAd.load(
      adUnitId: "ca-app-pub-6721734106426198/2181490258",
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          Future.delayed(const Duration(seconds: 3), () {
            _appOpenAd?.show();
            _appOpenAd = null;
          });
        },
        onAdFailedToLoad: (error) => _appOpenAd = null,
      ),
    );
  }

  void _onItemClick(String title) {
    setState(() => _clickCount++);
    if (_clickCount % 3 == 0 && _interstitialAd != null) {
      _interstitialAd!.show();
      _loadInterstitial();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Clicked $title")),
    );
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    List<Map<String, dynamic>> filtered = items.where((item) {
      final rating = item["rating"] as double;
      final reviews = item["reviews"] as int;
      return rating >= minRating &&
          rating <= maxRating &&
          reviews >= minReviews &&
          reviews <= maxReviews;
    }).toList();

    // Jika filter aktif → sort by rating & reviews desc
    if (!(minRating == 0 && maxRating == 5 && minReviews == 0 && maxReviews >= 1000000)) {
      filtered.sort((a, b) {
        if (b["rating"].compareTo(a["rating"]) != 0) {
          return b["rating"].compareTo(a["rating"]);
        }
        return b["reviews"].compareTo(a["reviews"]);
      });
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();

    return Scaffold(
      appBar: AppBar(title: const Text("Product List with Ads")),
      body: Column(
        children: [
          if (_topBanner != null)
            SizedBox(
              height: _topBanner!.size.height.toDouble(),
              width: _topBanner!.size.width.toDouble(),
              child: AdWidget(ad: _topBanner!),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Rating range
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Rating Range"),
                      RangeSlider(
                        values: RangeValues(minRating, maxRating),
                        min: 0,
                        max: 5,
                        divisions: 5,
                        labels: RangeLabels("$minRating", "$maxRating"),
                        onChanged: (values) {
                          setState(() {
                            minRating = values.start;
                            maxRating = values.end;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Reviews range
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Reviews Range"),
                      RangeSlider(
                        values: RangeValues(
                            minReviews.toDouble(), maxReviews.toDouble()),
                        min: 0,
                        max: 5000, // tampilan UI aja, logikanya unlimited
                        divisions: 50,
                        labels: RangeLabels("$minReviews", "$maxReviews"),
                        onChanged: (values) {
                          setState(() {
                            minReviews = values.start.toInt();
                            maxReviews = values.end.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(item["title"]),
                      subtitle: Text(
                          "⭐ ${item["rating"]} | ${item["reviews"]} reviews"),
                      onTap: () => _onItemClick(item["title"]),
                    ),
                    // Native ad setiap listing
                    SizedBox(
                      height: 100,
                      child: AdWidget(
                        ad: NativeAd(
                          adUnitId: "ca-app-pub-6721734106426198/6120735266",
                          request: const AdRequest(),
                          factoryId: "listTile",
                          listener: const NativeAdListener(),
                        )..load(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_bottomBanner != null)
            SizedBox(
              height: _bottomBanner!.size.height.toDouble(),
              width: _bottomBanner!.size.width.toDouble(),
              child: AdWidget(ad: _bottomBanner!),
            ),
        ],
      ),
    );
  }
}
