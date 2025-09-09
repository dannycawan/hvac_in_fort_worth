import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ===== Dummy Data Model =====
class Business {
  final String name;
  final double rating;
  final int reviews;

  Business({required this.name, required this.rating, required this.reviews});
}

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
      home: BusinessListPage(),
    );
  }
}

class BusinessListPage extends StatefulWidget {
  @override
  State<BusinessListPage> createState() => _BusinessListPageState();
}

class _BusinessListPageState extends State<BusinessListPage> {
  List<Business> allData = [
    Business(name: "Store A", rating: 4.5, reviews: 120),
    Business(name: "Store B", rating: 3.8, reviews: 80),
    Business(name: "Store C", rating: 5.0, reviews: 300),
    Business(name: "Store D", rating: 2.5, reviews: 40),
    Business(name: "Store E", rating: 4.2, reviews: 200),
  ];

  List<dynamic> filteredData = [];

  int? selectedRating;
  int? selectedReviews;
  String selectedSort = "Top";

  final List<int?> ratingOptions = [null, 1, 2, 3, 4, 5];
  final List<int?> reviewOptions = [null, 10, 50, 100, 500, 1000];

  int clickCounter = 0;
  InterstitialAd? interstitialAd;
  AppOpenAd? appOpenAd;

  @override
  void initState() {
    super.initState();
    applyFilters();
    loadInterstitialAd();
    loadAppOpenAd();
  }

  void applyFilters() {
    List<Business> temp = allData.where((item) {
      final matchRating = selectedRating == null || item.rating >= selectedRating!;
      final matchReviews = selectedReviews == null || item.reviews >= selectedReviews!;
      return matchRating && matchReviews;
    }).toList();

    if (selectedSort == "Top") {
      temp.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      temp.sort((a, b) => b.reviews.compareTo(a.reviews));
    }

    filteredData = insertAds(temp);
    setState(() {});
  }

  List<dynamic> insertAds(List<Business> list) {
    List<dynamic> withAds = [];
    for (var item in list) {
      withAds.add(item);
      withAds.add("ad");
    }
    return withAds;
  }

  // ====== AdMob Logic ======

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-6721734106426198/7710531994",
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => interstitialAd = ad,
        onAdFailedToLoad: (error) => interstitialAd = null,
      ),
    );
  }

  void showInterstitialAd() {
    if (interstitialAd != null) {
      interstitialAd!.show();
      interstitialAd = null;
      loadInterstitialAd();
    }
  }

  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: "ca-app-pub-6721734106426198/2181490258",
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          appOpenAd = ad;
          Future.delayed(const Duration(seconds: 3), () {
            appOpenAd?.show();
            appOpenAd = null;
          });
        },
        onAdFailedToLoad: (error) => appOpenAd = null,
      ),
      orientation: AppOpenAd.orientationPortrait,
    );
  }

  BannerAd buildBannerAd() {
    return BannerAd(
      adUnitId: "ca-app-pub-6721734106426198/5259469376",
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
  }

  void handleClick() {
    clickCounter++;
    if (clickCounter % 3 == 0) {
      showInterstitialAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topBanner = buildBannerAd();
    final bottomBanner = buildBannerAd();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Business List"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // ====== Banner Fixed Atas ======
          SizedBox(
            height: topBanner.size.height.toDouble(),
            child: AdWidget(ad: topBanner),
          ),

          // ====== Filter Bar ======
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: selectedRating,
                    hint: const Text("Rating"),
                    items: ratingOptions.map((value) {
                      return DropdownMenuItem<int?>(
                        value: value,
                        child: Text(value == null ? "Any" : "$value+ ⭐"),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => selectedRating = val);
                      applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: selectedReviews,
                    hint: const Text("Reviews"),
                    items: reviewOptions.map((value) {
                      return DropdownMenuItem<int?>(
                        value: value,
                        child: Text(value == null ? "Any" : "$value+ Reviews"),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => selectedReviews = val);
                      applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedSort,
                    items: ["Top", "Most"].map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value == "Top" ? "Top Rating" : "Most Reviews"),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => selectedSort = val!);
                      applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // ====== List with Ads ======
          Expanded(
            child: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final item = filteredData[index];

                if (item == "ad") {
                  final inlineBanner = buildBannerAd();
                  return SizedBox(
                    height: inlineBanner.size.height.toDouble(),
                    child: AdWidget(ad: inlineBanner),
                  );
                }

                final business = item as Business;
                return ListTile(
                  title: Text(business.name),
                  subtitle: Text("⭐ ${business.rating} - ${business.reviews} reviews"),
                  onTap: () => handleClick(),
                );
              },
            ),
          ),

          // ====== Banner Fixed Bawah ======
          SizedBox(
            height: bottomBanner.size.height.toDouble(),
            child: AdWidget(ad: bottomBanner),
          ),
        ],
      ),
    );
  }
}
