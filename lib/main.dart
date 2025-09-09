import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
<<<<<<< HEAD
import 'package:url_launcher/url_launcher.dart';

import 'flutter_data.dart'; // hasil generate dari script Python
=======
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
>>>>>>> origin/main

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
<<<<<<< HEAD
      title: 'HVAC in Fort Worth',
=======
      title: 'Commercial HVAC in Fort Worth',
>>>>>>> origin/main
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
<<<<<<< HEAD
  // AdMob Ad Units (ganti dengan unit ID milikmu di AdMob)
  final String bannerAdUnitId = "ca-app-pub-3940256099942544/6300978111"; // test ID
  final String interstitialAdUnitId = "ca-app-pub-3940256099942544/1033173712"; // test ID

  BannerAd? _bannerAd;
=======
  List<Map<String, String>> listings = [];

  // AdMob IDs
  final String bannerAdUnitId = "ca-app-pub-6721734106426198/5259469376";
  final String interstitialAdUnitId = "ca-app-pub-6721734106426198/7710531994";

  BannerAd? _bannerAdTop;
  BannerAd? _bannerAdBottom;
>>>>>>> origin/main
  InterstitialAd? _interstitialAd;
  Timer? _interstitialTimer;

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadBannerAd();
    _loadInterstitialAd();

    // tampilkan interstitial otomatis setelah 2 menit
    _interstitialTimer = Timer(const Duration(minutes: 2), () {
=======
    _fetchListings();

    // Load Ads
    _loadBannerAds();
    _loadInterstitialAd();

    // Timer untuk interstitial
    _interstitialTimer = Timer(const Duration(minutes: 3), () {
>>>>>>> origin/main
      _showInterstitialAd();
    });
  }

<<<<<<< HEAD
  void _loadBannerAd() {
    _bannerAd = BannerAd(
=======
  Future<void> _fetchListings() async {
    try {
      final response = await http.get(Uri.parse("https://dannycawan.github.io/site/"));
      if (response.statusCode == 200) {
        final document = html.parse(response.body);

        // Cari semua <tr> di tabel
        final rows = document.querySelectorAll("table tr");
        List<Map<String, String>> data = [];

        for (var row in rows.skip(1)) {
          final cols = row.querySelectorAll("td");
          if (cols.length >= 4) {
            data.add({
              "name": cols[0].text.trim(),
              "address": cols[1].text.trim(),
              "phone": cols[2].text.trim(),
              "map": cols[3].querySelector("a")?.attributes["href"] ?? "",
            });
          }
        }

        setState(() {
          listings = data;
        });
      }
    } catch (e) {
      debugPrint("Error fetch: $e");
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
>>>>>>> origin/main
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
<<<<<<< HEAD
    _bannerAd?.dispose();
=======
    _bannerAdTop?.dispose();
    _bannerAdBottom?.dispose();
>>>>>>> origin/main
    _interstitialAd?.dispose();
    _interstitialTimer?.cancel();
    super.dispose();
  }

<<<<<<< HEAD
  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tidak bisa membuka: $url")),
      );
    }
  }

=======
>>>>>>> origin/main
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text("HVAC in Fort Worth"),
=======
        title: const Text("Commercial HVAC in Fort Worth"),
>>>>>>> origin/main
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Banner atas
<<<<<<< HEAD
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
=======
          if (_bannerAdTop != null)
            SizedBox(
              height: _bannerAdTop!.size.height.toDouble(),
              width: _bannerAdTop!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAdTop!),
            ),

          // Konten daftar
          Expanded(
            child: listings.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final item = listings[index];
                      // Selipkan Native/ Banner placeholder tiap 3 item
                      if (index % 3 == 0 && index != 0) {
                        return Column(
                          children: [
                            ListTile(
                              title: Text(item["name"] ?? ""),
                              subtitle: Text("${item["address"]}\n${item["phone"]}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.map),
                                onPressed: () {
                                  final url = item["map"] ?? "";
                                  if (url.isNotEmpty) {
                                    // bisa tambahin url_launcher kalau mau buka Google Maps
                                  }
                                },
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Text("Native Ad Placeholder"), // nanti diganti NativeAdWidget
                            )
                          ],
                        );
                      }
                      return ListTile(
                        title: Text(item["name"] ?? ""),
                        subtitle: Text("${item["address"]}\n${item["phone"]}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.map),
                          onPressed: () {
                            final url = item["map"] ?? "";
                            if (url.isNotEmpty) {
                              // bisa tambahin url_launcher
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),

          // Banner bawah
          if (_bannerAdBottom != null)
            SizedBox(
              height: _bannerAdBottom!.size.height.toDouble(),
              width: _bannerAdBottom!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAdBottom!),
>>>>>>> origin/main
            ),
        ],
      ),
    );
  }
}
