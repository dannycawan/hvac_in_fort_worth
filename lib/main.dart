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
      title: 'Listing with Ads',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
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
  BannerAd? topBannerAd;
  BannerAd? bottomBannerAd;
  InterstitialAd? interstitialAd;
  AppOpenAd? appOpenAd;
  NativeAd? nativeAd;
  bool isNativeAdLoaded = false;

  int clickCount = 0;

  // Example data
  List<Map<String, dynamic>> items = List.generate(
    30,
    (i) => {
      "title": "Item ${i + 1}",
      "rating": (i % 5 + 1).toDouble(),
      "reviews": (i + 1) * 123,
    },
  );

  double minRating = 1;
  double maxRating = 5;
  double minReviews = 0;
  double maxReviews = 1000;

  @override
  void initState() {
    super.initState();
    _loadBannerAds();
    _loadInterstitialAd();
    _loadAppOpenAd();
    _loadNativeAd();

    // delay show app open ad once
    Future.delayed(const Duration(seconds: 3), () {
      appOpenAd?.show();
      appOpenAd = null;
    });

    // set dynamic max reviews
    final maxFromData = items.map((e) => e["reviews"] as int).reduce((a, b) => a > b ? a : b);
    setState(() {
      maxReviews = maxFromData.toDouble();
    });
  }

  void _loadBannerAds() {
    topBannerAd = BannerAd(
      adUnitId: "ca-app-pub-6721734106426198/5259469376",
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();

    bottomBannerAd = BannerAd(
      adUnitId: "ca-app-pub-6721734106426198/5259469376",
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-6721734106426198/7710531994",
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => interstitialAd = ad,
        onAdFailedToLoad: (err) => interstitialAd = null,
      ),
    );
  }

  void _showInterstitialAd() {
    if (interstitialAd != null) {
      interstitialAd!.show();
      interstitialAd = null;
      _loadInterstitialAd();
    }
  }

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: "ca-app-pub-6721734106426198/2181490258",
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) => appOpenAd = ad,
        onAdFailedToLoad: (err) => appOpenAd = null,
      ),
    );
  }

  void _loadNativeAd() {
    nativeAd = NativeAd(
      adUnitId: "ca-app-pub-6721734106426198/6120735266",
      factoryId: "listTile", // harus daftarkan di Android native factory
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() => isNativeAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() => isNativeAdLoaded = false);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    topBannerAd?.dispose();
    bottomBannerAd?.dispose();
    interstitialAd?.dispose();
    appOpenAd?.dispose();
    nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = items.where((item) {
      return item["rating"] >= minRating &&
          item["rating"] <= maxRating &&
          item["reviews"] >= minReviews &&
          item["reviews"] <= maxReviews;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Listing with Ads"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (topBannerAd != null)
            SizedBox(
              height: topBannerAd!.size.height.toDouble(),
              width: topBannerAd!.size.width.toDouble(),
              child: AdWidget(ad: topBannerAd!),
            ),
          _buildFilters(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(item["title"]),
                      subtitle: Text(
                        "⭐ ${item["rating"]} | ${item["reviews"]} reviews",
                      ),
                      onTap: () {
                        clickCount++;
                        if (clickCount % 3 == 0) {
                          _showInterstitialAd();
                        }
                      },
                    ),
                    if (isNativeAdLoaded && nativeAd != null)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        height: 100,
                        child: AdWidget(ad: nativeAd!),
                      ),
                  ],
                );
              },
            ),
          ),
          if (bottomBannerAd != null)
            SizedBox(
              height: bottomBannerAd!.size.height.toDouble(),
              width: bottomBannerAd!.size.width.toDouble(),
              child: AdWidget(ad: bottomBannerAd!),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text("Filter by Rating"),
          RangeSlider(
            values: RangeValues(minRating, maxRating),
            min: 1,
            max: 5,
            divisions: 4,
            labels: RangeLabels(
              minRating.toString(),
              maxRating.toString(),
            ),
            onChanged: (values) {
              setState(() {
                minRating = values.start;
                maxRating = values.end;
              });
            },
          ),
          const Text("Filter by Reviews"),
          RangeSlider(
            values: RangeValues(minReviews, maxReviews),
            min: 0,
            max: maxReviews,
            labels: RangeLabels(
              minReviews.toStringAsFixed(0),
              maxReviews.toStringAsFixed(0),
            ),
            onChanged: (values) {
              setState(() {
                minReviews = values.start;
                maxReviews = values.end;
              });
            },
          ),
        ],
      ),
    );
  }
}
