import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FruitSudokuGarden extends StatefulWidget {
  const FruitSudokuGarden({super.key});
  @override
  State<FruitSudokuGarden> createState() => _FruitSudokuGardenState();
}

class _FruitSudokuGardenState extends State<FruitSudokuGarden> {
  static const List<String> fruits4 = ['🍓', '🍎', '🍑', '🍋'];
  static const List<String> fruits6 = ['🍓', '🍎', '🍑', '🍋', '🍊', '🍇'];
  static const List<String> fruits9 = ['🍓', '🍎', '🍑', '🍋', '🍊', '🍇', '🍒', '🍐', '🥝'];

  int currentLevel = 0;
  late int gridSize;
  late List<String> currentFruits;
  late List<List<int>> solvedBoard;
  late List<List<int>> puzzleBoard;
  late List<List<int>> playerBoard;
  int moves = 0;
  int seconds = 0;
  Timer? timer;
  bool isWon = false;
  int? selectedRow;
  int? selectedCol;
  int? selectedFruitIndex;

  int getLevelSize(int level) => level < 3 ? 4 : level < 8 ? 6 : 9;
  String getLevelBadge(int level) => level < 3 ? 'Easy' : level < 8 ? 'Medium' : 'Hard';
  Color getLevelColor(int level) => level < 3 ? const Color(0xFF66BB6A) : level < 8 ? const Color(0xFFFFEB3B) : const Color(0xFFEF5350);

  @override
  void initState() { super.initState(); loadLevel(0); }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  void startTimer() {
    timer?.cancel(); seconds = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (t) { if (mounted) setState(() => seconds++); });
  }

  void loadLevel(int level) {
    currentLevel = level;
    gridSize = getLevelSize(level);
    currentFruits = gridSize == 4 ? fruits4 : gridSize == 6 ? fruits6 : fruits9;
    solvedBoard = _generateSolvedBoard(gridSize);
    int cluesToRemove = gridSize == 4 ? 6 + level : gridSize == 6 ? 18 + level : 35 + level;
    puzzleBoard = _makePuzzle(solvedBoard, cluesToRemove);
    playerBoard = puzzleBoard.map((r) => List<int>.from(r)).toList();
    moves = 0; isWon = false; selectedRow = null; selectedCol = null; selectedFruitIndex = null;
    startTimer(); setState(() {});
  }

  List<List<int>> _generateSolvedBoard(int n) {
    List<List<int>> board = List.generate(n, (_) => List.filled(n, -1));
    _fillBoard(board, 0, 0, n); return board;
  }
  bool _fillBoard(List<List<int>> board, int row, int col, int n) {
    if (row == n) return true;
    int nextRow = col == n - 1 ? row + 1 : row;
    int nextCol = col == n - 1 ? 0 : col + 1;
    List<int> nums = List.generate(n, (i) => i)..shuffle(Random());
    for (int num in nums) {
      if (_isValidPlacement(board, row, col, num, n)) {
        board[row][col] = num;
        if (_fillBoard(board, nextRow, nextCol, n)) return true;
        board[row][col] = -1;
      }
    }
    return false;
  }
  bool _isValidPlacement(List<List<int>> board, int r, int c, int val, int n) {
    for (int j = 0; j < n; j++) if (board[r][j] == val) return false;
    for (int i = 0; i < n; i++) if (board[i][c] == val) return false;
    int boxH, boxW;
    if (n == 4) { boxH = 2; boxW = 2; } else if (n == 6) { boxH = 2; boxW = 3; } else { boxH = 3; boxW = 3; }
    int startRow = (r ~/ boxH) * boxH; int startCol = (c ~/ boxW) * boxW;
    for (int i = startRow; i < startRow + boxH; i++) for (int j = startCol; j < startCol + boxW; j++) if (board[i][j] == val) return false;
    return true;
  }
  List<List<int>> _makePuzzle(List<List<int>> solved, int removeCount) {
    var puzzle = solved.map((r) => List<int>.from(r)).toList();
    List<Point<int>> cells = []; for (int i = 0; i < gridSize; i++) for (int j = 0; j < gridSize; j++) cells.add(Point(i, j));
    cells.shuffle(Random(currentLevel * 100)); int removed = 0;
    for (var p in cells) { if (removed >= removeCount) break; puzzle[p.x][p.y] = -1; removed++; }
    return puzzle;
  }

  void _onCellTap(int r, int c) {
    if (isWon) return; if (puzzleBoard[r][c] != -1) return;
    setState(() { selectedRow = r; selectedCol = c; });
  }
  void _placeFruit(int fruitIdx) {
    if (selectedRow == null || selectedCol == null) return;
    setState(() { playerBoard[selectedRow!][selectedCol!] = fruitIdx; moves++; selectedFruitIndex = fruitIdx; _checkWin(); });
  }
  void _eraseCell() {
    if (selectedRow == null || selectedCol == null) return;
    setState(() { playerBoard[selectedRow!][selectedCol!] = -1; moves++; });
  }
  void _checkWin() {
    for (int i = 0; i < gridSize; i++) for (int j = 0; j < gridSize; j++) if (playerBoard[i][j] == -1) return;
    if (_isBoardValid(playerBoard)) _onWin();
  }
  bool _isBoardValid(List<List<int>> board) {
    int n = gridSize;
    for (int i = 0; i < n; i++) {
      Set<int> rowSet = {}; Set<int> colSet = {};
      for (int j = 0; j < n; j++) { if (board[i][j] == -1 || board[j][i] == -1) return false; rowSet.add(board[i][j]); colSet.add(board[j][i]); }
      if (rowSet.length != n || colSet.length != n) return false;
    }
    int boxH, boxW; if (n == 4) { boxH = 2; boxW = 2; } else if (n == 6) { boxH = 2; boxW = 3; } else { boxH = 3; boxW = 3; }
    for (int br = 0; br < n; br += boxH) for (int bc = 0; bc < n; bc += boxW) {
      Set<int> boxSet = {}; for (int i = br; i < br + boxH; i++) for (int j = bc; j < bc + boxW; j++) boxSet.add(board[i][j]);
      if (boxSet.length != n) return false;
    }
    return true;
  }
  Future<void> _onWin() async {
    timer?.cancel(); isWon = true;
    int score = max(0, 1000 - seconds - moves * 2); int stars = seconds < 60 ? 3 : seconds < 120 ? 2 : 1;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'fruit_sudoku_best_$currentLevel'; int best = prefs.getInt(key) ?? 9999;
    if (seconds < best) await prefs.setInt(key, seconds);
    if (!mounted) return;
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      title: Text('Level ${currentLevel + 1} Done!'), content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Time: $seconds s'), Text('Moves: $moves'), Text('Score: $score'), const SizedBox(height: 8), Row(children: List.generate(stars, (i) => const Text('⭐')))]),
      actions: [TextButton(onPressed: () { Navigator.pop(context); loadLevel(currentLevel); }, child: const Text('Replay')), TextButton(onPressed: () { Navigator.pop(context); if (currentLevel < 14) loadLevel(currentLevel + 1); }, child: Text(currentLevel < 14 ? 'Next' : 'Done'))],
    ));
  }
  void _hint() {
    if (selectedRow == null || selectedCol == null) { for (int i = 0; i < gridSize; i++) for (int j = 0; j < gridSize; j++) if (playerBoard[i][j] == -1) { setState(() { selectedRow = i; selectedCol = j; }); return; } return; }
    setState(() { playerBoard[selectedRow!][selectedCol!] = solvedBoard[selectedRow!][selectedCol!]; moves++; _checkWin(); });
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double tileSize = gridSize == 9 ? min(34.0, (screenW - 20) / 9) : gridSize == 6 ? min(48.0, (screenW - 20) / 6) : min(62.0, (screenW - 20) / 4);
    double bottomPad = MediaQuery.of(context).padding.bottom + 90;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF0),
        elevation: 0,
        titleSpacing: 0,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: getLevelColor(currentLevel), borderRadius: BorderRadius.circular(10)), child: Text('${getLevelBadge(currentLevel)} ${currentLevel + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: getLevelColor(currentLevel) == const Color(0xFFFFEB3B) ? Colors.black : Colors.white))),
              const SizedBox(width: 6),
              Text('🍓 Fruit Sudoku ${gridSize}x$gridSize', style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          IconButton(onPressed: _hint, icon: const Text('💡', style: TextStyle(fontSize: 18)), padding: const EdgeInsets.all(4), constraints: const BoxConstraints()),
          const SizedBox(width: 4),
          IconButton(onPressed: () => loadLevel(currentLevel), icon: const Icon(Icons.refresh, size: 20, color: Colors.black54), padding: const EdgeInsets.all(4), constraints: const BoxConstraints()),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('⏱ $seconds s', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), Text('Moves $moves', style: const TextStyle(fontSize: 14)), Text('$gridSize x $gridSize', style: const TextStyle(fontSize: 12, color: Colors.black54))]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomPad, left: 4, right: 4, top: 4),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.black87, width: 2), borderRadius: BorderRadius.circular(8)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: List.generate(gridSize, (r) {
                    int boxH = gridSize == 4 ? 2 : gridSize == 6 ? 2 : 3; bool thickBottom = (r + 1) % boxH == 0 && r != gridSize - 1;
                    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(gridSize, (c) {
                      int boxW = gridSize == 4 ? 2 : gridSize == 6 ? 3 : 3; bool thickRight = (c + 1) % boxW == 0 && c != gridSize - 1;
                      bool isFixed = puzzleBoard[r][c] != -1; bool isSelected = selectedRow == r && selectedCol == c; bool isSameRowCol = selectedRow == r || selectedCol == c;
                      int val = playerBoard[r][c];
                      return GestureDetector(onTap: () => _onCellTap(r, c), child: Container(width: tileSize, height: tileSize, decoration: BoxDecoration(color: isSelected ? const Color(0xFFB3E5FC) : isSameRowCol ? const Color(0xFFFFF9C4) : isFixed ? const Color(0xFFF1F8E9) : Colors.white, border: Border(right: BorderSide(color: thickRight ? Colors.black87 : Colors.black26, width: thickRight ? 2 : 0.5), bottom: BorderSide(color: thickBottom ? Colors.black87 : Colors.black26, width: thickBottom ? 2 : 0.5), left: const BorderSide(color: Colors.black26, width: 0.5), top: const BorderSide(color: Colors.black26, width: 0.5))), child: Center(child: val == -1 ? const SizedBox() : Text(currentFruits[val], style: TextStyle(fontSize: gridSize == 9 ? 18 : gridSize == 6 ? 24 : 30)))));
                    }));
                  })),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 6, right: 6, bottom: MediaQuery.of(context).padding.bottom + 12, top: 6),
            color: Colors.white,
            child: Column(
              children: [
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [...List.generate(currentFruits.length, (i) { bool isSel = selectedFruitIndex == i; return Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: GestureDetector(onTap: () => _placeFruit(i), child: Container(width: gridSize == 9 ? 32 : 44, height: gridSize == 9 ? 32 : 44, decoration: BoxDecoration(color: isSel ? const Color(0xFFFFEB3B) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8), border: Border.all(color: isSel ? Colors.black87 : Colors.black26, width: isSel ? 2 : 1)), child: Center(child: Text(currentFruits[i], style: TextStyle(fontSize: gridSize == 9 ? 18 : 26)))))); }), Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: GestureDetector(onTap: _eraseCell, child: Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFFFCDD2), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black26)), child: const Center(child: Icon(Icons.backspace_outlined, size: 18)))))])),
                const SizedBox(height: 6),
                SizedBox(height: 32, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: 15, itemBuilder: (_, idx) { bool active = idx == currentLevel; return GestureDetector(onTap: () => loadLevel(idx), child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: active ? getLevelColor(idx) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: getLevelColor(idx))), child: Center(child: Text('${idx + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: active ? (getLevelColor(idx) == const Color(0xFFFFEB3B) ? Colors.black : Colors.white) : Colors.black87, fontSize: 12))))); })),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
