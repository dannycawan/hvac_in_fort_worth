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
  List<Map<String, String>> listings = [];

  // AdMob IDs
  final String bannerAdUnitId = "ca-app-pub-6721734106426198/5259469376";
  final String interstitialAdUnitId = "ca-app-pub-6721734106426198/7710531994";

  BannerAd? _bannerAdTop;
  BannerAd? _bannerAdBottom;
  InterstitialAd? _interstitialAd;
  Timer? _interstitialTimer;

  @override
  void initState() {
    super.initState();
    _fetchListings();

    // Load Ads
    _loadBannerAds();
    _loadInterstitialAd();

    // Timer untuk interstitial
    _interstitialTimer = Timer(const Duration(minutes: 3), () {
      _showInterstitialAd();
    });
  }

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
    _bannerAdTop?.dispose();
    _bannerAdBottom?.dispose();
    _interstitialAd?.dispose();
    _interstitialTimer?.cancel();
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
            ),
        ],
      ),
    );
  }
}
