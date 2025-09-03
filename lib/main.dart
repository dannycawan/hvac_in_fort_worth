import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

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
      title: 'Commercial HVAC in Fort Worth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
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
  List<String> listings = [];
  bool isLoading = true;

  // AdMob IDs
  final String bannerAdUnitId = "ca-app-pub-6721734106426198/5259469376";
  final String interstitialAdUnitId = "ca-app-pub-6721734106426198/7710531994";
  final String nativeAdUnitId = "ca-app-pub-6721734106426198/6120735266";

  BannerAd? _bannerAdTop;
  BannerAd? _bannerAdBottom;
  InterstitialAd? _interstitialAd;
  Timer? _interstitialTimer;

  // Cache Native Ads
  final Map<int, NativeAd> _nativeAds = {};

  @override
  void initState() {
    super.initState();
    _fetchListings();

    // Banner atas
    _bannerAdTop = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();

    // Banner bawah
    _bannerAdBottom = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();

    // Load interstitial
    _loadInterstitialAd();
    _interstitialTimer = Timer(const Duration(minutes: 3), () {
      _showInterstitialAd();
    });
  }

  Future<void> _fetchListings() async {
    try {
      final response =
          await http.get(Uri.parse("https://dannycawan.github.io/site/"));
      if (response.statusCode == 200) {
        final document = html.parse(response.body);
        final items = document.querySelectorAll("li");

        setState(() {
          listings = items.map((e) => e.text.trim()).toList();
          isLoading = false;
        });

        // Preload native ads untuk tiap 3 item
        for (int i = 0; i < listings.length; i++) {
          if (i > 0 && i % 3 == 0) {
            _loadNativeAd(i);
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Scraping error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadNativeAd(int index) {
    final nativeAd = NativeAd(
      adUnitId: nativeAdUnitId,
      factoryId: 'listTile', // register factory di Android/iOS
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _nativeAds[index] = ad as NativeAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("NativeAd failed: $error");
          ad.dispose();
        },
      ),
    );
    nativeAd.load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint("InterstitialAd failed: $error");
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _loadInterstitialAd();
    }
  }

  @override
  void dispose() {
    _bannerAdTop?.dispose();
    _bannerAdBottom?.dispose();
    _interstitialAd?.dispose();
    _interstitialTimer?.cancel();
    for (final ad in _nativeAds.values) {
      ad.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Commercial HVAC in Fort Worth"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Banner atas
          if (_bannerAdTop != null)
            SizedBox(
              height: _bannerAdTop!.size.height.toDouble(),
              width: _bannerAdTop!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAdTop!),
            ),

          // Konten scraping + native ads
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      if (_nativeAds.containsKey(index)) {
                        return Column(
                          children: [
                            ListTile(title: Text(listings[index])),
                            SizedBox(
                              height: 100,
                              child: AdWidget(ad: _nativeAds[index]!),
                            ),
                          ],
                        );
                      }
                      return ListTile(title: Text(listings[index]));
                    },
                  ),
          ),

          // Banner bawah
          if (_bannerAdBottom != null)
            SizedBox(
              height: _bannerAdBottom!.size.height.toDouble(),
              width: _bannerAdBottom!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAdBottom!),
            ),
        ],
      ),
    );
  }
}
