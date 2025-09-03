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
  // AdMob IDs
  final String bannerAdUnitId = "ca-app-pub-6721734106426198/5259469376";
  final String interstitialAdUnitId = "ca-app-pub-6721734106426198/7710531994";

  BannerAd? _bannerAdTop;
  BannerAd? _bannerAdBottom;
  InterstitialAd? _interstitialAd;
  Timer? _interstitialTimer;

  List<String> listings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
    _loadBannerAds();
    _loadInterstitialAd();

    // Timer untuk menampilkan interstitial tiap 3 menit
    _interstitialTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      _showInterstitialAd();
    });
  }

  Future<void> _loadContent() async {
    try {
      final response = await http.get(
        Uri.parse("https://dannycawan.github.io/site/"),
      );
      if (response.statusCode == 200) {
        final document = html.parse(response.body);
        final items = document.querySelectorAll("li");
        setState(() {
          listings = items.map((e) => e.text.trim()).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error load site: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadBannerAds() {
    _bannerAdTop = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();

    _bannerAdBottom = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint("Interstitial failed: $error");
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
    super.dispose();
  }

  Widget _buildInlineBanner() {
    final BannerAd inlineBanner = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.mediumRectangle, // lebih besar dari banner biasa
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: SizedBox(
        height: inlineBanner.size.height.toDouble(),
        width: inlineBanner.size.width.toDouble(),
        child: AdWidget(ad: inlineBanner),
      ),
    );
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
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      if (index > 0 && index % 3 == 0) {
                        // setiap 3 item → sisipkan iklan banner
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(title: Text(listings[index])),
                            _buildInlineBanner(),
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
