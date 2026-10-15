import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const PuzzleGardenApp());
}

class PuzzleGardenApp extends StatelessWidget {
  const PuzzleGardenApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Puzzle Garden',
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF4CAF50)), scaffoldBackgroundColor: Color(0xFFFBF8F0)),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  InterstitialAd? inter;
  RewardedAd? reward;
  int levelCount = 0;
  int solved = 0;
  List puzzles = [];
  bool ready = false;

  @override
  void initState() { super.initState(); load(); }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    solved = prefs.getInt('solved')?? 0;
    final s = await rootBundle.loadString('assets/puzzles.json');
    puzzles = json.decode(s);
    InterstitialAd.load(adUnitId: 'ca-app-pub-3940256099942544/1033173712', request: AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) => inter = ad, onAdFailedToLoad: (e) => debugPrint('inter $e')));
    RewardedAd.load(adUnitId: 'ca-app-pub-3940256099942544/5224354917', request: AdRequest(), rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) => reward = ad, onAdFailedToLoad: (e) => debugPrint('reward $e')));
    setState(() => ready = true);
  }

  void showInterIfNeeded() {
    levelCount++;
    if (levelCount % 2 == 0 && inter!= null) {
      inter!.fullScreenContentCallback = FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) { ad.dispose(); InterstitialAd.load(adUnitId: 'ca-app-pub-3940256099942544/1033173712', request: AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (a) => inter = a, onAdFailedToLoad: (e) => {})); }, onAdFailedToShowFullScreenContent: (ad, e) { ad.dispose(); });
      inter!.show();
      inter = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) return Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(0xFF4CAF50))), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('PUZZLE GARDEN', style: TextStyle(fontSize: 11, letterSpacing: 2, color: Colors.grey)), Text('Relax. Think. Grow.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)))])), Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)), child: Text('🌸 $solved solved', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))])),
            SizedBox(height: 12),
            Text('${puzzles.length} puzzles • Ads every 2 gardens', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            SizedBox(height: 20),
            Text('Choose a Garden', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Same logic, different skin', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            SizedBox(height: 16),
            GridView.count(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.15, children: [
              gardenCard('🌸', 'Flower Garden', '${puzzles.where((p) => p['garden'] == 0).length} puzzles', 0, Colors.pink[50]!),
              gardenCard('🐦', 'Bird Garden', '${puzzles.where((p) => p['garden'] == 1).length} puzzles', 1, Colors.blue[50]!),
              gardenCard('🦋', 'Butterfly', '${puzzles.where((p) => p['garden'] == 2).length} puzzles', 2, Colors.purple[50]!),
              gardenCard('🍄', 'Mushroom', '${puzzles.where((p) => p['garden'] == 3).length} puzzles', 3, Colors.orange[50]!),
              gardenCard('🐝', 'Bee Garden', '${puzzles.where((p) => p['garden'] == 4).length} puzzles', 4, Colors.yellow[50]!),
              gardenCard('🌿', 'Zen Garden', 'Coming soon', 5, Colors.green[50]!, true),
            ]),
            SizedBox(height: 20),
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () { if (reward!= null) { reward!.show(onUserEarnedReward: (ad, r) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hint earned!'))); }); } }, child: Text('Watch Ad for Hint (Test Ad)'))),
          ]),
        ),
      ),
    );
  }

  Widget gardenCard(String emoji, String title, String sub, int id, Color col, [bool locked = false]) {
    return GestureDetector(
      onTap: locked? null : () async {
        showInterIfNeeded();
        var list = puzzles.where((p) => p['garden'] == id).toList();
        final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => PuzzleScreen(gardenId: id, gardenName: title, puzzles: list)));
        if (res == true) {
          final prefs = await SharedPreferences.getInstance();
          int n = (prefs.getInt('solved')?? 0) + 1;
          await prefs.setInt('solved', n);
          setState(() => solved = n);
        }
      },
      child: Container(decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.withOpacity(0.2))), padding: EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(emoji, style: TextStyle(fontSize: 28)), Spacer(), Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey[600])), if (locked) Icon(Icons.lock, size: 14, color: Colors.grey)])),
    );
  }
}

class PuzzleScreen extends StatefulWidget {
  final int gardenId; final String gardenName; final List puzzles;
  const PuzzleScreen({super.key, required this.gardenId, required this.gardenName, required this.puzzles});
  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  int idx = 0;
  List<List<String>> board = [];
  @override
  void initState() { super.initState(); if (widget.puzzles.isNotEmpty) load(0); }
  void load(int i) { var p = widget.puzzles[i]; setState(() { board = (p['board'] as List).map((r) => (r as List).map((c) => c.toString()).toList()).toList(); idx = i; }); }
  void check() {
    if (board.any((r) => r.any((c) => c.isEmpty))) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fill all cells'))); return; }
    var syms = widget.puzzles[idx]['symbols'] as List;
    String a = syms[0].toString(); String b = syms[1].toString();
    bool ok = true;
    for (int r = 0; r < 4; r++) { if (board[r].where((c) => c == a).length!= 2 || board[r].where((c) => c == b).length!= 2) ok = false; }
    for (int c = 0; c < 4; c++) { int x = 0, y = 0; for (int r = 0; r < 4; r++) { if (board[r][c] == a) x++; if (board[r][c] == b) y++; } if (x!= 2 || y!= 2) ok = false; }
    if (ok) {
      showDialog(context: context, builder: (_) => AlertDialog(title: Text('Complete'), content: Text('Puzzle ${idx + 1} solved'), actions: [TextButton(onPressed: () { Navigator.pop(context); if (idx < widget.puzzles.length - 1) load(idx + 1); else Navigator.pop(context, true); }, child: Text(idx < widget.puzzles.length - 1? 'Next' : 'Finish'))]));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Each row & column needs 2 of each')));
    }
  }
  @override
  Widget build(BuildContext context) {
    if (board.isEmpty) return Scaffold(body: Center(child: Text('No puzzles')));
    var syms = widget.puzzles[idx]['symbols'] as List;
    String a = syms[0].toString(); String b = syms[1].toString();
    return Scaffold(
      appBar: AppBar(title: Text('${widget.gardenName} ${idx + 1}/${widget.puzzles.length}'), backgroundColor: Color(0xFFFBF8F0)),
      body: Padding(padding: EdgeInsets.all(20), child: Column(children: [
        Text('Each row & column: 2 $a and 2 $b', textAlign: TextAlign.center),
        SizedBox(height: 20),
        AspectRatio(aspectRatio: 1, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.withOpacity(0.2))), child: GridView.builder(physics: NeverScrollableScrollPhysics(), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4), itemCount: 16, itemBuilder: (c, i) { int r = i ~/ 4; int co = i % 4; return GestureDetector(onTap: () { setState(() { if (board[r][co] == '') board[r][co] = a; else if (board[r][co] == a) board[r][co] = b; else board[r][co] = ''; }); }, child: Container(margin: EdgeInsets.all(4), decoration: BoxDecoration(color: board[r][co].isEmpty? Color(0xFFF5F5F5) : Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)), child: Center(child: Text(board[r][co], style: TextStyle(fontSize: 22))))); }))),
        SizedBox(height: 20),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4CAF50), foregroundColor: Colors.white), onPressed: check, child: Text('Check Garden'))),
      ])),
    );
  }
}
