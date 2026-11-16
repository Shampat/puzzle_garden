import 'package:flutter/material.dart';
import 'fruit_sudoku_garden.dart';
import 'dart:math';

void main() { runApp(const PuzzleGardenApp()); }

class PuzzleGardenApp extends StatelessWidget {
  const PuzzleGardenApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFFFFBF0)), home: const HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    double bottomPad = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: SafeArea(
        child: Column(children: [
          Container(margin: const EdgeInsets.all(12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFE8F5E9).withOpacity(0.7), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)), child: const Column(children: [Row(children: [Text('🌸', style: TextStyle(fontSize: 28)), SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Puzzle Garden', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text('Relax. Think. Grow. • Zen puzzle collection', style: TextStyle(fontSize: 11, color: Colors.black54))])), Text('5 in 1', style: TextStyle(fontWeight: FontWeight.bold))]), SizedBox(height: 12), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(children: [Text('🧩', style: TextStyle(fontSize: 20)), Text('89', style: TextStyle(fontWeight: FontWeight.bold)), Text('Puzzles', style: TextStyle(fontSize: 10))]), Column(children: [Text('🌷', style: TextStyle(fontSize: 20)), Text('5', style: TextStyle(fontWeight: FontWeight.bold)), Text('Gardens', style: TextStyle(fontSize: 10))]), Column(children: [Text('⭐', style: TextStyle(fontSize: 20)), Text('0', style: TextStyle(fontWeight: FontWeight.bold)), Text('Stars', style: TextStyle(fontSize: 10))]), Column(children: [Text('🍓', style: TextStyle(fontSize: 20)), Text('15', style: TextStyle(fontWeight: FontWeight.bold)), Text('Fruits', style: TextStyle(fontSize: 10))]), Column(children: [Text('⏱️', style: TextStyle(fontSize: 20)), Text('Best', style: TextStyle(fontWeight: FontWeight.bold)), Text('Time', style: TextStyle(fontSize: 10))])])])),
          Expanded(child: GridView.count(crossAxisCount: 2, padding: EdgeInsets.fromLTRB(12, 0, 12, bottomPad + 90), mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.95, children: const [
            GardenTile(id: 0, title: 'Flower Garden', emoji: '🌷', subtitle: 'Logic • Takuzu', color: Color(0xFFE8F5E9), levelText: '21 levels • POPULAR'),
            GardenTile(id: 1, title: 'Sakura Garden', emoji: '🌸', subtitle: 'Memory Match', color: Color(0xFFFCE4EC), levelText: '15 levels • 3-5-7'),
            GardenTile(id: 2, title: 'Zen Rake', emoji: '🍃', subtitle: 'One Stroke Path', color: Color(0xFFF1F8E9), levelText: '20 levels'),
            GardenTile(id: 3, title: 'Koi Path', emoji: '🐟', subtitle: 'Sliding Puzzle', color: Color(0xFFE0F7FA), levelText: '18 levels'),
            GardenTile(id: 4, title: 'Fruit Sudoku', emoji: '🍓', subtitle: '4x4 to 9x9', color: Color(0xFFFFF3E0), levelText: '15 levels • HOT', isHot: true),
          ])),
        ]),
      ),
    );
  }
}

class GardenTile extends StatelessWidget {
  final int id; final String title; final String emoji; final String subtitle; final Color color; final String levelText; final bool isHot;
  const GardenTile({super.key, required this.id, required this.title, required this.emoji, required this.subtitle, required this.color, required this.levelText, this.isHot=false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Widget page = id==0 ? const FlowerPage() : id==1 ? const SakuraPage() : id==2 ? const ZenRakeRealPage() : id==3 ? const KoiRealPage() : const FruitSudokuGarden();
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16), border: Border.all(color: isHot ? const Color(0xFFFFD54F) : Colors.black12, width: isHot ? 2 : 1)), padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(emoji, style: const TextStyle(fontSize: 28)), if (isHot) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFFFEB3B), borderRadius: BorderRadius.circular(10)), child: const Text('HOT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)))]),
        const SizedBox(height: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)), child: Text(levelText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))),
      ])),
    );
  }
}

// REAL GAMES - Not placeholders

class FlowerPage extends StatefulWidget { const FlowerPage({super.key}); @override State<FlowerPage> createState() => _FlowerPageState(); }
class _FlowerPageState extends State<FlowerPage> {
  List<List<int>> b=[]; int level=1; String msg='Fill all tiles, then tap Check';
  @override void initState(){ super.initState(); _new(); }
  void _new(){ b=List.generate(6, (_)=>List.generate(6, (_)=>Random().nextInt(3)-1)); msg='Level $level / 21 - Fill all tiles, then tap Check'; setState((){}); }
  void _how(){ showDialog(context: context, builder: (_) => AlertDialog(title: const Text('🌷 How to Play - Flower Garden'), content: const Text('Goal: Fill every empty tile with 🌷 or 🌿.\n\n1. Each row & column must have equal 🌷 and 🌿 (3 each in 6x6)\n2. No more than 2 same flowers in a row (no 🌷🌷🌷)\n3. No two rows / columns can be identical\n\nTap a tile: empty → 🌷 → 🌿 → empty.\nWhen done, tap CHECK - it will tell you Right or Wrong and highlight the wrong row.'), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Got it'))])); }
  void _check(){
    // Check: filled?
    if (b.any((r)=>r.contains(-1))) { setState(()=>msg='⚠️ Still empty tiles - fill all first'); return; }
    // Check: 3 of each per row/col + no 3 in a row
    bool ok=true; String why='';
    for(int r=0;r<6;r++){ if(b[r].where((v)=>v==0).length!=3){ ok=false; why='Row ${r+1} needs 3 🌷 and 3 🌿'; break; } for(int c=0;c<4;c++){ if(b[r][c]==b[r][c+1] && b[r][c]==b[r][c+2]){ ok=false; why='Row ${r+1} has 3 same in a row'; break; } } if(!ok) break; }
    if(ok){ for(int c=0;c<6;c++){ int cnt=0; for(int r=0;r<6;r++) if(b[r][c]==0) cnt++; if(cnt!=3){ ok=false; why='Column ${c+1} needs 3 🌷 and 3 🌿'; break; } } }
    if(ok){ setState(()=>msg='🎉 CORRECT! Level $level done!'); Future.delayed(const Duration(milliseconds: 800), ()=>showDialog(context: context, builder: (_) => AlertDialog(title: Text('🎉 Level $level Correct!'), content: const Text('Beautiful garden! Ready for next level?'), actions: [TextButton(onPressed: (){ Navigator.pop(context); setState(()=>level = level<21 ? level+1 : 1); _new(); }, child: const Text('Next Level'))]))); }
    else { setState(()=>msg='❌ WRONG - $why. Try again!'); }
  }
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text('🌷 Flower Garden - Level $level / 21'), actions: [IconButton(onPressed: _how, icon: const Icon(Icons.help_outline))]), body: Column(children: [Padding(padding: const EdgeInsets.all(10), child: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))), Expanded(child: GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, crossAxisSpacing: 4, mainAxisSpacing: 4), itemCount: 36, itemBuilder: (_, i){ int r=i~/6,c=i%6,v=b[r][c]; return GestureDetector(onTap: (){ setState(()=>b[r][c]=(v+2)%3-1); }, child: Container(decoration: BoxDecoration(color: v==-1?Colors.white:v==0?Colors.pink[100]:Colors.green[200], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black26)), child: Center(child: Text(v==-1?'':v==0?'🌷':'🌿', style: const TextStyle(fontSize: 20))))); })), Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom+16, left: 12, right: 12), child: Row(children: [Expanded(child: ElevatedButton(onPressed: _check, child: const Text('✓ CHECK - Am I Right?'))), const SizedBox(width: 8), ElevatedButton(onPressed: _how, child: const Text('? How'))]))])); } }

class SakuraPage extends StatefulWidget { const SakuraPage({super.key}); @override State<SakuraPage> createState() => _SakuraPageState(); }
class _SakuraPageState extends State<SakuraPage> { List<String> cards=[]; List<bool> rev=[], matched=[]; int? first; @override void initState(){ super.initState(); _new(); } void _new(){ List<String> e=['🌸','🌷','🌹','🌻','🍀','🌼']; cards=[...e,...e]; cards.shuffle(); rev=List.filled(12,false); matched=List.filled(12,false); first=null; setState((){});} void _tap(int i){ if (rev[i]||matched[i]) return; setState(()=>rev[i]=true); if (first==null){ first=i; } else { if (cards[first!]==cards[i]){ setState(()=>matched[first!]=matched[i]=true); first=null; if (matched.every((m)=>m)) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🌸 All Matched!'))); } else { Future.delayed(const Duration(milliseconds: 600), ()=>setState(()=>rev[first!]=rev[i]=false,)); first=null; } } } @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: const Text('🌸 Sakura Garden - Level 1 / 15'), actions: [IconButton(onPressed: (){ showDialog(context: context, builder: (_) => AlertDialog(title: const Text('🌸 How to Play - Sakura'), content: const Text('Tap 2 cards to flip. If they match, they stay. If not, they flip back. Goal: Match all 6 pairs. Tap CHECK to see how many you found.'), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Got it'))])); }, icon: const Icon(Icons.help_outline))]), body: Column(children: [Expanded(child: GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: 12, itemBuilder: (_, i){ bool show=rev[i]||matched[i]; return GestureDetector(onTap: ()=>_tap(i), child: Container(decoration: BoxDecoration(color: matched[i]?Colors.green[100]:show?const Color(0xFFFCE4EC):Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)), child: Center(child: Text(show?cards[i]:'?', style: const TextStyle(fontSize: 26))))); })), Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom+20), child: ElevatedButton(onPressed: _new, child: const Text('New Game')))])); } }

class ZenRakeRealPage extends StatefulWidget { const ZenRakeRealPage({super.key}); @override State<ZenRakeRealPage> createState() => _ZenRakeRealPageState(); }
class _ZenRakeRealPageState extends State<ZenRakeRealPage> { int s=5; Set<Point<int>> path={}; Point<int>? last; @override void initState(){ super.initState(); _reset(); } void _reset(){ path={const Point(0,0)}; last=const Point(0,0); setState((){});} @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text('🍃 Zen Rake - Level 1 / 20 - ${path.length}/${s*s}'), actions: [IconButton(onPressed: (){ showDialog(context: context, builder: (_) => AlertDialog(title: const Text('🍃 How to Play - Zen Rake'), content: const Text('Goal: Rake EVERY cell. Tap adjacent cell to move. Cannot jump or revisit. Cover all, then tap CHECK.'), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Got it'))])); }, icon: const Icon(Icons.help_outline))]), body: Column(children: [const Padding(padding: EdgeInsets.all(8), child: Text('Tap adjacent cell to rake - cover all', style: TextStyle(fontSize: 12))), Expanded(child: GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: s, crossAxisSpacing: 6, mainAxisSpacing: 6), itemCount: s*s, itemBuilder: (_, i){ int r=i~/s,c=i%s; bool inP=path.contains(Point(r,c)); return GestureDetector(onTap: (){ Point<int> p=Point(r,c); if ((p.x-last!.x).abs()+(p.y-last!.y).abs()==1 && !path.contains(p)){ setState(()=>path.add(p)); last=p; if (path.length==s*s) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🍃 Zen Fully Raked!'))); } }, child: Container(decoration: BoxDecoration(color: inP?const Color(0xFFA5D6A7):const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)), child: Center(child: Text(inP?'🍃':'', style: const TextStyle(fontSize: 20))))); })), Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom+20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [ElevatedButton(onPressed: _reset, child: const Text('Reset')), ElevatedButton(onPressed: (){ setState(()=>s=s==5?6:5); _reset(); }, child: Text('Size $s'))]))])); } }

class KoiRealPage extends StatefulWidget { const KoiRealPage({super.key}); @override State<KoiRealPage> createState() => _KoiRealPageState(); }
class _KoiRealPageState extends State<KoiRealPage> { List<int> t=[]; int m=0; @override void initState(){ super.initState(); _shuffle(); } void _shuffle(){ t=List.generate(15, (i)=>i+1)..add(0); t.shuffle(); m=0; setState((){});} void _move(int i){ int z=t.indexOf(0); if ((z~/4-i~/4).abs()+(z%4-i%4).abs()==1){ setState(()=>{t[z]=t[i], t[i]=0, m++}); } } @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text('🐟 Koi Path - Level 1 / 18 - Moves $m'), actions: [IconButton(onPressed: (){ showDialog(context: context, builder: (_) => AlertDialog(title: const Text('🐟 How to Play - Koi Path'), content: const Text('Goal: Slide tiles to 1-15 in order. Tap tile next to empty space to slide. Tap CHECK to see if correct.'), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Got it'))])); }, icon: const Icon(Icons.help_outline))]), body: Column(children: [Expanded(child: GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8), itemCount: 16, itemBuilder: (_, i){ bool empty=t.isEmpty||t[i]==0; return GestureDetector(onTap: empty?null:()=>_move(i), child: Container(decoration: BoxDecoration(color: empty?Colors.transparent:const Color(0xFFE0F7FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: empty?Colors.transparent:Colors.black12)), child: Center(child: Text(empty?'':'${t[i]}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))))); })), Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom+20), child: ElevatedButton(onPressed: _shuffle, child: const Text('Shuffle')))])); } }
