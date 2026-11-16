import 'package:flutter/material.dart';

class FruitSudokuGarden extends StatefulWidget {
  const FruitSudokuGarden({super.key});
  @override
  State<FruitSudokuGarden> createState() => _FruitState();
}

class _FruitState extends State<FruitSudokuGarden> {
  List<List<int>> b = [
    [0, -1, -1, 3],
    [-1, 1, -1, -1],
    [-1, -1, 2, -1],
    [2, -1, -1, 0],
  ];
  int selected = 0;
  final fruits = ['🍓', '🍎', '🍊', '🍇'];

  void _how() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🍓 How to Play - Fruit Sudoku'),
        content: const Text('Goal: Fill every empty cell.\n\n1. Each ROW must have different fruits\n2. Each COLUMN must have different fruits\n3. Each 2x2 BOX must have different fruits\n\nTap an empty cell, then tap a fruit below.\nTap CHECK when done.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it'))],
      ),
    );
  }

  void _check() {
    if (b.any((r) => r.contains(-1))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Still empty cells - fill all first')));
      return;
    }
    bool ok = true;
    String why = '';
    for (int r = 0; r < 4; r++) {
      if (b[r].toSet().length != 4) { ok = false; why = 'Row ${r + 1} has duplicate fruit'; break; }
    }
    if (ok) {
      for (int c = 0; c < 4; c++) {
        var col = [b[0][c], b[1][c], b[2][c], b[3][c]];
        if (col.toSet().length != 4) { ok = false; why = 'Column ${c + 1} has duplicate fruit'; break; }
      }
    }
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 CORRECT! Fruit Sudoku solved!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ WRONG - $why')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍓 Fruit Sudoku - Level 1 / 15'),
        actions: [IconButton(onPressed: _how, icon: const Icon(Icons.help_outline))],
      ),
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.all(10), child: Text('Tap empty cell, then pick fruit below', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 6, mainAxisSpacing: 6),
              itemCount: 16,
              itemBuilder: (_, i) {
                int r = i ~/ 4, c = i % 4, v = b[r][c];
                return GestureDetector(
                  onTap: () { if (v == -1) { setState(() => b[r][c] = selected); } },
                  child: Container(
                    decoration: BoxDecoration(color: v == -1 ? Colors.white : Colors.orange[100], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black26)),
                    child: Center(child: Text(v == -1 ? '' : fruits[v], style: const TextStyle(fontSize: 28))),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(label: Text(fruits[i], style: const TextStyle(fontSize: 22)), selected: selected == i, onSelected: (_) => setState(() => selected = i)),
              )),
            ),
          ),
          SafeArea(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              child: Row(children: [
                Expanded(child: ElevatedButton(onPressed: _check, child: const Text('✓ CHECK - Am I Right?'))),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _how, child: const Text('? How')),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
