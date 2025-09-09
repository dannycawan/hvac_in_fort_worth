import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product List with Ads',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProductListPage(),
    );
  }
}

class Product {
  final String name;
  final double rating;
  final int reviews;

  Product(this.name, this.rating, this.reviews);
}

class ProductListPage extends StatefulWidget {
  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> allProducts = List.generate(
    30,
    (i) => Product("Product $i", (i % 5 + 1).toDouble(), (i + 1) * 150),
  );
  List<Product> filteredProducts = [];

  // Ads
  BannerAd? topBanner;
  BannerAd? bottomBanner;
  InterstitialAd? interstitialAd;
  AppOpenAd? appOpenAd;

  int clickCount = 0;
  double minRating = 1;
  double maxRating = 5;
  RangeValues reviewRange = const RangeValues(0, 1000);
  int maxReviews = 1000;

  @override
  void initState() {
    super.initState();
    filteredProducts = List.from(allProducts);

    // set max reviews dynamically
    maxReviews = allProducts.map((p) => p.reviews).reduce((a, b) => a > b ? a : b);
    reviewRange = RangeValues(0, maxReviews.toDouble());

    _loadBannerAds();
    _loadInterstitialAd();
    _loadAppOpenAd();

    // show app open ad after delay
    Future.delayed(const Duration(seconds: 3), () {
      appOpenAd?.show();
    });
  }

  void _loadBannerAds() {
    topBanner = BannerAd(
      adUnitId: "ca-app-pub-6721734106426198/5259469376",
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(),
    )..load();

    bottomBanner = BannerAd(
      adUnitId: "ca-app-pub-6721734106426198/5259469376",
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-6721734106426198/7710531994",
      request: AdRequest(),
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
      _loadInterstitialAd(); // preload lagi
    }
  }

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: "ca-app-pub-6721734106426198/2181490258",
      orientation: AppOpenAd.orientationPortrait,
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) => appOpenAd = ad,
        onAdFailedToLoad: (err) => appOpenAd = null,
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      filteredProducts = allProducts.where((p) {
        return p.rating >= minRating &&
            p.rating <= maxRating &&
            p.reviews >= reviewRange.start &&
            p.reviews <= reviewRange.end;
      }).toList();
    });
  }

  Widget _buildNativeAd() {
    return Container(
      margin: const EdgeInsets.all(8),
      height: 120,
      color: Colors.grey[200],
      child: Center(
        child: AdWidget(
          ad: NativeAd(
            adUnitId: "ca-app-pub-6721734106426198/6120735266",
            factoryId: 'listTile',
            request: AdRequest(),
            listener: NativeAdListener(),
          )..load(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    topBanner?.dispose();
    bottomBanner?.dispose();
    interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (int i = 0; i < filteredProducts.length; i++) {
      items.add(ListTile(
        title: Text(filteredProducts[i].name),
        subtitle: Text(
          "⭐ ${filteredProducts[i].rating} | ${filteredProducts[i].reviews} reviews",
        ),
        onTap: () {
          clickCount++;
          if (clickCount % 3 == 0) {
            _showInterstitialAd();
          }
        },
      ));

      if ((i + 1) % 2 == 0) {
        items.add(_buildNativeAd());
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products with Ads"),
      ),
      body: Column(
        children: [
          if (topBanner != null)
            SizedBox(
              height: topBanner!.size.height.toDouble(),
              child: AdWidget(ad: topBanner!),
            ),
          Expanded(
            child: Column(
              children: [
                // Filter section
                ExpansionTile(
                  title: const Text("Filters"),
                  children: [
                    // Rating filter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(5, (i) {
                        return ChoiceChip(
                          label: Text("${i + 1} ⭐"),
                          selected: minRating == (i + 1).toDouble(),
                          onSelected: (sel) {
                            setState(() {
                              minRating = (i + 1).toDouble();
                              maxRating = (i + 1).toDouble();
                              _applyFilters();
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    // Reviews filter
                    Column(
                      children: [
                        Text("Reviews: ${reviewRange.start.toInt()} - ${reviewRange.end.toInt()}"),
                        RangeSlider(
                          values: reviewRange,
                          min: 0,
                          max: maxReviews.toDouble(),
                          divisions: 10,
                          labels: RangeLabels(
                            "${reviewRange.start.toInt()}",
                            "${reviewRange.end.toInt()}",
                          ),
                          onChanged: (val) {
                            setState(() {
                              reviewRange = val;
                              _applyFilters();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(children: items),
                ),
              ],
            ),
          ),
          if (bottomBanner != null)
            SizedBox(
              height: bottomBanner!.size.height.toDouble(),
              child: AdWidget(ad: bottomBanner!),
            ),
        ],
      ),
    );
  }
}
