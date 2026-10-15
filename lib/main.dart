import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() async { WidgetsFlutterBinding.ensureInitialized(); await MobileAds.instance.initialize(); runApp(const PuzzleGardenApp()); }
class PuzzleGardenApp extends StatelessWidget { const PuzzleGardenApp({super.key}); @override Widget build(BuildContext context) { return MaterialApp(debugShowCheckedModeBanner: false, title: 'Puzzle Garden', theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF4CAF50)), scaffoldBackgroundColor: Color(0xFFFBF8F0)), home: const HomeScreen()); } }
class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState() => _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  InterstitialAd? inter; RewardedAd? reward; int levelCount=0; int solved=0; List puzzles=[]; bool ready=false;
  @override void initState(){ super.initState(); load(); }
  Future<void> load() async { final prefs = await SharedPreferences.getInstance(); solved = prefs.getInt('solved')??0; final s = await rootBundle.loadString('assets/puzzles.json'); puzzles = json.decode(s); InterstitialAd.load(adUnitId: 'ca-app-pub-3940256099942544/1033173712', request: AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad)=>inter=ad, onAdFailedToLoad: (e){})); RewardedAd.load(adUnitId: 'ca-app-pub-3940256099942544/5224354917', request: AdRequest(), rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad)=>reward=ad, onAdFailedToLoad: (e){})); setState(()=>ready=true); }
  void showInterIfNeeded(){ levelCount++; if(levelCount%2==0 && inter!=null){ inter!.fullScreenContentCallback=FullScreenContentCallback(onAdDismissedFullScreenContent: (ad){ad.dispose(); InterstitialAd.load(adUnitId: 'ca-app-pub-3940256099942544/1033173712', request: AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (a)=>inter=a, onAdFailedToLoad: (e)=>{}));}, onAdFailedToShowFullScreenContent: (ad,e){ad.dispose();}); inter!.show(); inter=null; } }
  @override Widget build(BuildContext context){
    if(!ready) return Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(body: SafeArea(child: SingleChildScrollView(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(0xFF4CAF50))), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('PUZZLE GARDEN', style: TextStyle(fontSize: 11, letterSpacing: 2, color: Colors.grey)), Text('Relax. Think. Grow.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)))])), Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)), child: Text('🌸 $solved solved', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))])),
      SizedBox(height: 12), Text('${puzzles.length} puzzles • 4x4 → 5x5 → 6x6', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      SizedBox(height: 20), Text('Choose a Garden', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), Text('Meadow 4x4 → Hill 5x5 → Peak 6x6', style: TextStyle(color: Colors.grey[600], fontSize: 13)), SizedBox(height: 16),
      GridView.count(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.15, children: [
        gardenCard('🌸','Flower Garden','21 levels • 4-6',0,Colors.pink[50]!), gardenCard('🐦','Bird Garden','21 levels • 4-6',1,Colors.blue[50]!), gardenCard('🦋','Butterfly','21 levels • 4-6',2,Colors.purple[50]!), gardenCard('🍄','Mushroom','21 levels • 4-6',3,Colors.orange[50]!), gardenCard('🐝','Bee Garden','21 levels • 4-6',4,Colors.yellow[50]!), gardenCard('🌿','Zen Garden','Coming soon',5,Colors.green[50]!,true),
      ]),
    ]))));
  }
  Widget gardenCard(String emoji, String title, String sub, int id, Color col, [bool locked=false]){
    return GestureDetector(onTap: locked?null:() async { showInterIfNeeded(); var list = puzzles.where((p)=>p['garden']==id).toList(); final res = await Navigator.push(context, MaterialPageRoute(builder: (_)=>PuzzleScreen(gardenId: id, gardenName: title, puzzles: list))); if(res==true){ final prefs = await SharedPreferences.getInstance(); int n=(prefs.getInt('solved')??0)+1; await prefs.setInt('solved', n); setState(()=>solved=n);} }, child: Container(decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.withOpacity(0.2))), padding: EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(emoji, style: TextStyle(fontSize: 28)), Spacer(), Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey[600])), if(locked) Icon(Icons.lock, size: 14, color: Colors.grey)])));
  }
}
class PuzzleScreen extends StatefulWidget { final int gardenId; final String gardenName; final List puzzles; const PuzzleScreen({super.key, required this.gardenId, required this.gardenName, required this.puzzles}); @override State<PuzzleScreen> createState() => _PuzzleScreenState(); }
class _PuzzleScreenState extends State<PuzzleScreen> {
  int idx=0; List<List<String>> board=[];
  @override void initState(){ super.initState(); if(widget.puzzles.isNotEmpty) load(0); }
  void load(int i){ var p=widget.puzzles[i]; setState((){ board=(p['board'] as List).map((r)=>(r as List).map((c)=>c.toString()).toList()).toList(); idx=i; }); }
  bool hasThreeInRow(List<String> line){ for(int j=0;j<line.length-2;j++){ if(line[j]!="" && line[j]==line[j+1] && line[j]==line[j+2]) return true; } return false; }
  void check(){
    if(board.any((r)=>r.any((c)=>c.isEmpty))){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fill all empty cells first'))); return; }
    var p=widget.puzzles[idx]; var syms=p['symbols'] as List; String a=syms[0].toString(); String b=syms[1].toString(); int size=p['size']; int world=p['world']; bool ok=true; String fail="";
    for(int r=0;r<size;r++){ int ca=board[r].where((c)=>c==a).length; int cb=board[r].where((c)=>c==b).length; if(size%2==0){ if(ca!=size~/2 || cb!=size~/2){ ok=false; fail="Row ${r+1} needs ${size~/2} of each"; break; } } else { if((ca!=2||cb!=3) && (ca!=3||cb!=2)){ ok=false; fail="Row ${r+1} needs 2+3 mix"; break; } } }
    if(ok){ for(int c=0;c<size;c++){ int ca=0,cb=0; for(int r=0;r<size;r++){ if(board[r][c]==a) ca++; if(board[r][c]==b) cb++; } if(size%2==0){ if(ca!=size~/2 || cb!=size~/2){ ok=false; fail="Column ${c+1} needs ${size~/2} of each"; break; } } else { if((ca!=2||cb!=3) && (ca!=3||cb!=2)){ ok=false; fail="Column ${c+1} needs 2+3 mix"; break; } } } }
    if(ok && world>=1){ for(int r=0;r<size;r++){ if(hasThreeInRow(board[r])){ ok=false; fail="Row ${r+1} has 3 same in a row"; break; } } if(ok){ for(int c=0;c<size;c++){ List<String> col=[for(int rr=0;rr<size;rr++) board[rr][c]]; if(hasThreeInRow(col)){ ok=false; fail="Column ${c+1} has 3 same in a row"; break; } } } }
    if(ok){ showDialog(context: context, builder: (_)=>AlertDialog(title: Text('🌸 ${p['world_name']} Complete!'), content: Text('Level ${p['level_in_world']}/7 • ${size}x$size solved'), actions: [TextButton(onPressed: (){ Navigator.pop(context); if(idx<widget.puzzles.length-1) load(idx+1); else Navigator.pop(context,true); }, child: Text(idx<widget.puzzles.length-1?'Next Level':'Garden Complete!'))])); } else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(fail))); }
  }
  @override Widget build(BuildContext context){
    if(board.isEmpty) return Scaffold(body: Center(child: Text('No puzzles')));
    var p=widget.puzzles[idx]; int size=p['size']; var syms=p['symbols'] as List; String worldName=p['world_name']; int levelInWorld=p['level_in_world']; int global=p['level_global']; String diff=p['difficulty'];
    Color worldColor=[Colors.green[100]!, Colors.yellow[100]!, Colors.orange[100]!][p['world']];
    return Scaffold(
      appBar: AppBar(title: Text(widget.gardenName), backgroundColor: Color(0xFFFBF8F0)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.fromLTRB(12,12,12,0), child: Column(children: [
              Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: worldColor, borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$worldName • Level $levelInWorld/7 • ${size}x$size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text('$diff • Global $global/21 • ${p['blanks']} blanks', style: TextStyle(fontSize: 10, color: Colors.grey[700]))]), Text(['🌱','⛰️','🏔️'][p['world']], style: TextStyle(fontSize: 20))]) ),
              SizedBox(height: 8),
              Text(size==4?'Each row/col: 2 of each':size==5?'Each row/col: 2+3 mix • No 3 same':'Each row/col: 3 of each • No 3 same', style: TextStyle(fontSize: 11)),
              SizedBox(height: 8),
              LinearProgressIndicator(value: global/21, backgroundColor: Colors.grey[200], color: Color(0xFF4CAF50)), SizedBox(height: 4), Text('$global / 21 in this garden', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ])),
            SizedBox(height: 12),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.withOpacity(0.2))),
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: size, childAspectRatio: 1, crossAxisSpacing: 2, mainAxisSpacing: 2),
                        padding: EdgeInsets.all(6),
                        itemCount: size*size,
                        itemBuilder: (c,i){
                          int r=i~/size; int co=i%size;
                          bool isEmpty = board[r][co].isEmpty;
                          return GestureDetector(
                            onTap: (){ setState((){ String a=syms[0].toString(); String b=syms[1].toString(); if(board[r][co]=='') board[r][co]=a; else if(board[r][co]==a) board[r][co]=b; else board[r][co]=''; }); },
                            child: Container(
                              decoration: BoxDecoration(color: isEmpty?Color(0xFFFFF9C4):Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8), border: Border.all(color: isEmpty?Colors.orange.withOpacity(0.5):Colors.grey[300]!)),
                              child: Center(child: Text(board[r][co], style: TextStyle(fontSize: size==6?16:size==5?18:22))),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).padding.bottom/2),
          child: SizedBox(height: 54, width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4CAF50), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), onPressed: check, child: Text('Check Garden', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
        ),
      ),
    );
  }
}
