import 'package:flutter/material.dart';

class MathNotationWidget extends StatefulWidget {
  final TextEditingController? targetController;
  final FocusNode? targetFocusNode;

  const MathNotationWidget({
    super.key,
    this.targetController,
    this.targetFocusNode,
  });

  @override
  State<MathNotationWidget> createState() => _MathNotationWidgetState();
}

class _MathNotationWidgetState extends State<MathNotationWidget> {
  int _currentMathPage = 0;
  List<String> mathNotations = [
    // Simbol umum
    '±', '∞', '=', '≠', '∼', '×', '÷', '!', '%',

    // Simbol perbandingan
    '<', '>', '≤', '≥', '≪', '≫', '≈', '≡',

    // Simbol himpunan/logika
    '∀', '∃', '⊂', '⊆', '⊃', '⊇', '∈', '∉', '∪', '∩', '∖', '∆', '∅', 'ℕ', 'ℤ', 'ℚ', 'ℝ', 'ℂ',

    // Huruf Yunani
    'α', 'β', 'γ', 'δ', 'ε', 'θ', 'μ', 'π', 'ρ', 'σ', 'τ', 'φ', 'ω', 'ψ', 'Δ',

    // Operator matematika
    '+', '−', '·', '*', ':', '∂', '∫', '∑', '∏',

    // Akar
    '√', '∛', '∜',

    // Satuan/simbol khusus
    '°F', '°C', 'ℎ', 'C', 'V', 'U',

    // Panah
    '←', '↑', '→', '↓',

    // Simbol lain
    '⋯', '…', '■'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(blurRadius: 2, color: Colors.grey)]
      ),
      child: Builder(
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;

          final crossAxisCount = screenWidth < 400 ? 4 :
          screenWidth < 600 ? 6 :
          screenWidth < 900 ? 8 : 10;

          final fontSize = screenWidth < 400 ? 16.0 :
          screenWidth < 600 ? 18.0 : 20.0;

          final spacing = screenWidth < 400 ? 4.0 : 8.0;

          // Pagination configuration
          final itemsPerPage = crossAxisCount * 2;
          final totalPages = (mathNotations.length / itemsPerPage).ceil();
          final startIndex = _currentMathPage * itemsPerPage;
          final endIndex = startIndex + itemsPerPage;
          final currentPageItems = mathNotations.sublist(
              startIndex,
              endIndex > mathNotations.length ? mathNotations.length : endIndex
          );

          return Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: 1,
                ),
                itemCount: currentPageItems.length,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    _insertMathNotation(
                      currentPageItems[index],
                      controller: widget.targetController,
                      focusNode: widget.targetFocusNode,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        currentPageItems[index],
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ),
                  ),
                ),
              ),

              // Dot indicator dengan navigation
              if (totalPages > 1) ...[
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, size: 20),
                      onPressed: _currentMathPage > 0 ? () {
                        setState(() {
                          _currentMathPage--;
                        });
                      } : null,
                      padding: EdgeInsets.all(4),
                    ),

                    // Dot indicators
                    Row(
                      children: List.generate(totalPages, (index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentMathPage == index
                                ? Colors.blue
                                : Colors.grey[300],
                          ),
                        );
                      }),
                    ),

                    IconButton(
                      icon: Icon(Icons.chevron_right, size: 20),
                      onPressed: _currentMathPage < totalPages - 1 ? () {
                        setState(() {
                          _currentMathPage++;
                        });
                      } : null,
                      padding: EdgeInsets.all(4),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _insertMathNotation(
      String notation, {
        TextEditingController? controller,
        FocusNode? focusNode,
      }) {
    // Gunakan parameter atau fallback ke default
    final targetController = controller;
    final targetFocusNode = focusNode;

    final text = targetController?.text;
    final selection = targetController?.selection;

    if (selection!.isValid) {
      // Insert pada posisi kursor
      final newText = text!.replaceRange(
          selection.start,
          selection.end,
          notation
      );

      targetController!.text = newText;

      // Update posisi kursor setelah karakter yang baru ditambahkan
      final newCursorPosition = selection.start + notation.length;
      targetController.selection = TextSelection.collapsed(offset: newCursorPosition);
    } else {
      // Fallback: tambahkan di akhir jika tidak ada selection yang valid
      targetController!.text += notation;
      targetController.selection = TextSelection.collapsed(
          offset: targetController.text.length
      );
    }

    // Pastikan focus tetap pada text field target
    if (!targetFocusNode!.hasFocus) {
      targetFocusNode.requestFocus();
    }
  }
}