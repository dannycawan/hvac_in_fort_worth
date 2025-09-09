import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import 'flutter_data.dart'; // hasil generate dari script Python

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
      title: 'HVAC in Fort Worth',
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
  // AdMob Ad Units (ganti dengan unit ID milikmu di AdMob)
  final String bannerAdUnitId = "ca-app-pub-3940256099942544/6300978111"; // test ID
  final String interstitialAdUnitId = "ca-app-pub-3940256099942544/1033173712"; // test ID

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  Timer? _interstitialTimer;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();

    // tampilkan interstitial otomatis setelah 2 menit
    _interstitialTimer = Timer(const Duration(minutes: 2), () {
      _showInterstitialAd();
    });
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
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
        onAdFailedToLoad: (error) => debugPrint("Interstitial failed: $error"),
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
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _interstitialTimer?.cancel();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tidak bisa membuka: $url")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HVAC in Fort Worth"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Banner atas
          if (_bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),

          // List data dari flutter_data.dart
          Expanded(
            child: ListView.builder(
              itemCount: hvacData.length,
              itemBuilder: (context, index) {
                final item = hvacData[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(item["name"] ?? "No Name",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item["address_full"] ?? ""),
                        Text("â­ ${item["rating"]} (${item["reviews_count"]} reviews)"),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "map" && (item["map_url"] ?? "").isNotEmpty) {
                          _launchUrl(item["map_url"]);
                        } else if (value == "website" && (item["website"] ?? "").isNotEmpty) {
                          _launchUrl(item["website"]);
                        } else if (value == "phone" && (item["phone_number"] ?? "").isNotEmpty) {
                          _launchUrl("tel:${item["phone_number"]}");
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: "map", child: Text("ðŸ“ Maps")),
                        const PopupMenuItem(value: "website", child: Text("ðŸŒ Website")),
                        const PopupMenuItem(value: "phone", child: Text("ðŸ“ž Call")),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Banner bawah
          if (_bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
