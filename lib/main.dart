import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  FacebookAudienceNetwork.init();
  runApp(const JambPro());
}

// ================== PUT YOUR REAL IDs HERE AFTER APPROVAL ==================
class AdIds {
  // META - Get from business.facebook.com -> Monetization -> Audience Network
  static const metaBanner = "YOUR_META_BANNER_ID";
  static const metaInter = "YOUR_META_INTERSTITIAL_ID";
  static const metaRewarded = "YOUR_META_REWARDED_ID";

  // ADMOB - Get from admob.google.com - THESE ARE TEST IDs (App works but no real money yet)
  static const admobBanner = "ca-app-pub-3940256099942544/6300978111";
  static const admobInter = "ca-app-pub-3940256099942544/1033173712";
  static const admobRewarded = "ca-app-pub-3940256099942544/5224354917";
  static const admobAppOpen = "ca-app-pub-3940256099942544/9257395921"; // HIGHEST PAYING
}
// =============================================================================

class JambPro extends StatelessWidget {
  const JambPro({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primaryColor: Color(0xFF5B3DF6)),
      home: const SplashWithAppOpen(),
    );
  }
}

class SplashWithAppOpen extends StatefulWidget {
  const SplashWithAppOpen({super.key});
  @override
  State<SplashWithAppOpen> createState() => _SplashWithAppOpenState();
}

class _SplashWithAppOpenState extends State<SplashWithAppOpen> {
  AppOpenAd? appOpenAd;

  @override
  void initState() {
    super.initState();
    loadAppOpen();
    FacebookInterstitialAd.loadInterstitialAd(placementId: AdIds.metaInter, listener: (r,v){});
    Future.delayed(Duration(seconds: 3), () {
      appOpenAd?.show();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  void loadAppOpen() {
    AppOpenAd.load(
      adUnitId: AdIds.admobAppOpen,
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) => appOpenAd = ad,
        onAdFailedToLoad: (e) => print("AppOpen failed $e"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF5B3DF6),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.school_rounded, size: 80, color: Colors.white),
          SizedBox(height: 10),
          Text("JAMB PRO", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          Text("Score 350+ Without Stress", style: TextStyle(color: Colors.white70)),
          SizedBox(height: 30),
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 10),
          Text("Loading App Open Ad... Pays \$10/1000 views", style: TextStyle(color: Colors.white70, fontSize: 11))
        ]),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? admobBanner;
  InterstitialAd? admobInter;
  int coins = 50;
  bool noAds = false;
  String selected = "";
  bool showResult = false;

  @override
  void initState() {
    super.initState();
    loadData();
    loadAdmobBanner();
    loadAdmobInter();
  }

  void loadData() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      coins = p.getInt('coins') ?? 50;
      noAds = p.getBool('noAds') ?? false;
    });
  }

  void addCoins(int n) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('coins', coins + n);
    setState(() => coins += n);
  }

  void loadAdmobBanner() {
    admobBanner = BannerAd(
      adUnitId: AdIds.admobBanner,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(),
    )..load();
  }

  void loadAdmobInter() {
    InterstitialAd.load(
      adUnitId: AdIds.admobInter,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => admobInter = ad,
        onAdFailedToLoad: (e) => {},
      ),
    );
  }

  void showInterstitial() {
    if (noAds) return;
    admobInter?.show();
    FacebookInterstitialAd.showInterstitialAd();
    loadAdmobInter();
    FacebookInterstitialAd.loadInterstitialAd(placementId: AdIds.metaInter, listener: (r,v){});
  }

  void showRewarded() {
    if (noAds) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No Ads Mode Active - Explanation Unlocked")));
      return;
    }
    FacebookRewardedVideoAd.loadRewardedVideoAd(
      placementId: AdIds.metaRewarded,
      listener: (result, value) {
        if (result == RewardedVideoAdResult.VIDEO_COMPLETE) {
          addCoins(20);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Meta Rewarded Complete! +20 Coins - You earned \$0.008")));
        }
      },
    );
    FacebookRewardedVideoAd.showRewardedVideoAd();

    RewardedAd.load(
      adUnitId: AdIds.admobRewarded,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => ad.show(onUserEarnedReward: (ad, reward) {
          addCoins(20);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("AdMob Rewarded Complete! +20 Coins")));
        }),
        onAdFailedToLoad: (e) => {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("JAMB PRO • $coins Coins"),
        backgroundColor: Color(0xFF5B3DF6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.casino), tooltip: "Spin", onPressed: () {
            int win = Random().nextInt(100);
            addCoins(win);
            showRewarded();
          }),
          if (!noAds) IconButton(icon: Icon(Icons.block), tooltip: "Remove Ads", onPressed: () async {
            final p = await SharedPreferences.getInstance();
            await p.setBool('noAds', true);
            setState(()=> noAds = true);
          })
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF5B3DF6), Color(0xFFEC4899)]), borderRadius: BorderRadius.circular(20)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Score 350+ in JAMB\nWithout Stress", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Row(children: [
                      _smallBtn("Watch & Earn +20", Colors.green, showRewarded),
                      SizedBox(width: 8),
                      _smallBtn("Spin & Win", Colors.orange, (){ addCoins(Random().nextInt(50)); showRewarded(); }),
                    ])
                  ]),
                ),
                SizedBox(height: 16),
                Text("Q1: What is the S.I unit of Force?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                _option("A) Joule", "Joule"),
                _option("B) Newton", "Newton"),
                _option("C) Watt", "Watt"),
                _option("D) Pascal", "Pascal"),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF5B3DF6), foregroundColor: Colors.white, padding: EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    setState(()=> showResult = true);
                    showInterstitial();
                  },
                  child: Text("Submit - Show Interstitial Ad (AdMob + Meta)"),
                ),
                if (showResult) ...[
                  SizedBox(height: 10),
                  if (selected == "Newton") Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(10)), child: Text("Correct! Newton is unit of Force."))
                  else Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(10)), child: Text("Wrong! Correct is Newton.")),
                ],
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: EdgeInsets.all(16)),
                  onPressed: showRewarded,
                  child: Text("🔒 Watch 20s Ad to Unlock Full Explanation (Pays HIGHEST)"),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.yellow[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange)),
                  child: Text("💰 HOW YOU EARN (Better than others):\n1. App Open Ad = \$10 per 1000 views (When app opens)\n2. Rewarded Ad = \$10 per 1000 views (BEST)\n3. Interstitial = \$3 per 1000 views\n4. Banner = \$1 per 1000 views\n5. Coins System = User watches 10+ ads daily to earn coins\n\n🔥 EXTRA: Add Unity Ads + IronSource later to earn 2X more", style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
          if (!noAds) FacebookBannerAd(placementId: AdIds.metaBanner, bannerSize: BannerSize.STANDARD, listener: (r,v){}),
          if (!noAds && admobBanner != null) Container(height: 60, color: Colors.white, child: AdWidget(ad: admobBanner!)),
        ],
      ),
    );
  }

  Widget _smallBtn(String t, Color c, VoidCallback f) => Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 10)), onPressed: f, child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))));

  Widget _option(String title, String value) {
    bool isSelected = selected == value;
    return Card(
      color: isSelected ? Color(0xFF5B3DF6).withOpacity(0.1) : Colors.white,
      shape: RoundedRectangleBorder(side: BorderSide(color: isSelected ? Color(0xFF5B3DF6) : Colors.grey[300]!, width: isSelected ? 2 : 1), borderRadius: BorderRadius.circular(10)),
      child: RadioListTile<String>(title: Text(title), value: value, groupValue: selected, activeColor: Color(0xFF5B3DF6), onChanged: (v) => setState(()=> selected = v!)),
    );
  }
}
