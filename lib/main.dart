import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import 'flutter_data.dart';

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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
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
  // Ganti dengan unit ID milikmu di AdMob untuk produksi
  final String bannerAdUnitId = "ca-app-pub-3940256099942544/6300978111";
  final String interstitialAdUnitId = "ca-app-pub-3940256099942544/1033173712";
  final String nativeAdUnitId = "ca-app-pub-3940256099942544/2247696110";

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  Timer? _interstitialTimer;

  // Filter dan Pencarian
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  double _minRating = 0.0;

  // Native Ad related
  final List<NativeAd> _nativeAds = [];
  final int _adInterval = 5; // Tampilkan iklan setiap 5 item data

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();
    _loadNativeAds();

    _interstitialTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _showInterstitialAd();
    });

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('BannerAd loaded.'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('InterstitialAd loaded.');
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  _loadInterstitialAd();
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  debugPrint('InterstitialAd failed to show: $error');
                  ad.dispose();
                  _loadInterstitialAd();
                },
              );
        },
        onAdFailedToLoad: (error) => debugPrint("Interstitial failed: $error"),
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      debugPrint('InterstitialAd not ready yet.');
    }
  }

  void _loadNativeAds() {
    for (int i = 0; i < (hvacData.length / _adInterval).ceil(); i++) {
      final nativeAd = NativeAd(
        adUnitId: nativeAdUnitId,
        factoryId: 'listTile',
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('NativeAd loaded: ${ad.adUnitId}');
            setState(() {
              _nativeAds.add(ad as NativeAd);
            });
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('NativeAd failed to load: $error');
            ad.dispose();
          },
        ),
      );
      nativeAd.load();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _interstitialTimer?.cancel();
    _searchController.dispose();
    for (var ad in _nativeAds) {
      ad.dispose();
    }
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Tidak bisa membuka: $url")));
    }
  }

  List<Map<String, dynamic>> get _filteredHvacData {
    return hvacData.where((item) {
      final name = item["name"]?.toLowerCase() ?? '';
      final address = item["address_full"]?.toLowerCase() ?? '';
      final rating = double.tryParse(item["rating"] ?? '0.0') ?? 0.0;

      final matchesSearch =
          _searchText.isEmpty ||
          name.contains(_searchText.toLowerCase()) ||
          address.contains(_searchText.toLowerCase());

      final matchesRating = rating >= _minRating;

      return matchesSearch && matchesRating;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HVAC in Fort Worth"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
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

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari berdasarkan nama atau alamat',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),

          Expanded(
            child: _filteredHvacData.isEmpty
                ? const Center(child: Text('Tidak ada data yang ditemukan.'))
                : ListView.builder(
                    itemCount:
                        _filteredHvacData.length + (_nativeAds.length * 1),
                    itemBuilder: (context, index) {
                      final int dataIndex = index - (index ~/ _adInterval);

                      if (index > 0 && index % _adInterval == 0) {
                        final int adIndex = (index ~/ _adInterval) - 1;
                        if (adIndex < _nativeAds.length) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            height: 300,
                            child: AdWidget(ad: _nativeAds[adIndex]),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      } else if (dataIndex < _filteredHvacData.length) {
                        final item = _filteredHvacData[dataIndex];
                        final rating = item["rating"] ?? "N/A";
                        final reviewsCount = item["reviews_count"] ?? "0";
                        final phoneNumber = item["phone_number"] ?? "";
                        final website = item["website"] ?? "";
                        final mapUrl = item["map_url"] ?? "";

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["name"] ?? "No Name",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item["address_full"] ??
                                      "Alamat tidak tersedia",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700], // HAPUS const
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$rating ($reviewsCount reviews)',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ), // Bisa tetap const karena tidak pakai Colors.grey[xxx]
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: [
                                    if (phoneNumber.isNotEmpty)
                                      ActionChip(
                                        avatar: const Icon(
                                          Icons.phone,
                                          size: 18,
                                        ),
                                        label: const Text('Telepon'),
                                        onPressed: () =>
                                            _launchUrl('tel:$phoneNumber'),
                                      ),
                                    if (website.isNotEmpty)
                                      ActionChip(
                                        avatar: const Icon(
                                          Icons.public,
                                          size: 18,
                                        ),
                                        label: const Text('Website'),
                                        onPressed: () => _launchUrl(website),
                                      ),
                                    if (mapUrl.isNotEmpty)
                                      ActionChip(
                                        avatar: const Icon(Icons.map, size: 18),
                                        label: const Text('Peta'),
                                        onPressed: () => _launchUrl(mapUrl),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
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

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Rating Minimal:'),
                Slider(
                  value: _minRating,
                  min: 0.0,
                  max: 5.0,
                  divisions: 10,
                  label: _minRating.toStringAsFixed(1),
                  onChanged: (double value) {
                    setState(() {
                      _minRating = value;
                    });
                  },
                ),
                Text('Rating: ${_minRating.toStringAsFixed(1)} ke atas'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Terapkan'),
              onPressed: () {
                setState(() {}); // Trigger rebuild with new filter
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reset'),
              onPressed: () {
                setState(() {
                  _minRating = 0.0;
                  _searchController.clear();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
