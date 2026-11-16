import 'dart:math';
import 'package:flutter/material.dart';
import 'fruit_sudoku_garden.dart';

void main() => runApp(const PuzzleGardenApp());
class PuzzleGardenApp extends StatelessWidget {
  const PuzzleGardenApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(title: 'Puzzle Garden', theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green), home: const HomeScreen(), debugShowCheckedModeBanner: false);
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override Widget build(BuildContext context) {
    final gardens = [
      {'emoji':'🌷','title':'Flower Garden','sub':'Takuzu • 21 levels','color':Colors.pink,'page':const FlowerPage()},
      {'emoji':'🌸','title':'Sakura Garden','sub':'Memory • 15 levels','color':Colors.purple,'page':const SakuraPage()},
      {'emoji':'🍃','title':'Zen Rake Garden','sub':'Path • 20 levels','color':Colors.teal,'page':const ZenPage()},
      {'emoji':'🐟','title':'Koi Path Garden','sub':'Slide • 18 levels','color':Colors.blue,'page':const KoiPage()},
      {'emoji':'🍓','title':'Fruit Sudoku Garden','sub':'Sudoku • 15 levels • HOT','color':Colors.orange,'page':const FruitSudokuGarden()},
    ];
    return Scaffold(appBar: AppBar(title: const Text('Puzzle Garden'), centerTitle: true), body: Column(children: [
      Container(width: double.infinity, margin: const EdgeInsets.all(12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(16)), child: const Column(children: [Text('🌿 Puzzle Garden', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Relax. Think. Grow.', style: TextStyle(fontSize: 14)), SizedBox(height: 8), Text('5 in 1 • 89 Puzzles • 5 Gardens', style: TextStyle(fontWeight: FontWeight.w600))])),
      Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: gardens.length, itemBuilder: (_, i){
        final g = gardens[i];
        return Card(color: (g['color'] as Color).withOpacity(0.12), child: ListTile(leading: Text(g['emoji'] as String, style: const TextStyle(fontSize: 32)), title: Text(g['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(g['sub'] as String), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>g['page'] as Widget))));
      })),
    ]));
  }
}

void showHow(BuildContext ctx, String title, String body){
  showDialog(context: ctx, builder: (_)=>AlertDialog(title: Text(title), content: Text(body), actions: [TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('Got it'))]));
}

// FLOWER
class FlowerPage extends StatefulWidget { const FlowerPage({super.key}); @override State<FlowerPage> createState()=>_FlowerState(); }
class _FlowerState extends State<FlowerPage> {
  List<List<int>> b=[]; int level=1; String msg='Fill all tiles, then tap CHECK';
  @override void initState(){ super.initState(); _new(); }
  void _new(){ b=List.generate(6, (_)=>List.generate(6, (_)=>Random().nextInt(3)-1)); msg='Level $level / 21 - Fill all, then tap CHECK'; setState((){}); }
  void _check(){
    if(b.any((r)=>r.contains(-1))){ setState(()=>msg='⚠️ Still empty tiles - fill all first'); return; }
    bool ok=true; String why='';
    for(int r=0;r<6;r++){ if(b[r].where((v)=>v==0).length!=3){ ok=false; why='Row ${r+1} needs 3 🌷 and 3 🌿'; break; } for(int c=0;c<4;c++){ if(b[r][c]==b[r][c+1]&&b[r][c]==b[r][c+2]){ ok=false; why='Row ${r+1} has 3 same in a row'; break; } } if(!ok) break; }
    if(!ok){ setState(()=>msg='❌ WRONG - $why'); return; }
    setState(()=>msg='🎉 CORRECT! Level $level done!');
    showDialog(context: context, builder: (_)=>AlertDialog(title: Text('🎉 Level $level Correct!'), content: const Text('Beautiful garden! Next level?'), actions: [TextButton(onPressed: (){ Navigator.pop(context); setState(()=>level=level<21?level+1:1); _new(); }, child: const Text('Next Level'))]));
  }
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text('🌷 Flower Garden - Level $level / 21'), actions: [IconButton(onPressed: ()=>showHow(context, '🌷 How to Play', 'Fill every tile with 🌷 or 🌿.\n1. Each row & column: 3 🌷 + 3 🌿\n2. No 3 same in a row\n3. No two rows identical\nTap tile: empty → 🌷 → 🌿 → empty'), icon: const Icon(Icons.help_outline))]), body: Column(children: [Padding(padding: const EdgeInsets.all(10), child: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))), Expanded(child: GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, crossAxisSpacing: 4, mainAxisSpacing: 4), itemCount: 36, itemBuilder: (_, i){ int r=i~/6,c=i%6,v=b[r][c]; return GestureDetector(onTap: ()=>setState(()=>b[r][c]=(v+2)%3-1), child: Container(decoration: BoxDecoration(color: v==-1?Colors.white:v==0?Colors.pink[100]:Colors.green[200], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black26)), child: Center(child: Text(v==-1?'':v==0?'🌷':'🌿', style: const TextStyle(fontSize: 20))))); })), SafeArea(child: Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(12, 12, 12, 20), child: Row(children: [Expanded(child: ElevatedButton(onPressed: _check, child: const Text('✓ CHECK - Am I Right?'))), const SizedBox(width: 8), ElevatedButton(onPressed: _new, child: const Text('New'))])))])); }
}

// SAKURA
class SakuraPage extends StatefulWidget { const SakuraPage({super.key}); @override State<SakuraPage> createState()=>_SakuraState(); }
class _SakuraState extends State<SakuraPage> {
  List<String> cards=[]; List<bool> flipped=[]; List<bool> matched=[]; int? first;
  @override void initState(){ super.initState(); _new(); }
  void _new(){ var base=['🌸','🌷','🌹','🌻','🌼','🌺']; cards=[...base, ...base]..shuffle(); flipped=List.filled(12,false); matched=List.filled(12,false); first=null; setState((){}); }
  bool _busy=false; void _tap(int i){ if(_busy) return; if(matched[i]){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Already matched - pick another card'))); return; } if(flipped[i]){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Already flipped - pick another'))); return; } setState(()=>flipped[i]=true); if(first==null){ first=i; } else { int f=first!; if(cards[f]==cards[i]){ setState(()=>matched[f]=matched[i]=true); } else { _busy=true; Future.delayed(const Duration(milliseconds: 700), ()=>setState(()=>{flipped[f]=false, flipped[i]=false, _busy=false})); } first=null; } }
  @override Widget build(BuildContext context){ int done=matched.where((m)=>m).length~/2; return Scaffold(appBar: AppBar(title: const Text('🌸 Sakura - Level 1 / 15'), actions: [IconButton(onPressed: ()=>showHow(context, '🌸 How to Play', 'Tap 2 cards to flip. If they match, they stay. If not, they flip back. Goal: Match all 6 pairs.'), icon: const Icon(Icons.help_outline))]), body: Column(children: [Padding(padding: const EdgeInsets.all(10), child: Text('Found $done / 6 pairs', style: const TextStyle(fontWeight: FontWeight.w600))), Expanded(child: GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 6, mainAxisSpacing: 6), itemCount: 12, itemBuilder: (_, i)=>GestureDetector(onTap: ()=>_tap(i), child: Container(decoration: BoxDecoration(color: matched[i]?Colors.pink[100]:Colors.pink[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black26)), child: Center(child: Text(flipped[i]||matched[i]?cards[i]:'🌸', style: const TextStyle(fontSize: 26))))))), SafeArea(child: Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(12, 12, 12, 20), child: Row(children: [Expanded(child: ElevatedButton(onPressed: ()=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done==6?'🎉 CORRECT! All 6 pairs!':'You found $done / 6 pairs - keep going!'))), child: const Text('✓ CHECK'))), const SizedBox(width: 8), ElevatedButton(onPressed: _new, child: const Text('New'))])))])); }
}

// ZEN
class ZenPage extends StatefulWidget { const ZenPage({super.key}); @override State<ZenPage> createState() => _ZenState(); }
class _ZenState extends State<ZenPage> {
  int s = 5;
  Set<int> path = {0};
  void _reset() { setState(() { path = {0}; }); }
  void _tap(int i) {
    int last = path.last;
    bool adjacent = (i - last).abs() == 1 || (i - last).abs() == s;
    if (!adjacent) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tap only the cell NEXT to you - up/down/left/right'))); return; } if (path.contains(i)) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Already raked - pick a new cell'))); return; } setState(() { path.add(i); });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🍃 Zen Rake - ${path.length} / ${s * s}'),
        actions: [IconButton(onPressed: () => showHow(context, '🍃 How to Play', 'Goal: Rake EVERY cell. Tap adjacent cell (up/down/left/right) to move. Cannot jump or revisit. Cover all, then tap CHECK.'), icon: const Icon(Icons.help_outline))],
      ),
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.all(10), child: Text('Tap adjacent cell to rake it', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: s, crossAxisSpacing: 4, mainAxisSpacing: 4),
              itemCount: s * s,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _tap(i),
                child: Container(
                  decoration: BoxDecoration(color: path.contains(i) ? Colors.teal[200] : Colors.brown[100], borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text(path.contains(i) ? '〰️' : '')),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(path.length == s * s ? '🎉 CORRECT! Fully raked!' : '❌ Not yet - ${path.length} / ${s * s}. Keep going!'))), child: const Text('✓ CHECK'))),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _reset, child: const Text('Reset')),
            ]),
          ),
        ],
      ),
    );
  }
}
// KOI

class KoiPage extends StatefulWidget { const KoiPage({super.key}); @override State<KoiPage> createState()=>_KoiState(); }
class _KoiState extends State<KoiPage> { List<int> t=[]; int m=0; @override void initState(){ super.initState(); _shuffle(); } void _shuffle(){ t=List.generate(16,(i)=>i); t.shuffle(); m=0; setState((){}); } void _tap(int i){ int e=t.indexOf(15); if((i-e).abs()==1&&(i~/4==e~/4)||(i-e).abs()==4){ setState(()=>{t[e]=t[i], t[i]=15, m++}); } } @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text('🐟 Koi Path - Moves $m'), actions: [IconButton(onPressed: ()=>showHow(context, '🐟 How to Play', 'Goal: Slide tiles to 1-15 in order. Tap tile next to empty space to slide. Tap CHECK to see if correct.'), icon: const Icon(Icons.help_outline))]), body: Column(children: [Expanded(child: GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 4, mainAxisSpacing: 4), itemCount: 16, itemBuilder: (_, i)=>GestureDetector(onTap: ()=>_tap(i), child: Container(decoration: BoxDecoration(color: t[i]==15?Colors.white:Colors.blue[100], borderRadius: BorderRadius.circular(8)), child: Center(child: Text(t[i]==15?'': '${t[i]+1}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))))))), SafeArea(child: Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(12, 12, 12, 20), child: Row(children: [Expanded(child: ElevatedButton(onPressed: (){ bool ok=true; for(int i=0;i<15;i++) if(t[i]!=i) ok=false; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok?'🎉 CORRECT! Koi path complete!':'❌ WRONG - not in order yet'))); }, child: const Text('✓ CHECK'))), const SizedBox(width: 8), ElevatedButton(onPressed: _shuffle, child: const Text('Shuffle'))])))])); } }
