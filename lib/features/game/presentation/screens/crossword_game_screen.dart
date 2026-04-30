import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/widgets/animated_score_badge.dart';

class CrosswordCellData {
  final String expectedChar;
  String currentValue;
  final int number; // 0 if no number
  final bool isBlack;

  CrosswordCellData({
    required this.expectedChar,
    this.currentValue = "",
    this.number = 0,
    this.isBlack = false,
  });
}

class CrosswordGameScreen extends StatefulWidget {
  const CrosswordGameScreen({super.key});

  @override
  State<CrosswordGameScreen> createState() => _CrosswordGameScreenState();
}

class _CrosswordGameScreenState extends State<CrosswordGameScreen> {
  // Grid size: 9 columns, 6 rows
  final int _cols = 9;
  final int _rows = 6;
  
  late List<List<CrosswordCellData>> _grid;
  int _selectedRow = -1;
  int _selectedCol = -1;
  int _score = 0;
  bool _isSuccess = false;

  final List<String> _hints = [
    "1. [Horiz] Aquele que vai à escola para aprender",
    "2. [Vert] Associação, junção de partes",
    "3. [Vert] Sinônimo de estudante",
    "4. [Vert] Período depois do meio-dia",
    "5. [Horiz] Estado de quem está muito contente",
    "5. [Vert] Ponto de convergência, atenção",
    "6. [Horiz] Um acontecimento ou situação",
  ];

  @override
  void initState() {
    super.initState();
    _initGrid();
  }

  void _initGrid() {
    final template = [
      ["E:1", "S", "T", "U:2", "D", "A:3", "N", "T:4", "E"],
      ["#",   "#", "#", "N",   "#", "L",   "#", "A",   "#"],
      ["F:5", "E", "L", "I",   "Z", "U",   "#", "R",   "#"],
      ["O",   "#", "#", "A",   "#", "N",   "#", "D",   "#"],
      ["C:6", "A", "S", "O",   "#", "O",   "#", "E",   "#"],
      ["O",   "#", "#", "#",   "#", "#",   "#", "#",   "#"],
    ];

    _grid = List.generate(_rows, (r) {
      return List.generate(_cols, (c) {
        String val = template[r][c];
        if (val == "#") {
          return CrosswordCellData(expectedChar: "", isBlack: true);
        }
        int num = 0;
        String char = val;
        if (val.contains(":")) {
          var parts = val.split(":");
          char = parts[0];
          num = int.parse(parts[1]);
        }
        return CrosswordCellData(expectedChar: char, number: num);
      });
    });
  }

  void _onCellTap(int r, int c) {
    if (_grid[r][c].isBlack || _isSuccess) return;
    setState(() {
      _selectedRow = r;
      _selectedCol = c;
    });
  }

  void _onKeyPress(String key) {
    if (_selectedRow == -1 || _selectedCol == -1 || _isSuccess) return;

    setState(() {
      if (key == "DEL") {
        _grid[_selectedRow][_selectedCol].currentValue = "";
      } else {
        _grid[_selectedRow][_selectedCol].currentValue = key;
        _moveToNextEmptyCell();
      }
      _checkWinCondition();
    });
  }

  void _moveToNextEmptyCell() {
    // Try to move to the right or down logically (simple approach: just right)
    if (_selectedCol + 1 < _cols && !_grid[_selectedRow][_selectedCol + 1].isBlack) {
      _selectedCol++;
    } else if (_selectedRow + 1 < _rows && !_grid[_selectedRow + 1][_selectedCol].isBlack) {
      _selectedRow++;
    }
  }

  void _checkWinCondition() {
    bool isComplete = true;
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        var cell = _grid[r][c];
        if (!cell.isBlack) {
          if (cell.currentValue != cell.expectedChar) {
            isComplete = false;
            break;
          }
        }
      }
      if (!isComplete) break;
    }

    if (isComplete) {
      setState(() {
        _isSuccess = true;
        _score += 500;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Palavras Cruzadas'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: AnimatedScoreBadge(score: _score),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isSuccess)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.checkCircle, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text("Nível Concluído com Sucesso!", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ).animate().fade().scale()
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: _hints.map((hint) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(hint, style: const TextStyle(color: AppColors.textMedium, fontSize: 12)),
                  )).toList(),
                ),
              ),
            
            // Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: ShrinkWrapGrid(
                  cols: _cols,
                  rows: _rows,
                  grid: _grid,
                  selectedRow: _selectedRow,
                  selectedCol: _selectedCol,
                  isSuccess: _isSuccess,
                  onCellTap: _onCellTap,
                ),
              ),
            ).animate().fade().slideY(begin: 0.1),
            
            const SizedBox(height: 16),
            
            // Custom Keyboard
            Container(
              padding: const EdgeInsets.all(8.0),
              color: AppColors.surface,
              child: Column(
                children: [
                  _buildKeyboardRow(["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]),
                  const SizedBox(height: 8),
                  _buildKeyboardRow(["A", "S", "D", "F", "G", "H", "J", "K", "L"]),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildKeyboardRow(["Z", "X", "C", "V", "B", "N", "M"]),
                      const SizedBox(width: 8),
                      _buildKey("DEL", isSpecial: true),
                    ],
                  ),
                ],
              ),
            ).animate().slideY(begin: 1.0, duration: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((k) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: _buildKey(k),
      )).toList(),
    );
  }

  Widget _buildKey(String label, {bool isSpecial = false}) {
    return Material(
      color: isSpecial ? AppColors.primaryDim : AppColors.surfaceBright,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: () => _onKeyPress(label),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: isSpecial ? 16 : 10, vertical: 12),
          child: isSpecial && label == "DEL"
              ? const Icon(LucideIcons.delete, size: 20, color: Colors.white)
              : Text(
                  label,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
      ),
    );
  }
}

class ShrinkWrapGrid extends StatelessWidget {
  final int cols;
  final int rows;
  final List<List<CrosswordCellData>> grid;
  final int selectedRow;
  final int selectedCol;
  final bool isSuccess;
  final Function(int, int) onCellTap;

  const ShrinkWrapGrid({
    super.key,
    required this.cols,
    required this.rows,
    required this.grid,
    required this.selectedRow,
    required this.selectedCol,
    required this.isSuccess,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Reduz a largura disponível para evitar qualquer overflow de ponto flutuante
        final double availableWidth = constraints.maxWidth - 4;
        final double cellSize = availableWidth / cols;
        
        return SizedBox(
          width: availableWidth,
          height: cellSize * rows,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1,
            ),
            itemCount: rows * cols,
            itemBuilder: (context, index) {
              int r = index ~/ cols;
              int c = index % cols;
              var cell = grid[r][c];
              
              if (cell.isBlack) {
                return const SizedBox.shrink();
              }

              bool isSelected = r == selectedRow && c == selectedCol;
              bool isCorrect = isSuccess || (cell.currentValue.isNotEmpty && cell.currentValue == cell.expectedChar);

              return GestureDetector(
                onTap: () => onCellTap(r, c),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary.withOpacity(0.5) 
                        : (isCorrect ? AppColors.secondary.withOpacity(0.3) : AppColors.surfaceBright),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : (isCorrect ? AppColors.secondary : AppColors.outline),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      if (cell.number > 0)
                        Positioned(
                          top: 2,
                          left: 4,
                          child: Text(
                            cell.number.toString(),
                            style: const TextStyle(fontSize: 8, color: AppColors.textMedium, fontWeight: FontWeight.bold),
                          ),
                        ),
                      Center(
                        child: Text(
                          cell.currentValue,
                          style: TextStyle(
                            fontSize: cellSize * 0.45,
                            fontWeight: FontWeight.bold,
                            color: isCorrect ? AppColors.secondary : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .scale(
                  delay: ((r * cols + c) * 20).ms, 
                  duration: 300.ms, 
                  curve: Curves.easeOutBack
                )
                .fade(duration: 300.ms)
                .animate(target: isCorrect ? 1 : 0)
                .shimmer(duration: 500.ms, color: Colors.white24),
              );
            },
          ),
        );
      }
    );
  }
}

