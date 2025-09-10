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

/// Global App Open Ad reference
AppOpenAd? appOpenAd;

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
  // Ad Unit IDs
  final String bannerAdUnitId = "ca-app-pub-6721734106426198/5259469376";
  final String interstitialAdUnitId = "ca-app-pub-6721734106426198/7710531994";
  final String nativeAdUnitId = "ca-app-pub-6721734106426198/6120735266";
  final String appOpenAdUnitId = "ca-app-pub-6721734106426198/2181490258";

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  int _clickCount = 0;

  // Search & Filter
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  double _minRating = 0.0;
  double _maxRating = 5.0;
  double _minReviews = 0.0;
  double _maxReviews = 1000.0;

  // Native ads
  final List<NativeAd> _nativeAds = [];
  final int _adInterval = 2; // every 2 listings

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();
    _loadNativeAds();
    _loadAppOpenAd();

    // Delay App Open Ad 3 seconds once
    Future.delayed(const Duration(seconds: 3), () {
      if (appOpenAd != null) {
        appOpenAd!.show();
        appOpenAd = null; // only show once per session
      }
    });

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });

    // Dynamic max reviews from data
    final reviews = hvacData
        .map((item) => double.tryParse(item["reviews_count"] ?? '0') ?? 0)
        .toList();
    if (reviews.isNotEmpty) {
      _maxReviews = reviews.reduce((a, b) => a > b ? a : b);
    }
  }

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) => appOpenAd = ad,
        onAdFailedToLoad: (err) => appOpenAd = null,
      ),
    );
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('Banner loaded'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner failed: $error');
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
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (err) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    _clickCount++;
    if (_clickCount % 3 == 0 && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _loadInterstitialAd();
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
            setState(() {
              _nativeAds.add(ad as NativeAd);
            });
          },
          onAdFailedToLoad: (ad, error) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot open: $url")),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredHvacData {
    return hvacData.where((item) {
      final name = item["name"]?.toLowerCase() ?? '';
      final address = item["address_full"]?.toLowerCase() ?? '';
      final rating = double.tryParse(item["rating"] ?? '0.0') ?? 0.0;
      final reviews = double.tryParse(item["reviews_count"] ?? '0') ?? 0.0;

      final matchesSearch =
          _searchText.isEmpty ||
          name.contains(_searchText.toLowerCase()) ||
          address.contains(_searchText.toLowerCase());

      final matchesRating = rating >= _minRating && rating <= _maxRating;
      final matchesReviews = reviews >= _minReviews && reviews <= _maxReviews;

      return matchesSearch && matchesRating && matchesReviews;
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
                labelText: 'Search by name or address',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),

          Expanded(
            child: _filteredHvacData.isEmpty
                ? const Center(child: Text('No data found.'))
                : ListView.builder(
                    itemCount: _filteredHvacData.length + _nativeAds.length,
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

                        return GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                          },
                          child: Card(
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
                                        "Address not available",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
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
                                        style: const TextStyle(fontSize: 14),
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
                                          avatar: const Icon(Icons.phone,
                                              size: 18),
                                          label: const Text('Call'),
                                          onPressed: () =>
                                              _launchUrl('tel:$phoneNumber'),
                                        ),
                                      if (website.isNotEmpty)
                                        ActionChip(
                                          avatar: const Icon(Icons.public,
                                              size: 18),
                                          label: const Text('Website'),
                                          onPressed: () => _launchUrl(website),
                                        ),
                                      if (mapUrl.isNotEmpty)
                                        ActionChip(
                                          avatar: const Icon(Icons.map,
                                              size: 18),
                                          label: const Text('Map'),
                                          onPressed: () => _launchUrl(mapUrl),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
          ),

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
                const Text('Rating Range:'),
                RangeSlider(
                  values: RangeValues(_minRating, _maxRating),
                  min: 0,
                  max: 5,
                  divisions: 5,
                  labels: RangeLabels(
                    _minRating.toStringAsFixed(1),
                    _maxRating.toStringAsFixed(1),
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _minRating = values.start;
                      _maxRating = values.end;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Reviews Range:'),
                RangeSlider(
                  values: RangeValues(_minReviews, _maxReviews),
                  min: 0,
                  max: _maxReviews,
                  divisions: 10,
                  labels: RangeLabels(
                    _minReviews.toStringAsFixed(0),
                    _maxReviews.toStringAsFixed(0),
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _minReviews = values.start;
                      _maxReviews = values.end;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Apply'),
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reset'),
              onPressed: () {
                setState(() {
                  _minRating = 0.0;
                  _maxRating = 5.0;
                  _minReviews = 0.0;
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