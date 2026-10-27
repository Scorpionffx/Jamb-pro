import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  UnityAds.init(gameId: '5433647', testMode: true); // Replace with your Unity Game ID later
  runApp(const JambPro());
}

class AdIds {
  // AdMob TEST IDs - Replace with yours for real money
  static const admobBanner = "ca-app-pub-3940256099942544/6300978111";
  static const admobInter = "ca-app-pub-3940256099942544/1033173712";
  static const admobRewarded = "ca-app-pub-3940256099942544/5224354917";
  static const admobAppOpen = "ca-app-pub-3940256099942544/9257395921";
  // Unity TEST
  static const unityRewarded = "Rewarded_Android";
  static const unityInter = "Interstitial_Android";
}

class JambPro extends StatelessWidget {
  const JambPro({super.key});
  @override Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false, home: Splash());
}

class Splash extends StatefulWidget { const Splash({super.key}); @override State<Splash> createState()=>_SplashState(); }
class _SplashState extends State<Splash> {
  AppOpenAd? ad;
  @override void initState(){
    super.initState();
    AppOpenAd.load(adUnitId: AdIds.admobAppOpen, request: AdRequest(), adLoadCallback: AppOpenAdLoadCallback(onAdLoaded:(a)=>ad=a, onAdFailedToLoad:(e)=>{}));
    Future.delayed(Duration(seconds:3),(){ ad?.show(); Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>Home()));});
  }
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor: Color(0xFF5B3DF6), body: Center(child: Column(mainAxisAlignment:MainAxisAlignment.center, children:[Icon(Icons.school, size:80, color:Colors.white), Text("JAMB PRO ULTIMATE", style:TextStyle(color:Colors.white, fontSize:26, fontWeight:FontWeight.bold)), SizedBox(height:10), Text("3 Ad Networks + Paystack", style:TextStyle(color:Colors.white70)), SizedBox(height:20), CircularProgressIndicator(color:Colors.white)])));
}

class Home extends StatefulWidget { const Home({super.key}); @override State<Home> createState()=>_HomeState(); }
class _HomeState extends State<Home> {
  BannerAd? banner; InterstitialAd? inter; int coins=100; bool isPremium=false;

  @override void initState(){
    super.initState();
    load();
    banner=BannerAd(adUnitId: AdIds.admobBanner, size: AdSize.banner, request: AdRequest(), listener: BannerAdListener())..load();
    InterstitialAd.load(adUnitId: AdIds.admobInter, request: AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded:(a)=>inter=a, onAdFailedToLoad:(e)=>{}));
  }
  load() async { final p=await SharedPreferences.getInstance(); setState((){ coins=p.getInt('coins')??100; isPremium=p.getBool('premium')??false; }); }
  saveCoins(int n) async { final p=await SharedPreferences.getInstance(); await p.setInt('coins', coins+n); setState(()=>coins+=n); }

  showAdmobInter(){ inter?.show(); InterstitialAd.load(adUnitId: AdIds.admobInter, request: AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded:(a)=>inter=a, onAdFailedToLoad:(e)=>{})); }
  showAdmobReward(){ RewardedAd.load(adUnitId: AdIds.admobRewarded, request: AdRequest(), rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded:(a)=>a.show(onUserEarnedReward:(ad,rew){ saveCoins(25); }), onAdFailedToLoad:(e)=>{})); }
  showUnityReward(){ UnityAds.showVideoAd(placementId: AdIds.unityRewarded, onComplete: (_)=>saveCoins(30), onFailed: (a,e,m)=>{}); }
  showUnityInter(){ UnityAds.showVideoAd(placementId: AdIds.unityInter, onComplete: (_){}, onFailed: (a,e,m)=>{}); }

  // MONETIZATION LINKS
  openPaystack() async { final url=Uri.parse("https://paystack.shop/pay/jambpro-premium"); if(await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication); }
  openJumia() async { final url=Uri.parse("https://www.jumia.com.ng/catalog/?q=jamb+textbook"); if(await canLaunchUrl(url)) await launchUrl(url); }
  openSponsor() async { final url=Uri.parse("https://wa.me/234000000000?text=I%20want%20to%20advertise%20my%20tutorial%20in%20JAMB%20PRO"); if(await canLaunchUrl(url)) await launchUrl(url); }

  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("JAMB PRO • $coins • ${isPremium?'PREMIUM':''}"), backgroundColor: Color(0xFF5B3DF6), foregroundColor: Colors.white),
      body: Column(children:[
        Expanded(child: ListView(padding:EdgeInsets.all(14), children:[
          // SPONSORSHIP BANNER - Direct Money N10k/month
          GestureDetector(onTap: openSponsor, child: Container(padding:EdgeInsets.all(12), decoration:BoxDecoration(color: Colors.amber[100], borderRadius:BorderRadius.circular(12), border: Border.all(color: Colors.amber)), child: Row(children:[Icon(Icons.campaign, color: Colors.orange), SizedBox(width:10), Expanded(child: Text("SPONSORED: Best CBT Center in Lagos - Click to Advertise YOUR Center N10k/month", style:TextStyle(fontWeight:FontWeight.bold, fontSize:12)))]))),

          SizedBox(height:12),
          Container(padding:EdgeInsets.all(18), decoration:BoxDecoration(gradient:LinearGradient(colors:[Color(0xFF5B3DF6), Color(0xFFEC4899)]), borderRadius:BorderRadius.circular(16)), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text("Score 350+ in JAMB", style:TextStyle(color:Colors.white, fontSize:20, fontWeight:FontWeight.bold)), Text("3 Ad Networks = 3x Revenue", style:TextStyle(color:Colors.white70))])),
          
          SizedBox(height:12),
          // AD NETWORK BUTTONS
          Text("ADMONETIZATION (AdMob + Unity + AppLovin via Mediation):", style:TextStyle(fontWeight:FontWeight.bold)),
          SizedBox(height:8),
          Row(children:[Expanded(child: ElevatedButton(onPressed: showAdmobInter, child: Text("AdMob Inter\n\$5/1000"))), SizedBox(width:8), Expanded(child: ElevatedButton(onPressed: showUnityInter, style: ElevatedButton.styleFrom(backgroundColor: Colors.black), child: Text("Unity Inter\n\$4/1000")))]),
          SizedBox(height:8),
          Row(children:[Expanded(child: ElevatedButton(onPressed: showAdmobReward, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF5B3DF6)), child: Text("AdMob Rewarded\n\$12/1000 +25 Coins"))), SizedBox(width:8), Expanded(child: ElevatedButton(onPressed: showUnityReward, style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple), child: Text("Unity Rewarded\n\$8/1000 +30 Coins")))]),

          Divider(height:30),
          Text("DIRECT MONETIZATION:", style:TextStyle(fontWeight:FontWeight.bold)),
          SizedBox(height:8),
          // PAYSTACK
          Card(color: Colors.green[50], child: ListTile(leading: Icon(Icons.payment, color: Colors.green), title: Text("Unlock Premium N1500 (Paystack)"), subtitle: Text("Remove Ads + 10k Questions"), trailing: Icon(Icons.arrow_forward), onTap: openPaystack)),
          // SUBSCRIPTION
          Card(color: Colors.blue[50], child: ListTile(leading: Icon(Icons.subscriptions, color: Colors.blue), title: Text("Subscribe N500/month"), subtitle: Text("Google Play Billing - Monthly Recurring"), onTap: ()=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Add your Play Console subscription ID in code"))))),
          // AFFILIATE
          Card(color: Colors.orange[50], child: ListTile(leading: Icon(Icons.shopping_bag, color: Colors.orange), title: Text("Buy JAMB Textbooks (Jumia Affiliate - Earn 8%)"), subtitle: Text("You earn per sale"), trailing: Icon(Icons.open_in_new), onTap: openJumia)),

          SizedBox(height:12),
          ElevatedButton.icon(onPressed: (){ saveCoins(Random().nextInt(20)+10); showAdmobReward(); }, icon: Icon(Icons.casino), label: Text("Spin & Win + Watch Ad (Highest eCPM)")),
        ])),
        if(banner!=null) Container(height:50, child: AdWidget(ad:banner!)),
        Container(padding:EdgeInsets.all(6), color: Colors.black12, child: Text("AppLovin active via AdMob Mediation - Add AppLovin ID in AdMob Dashboard for 3rd network", style:TextStyle(fontSize:10), textAlign:TextAlign.center)),
      ]),
    );
  }
}
