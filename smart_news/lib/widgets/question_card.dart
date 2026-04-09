import 'package:flutter/material.dart';

class QuestionCard extends StatefulWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.options,
    required this.onOptionSelected,
    required this.selectedIndex,
    required this.correctIndex,
    required this.isAnswered,
  });

  final String question;
  final List<String> options;
  final Function(int) onOptionSelected;
  final int? selectedIndex;
  final int correctIndex;
  final bool isAnswered;

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Question
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            widget.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),

        // Options
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(
              widget.options.length,
              (index) {
                final isSelected = widget.selectedIndex == index;
                final isCorrect = index == widget.correctIndex;
                bool showCorrect = false;
                bool showWrong = false;

                if (widget.isAnswered) {
                  if (isSelected && isCorrect) {
                    showCorrect = true;
                  } else if (isSelected && !isCorrect) {
                    showWrong = true;
                  } else if (!isSelected && isCorrect) {
                    showCorrect = true;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: widget.isAnswered
                        ? null
                        : () {
                            widget.onOptionSelected(index);
                          },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: showCorrect
                              ? Colors.green
                              : showWrong
                                  ? Colors.red
                                  : isSelected
                                      ? Colors.blue
                                      : Colors.grey[300] ?? Colors.grey,
                          width: showCorrect || showWrong ? 2 : 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: showCorrect
                            ? Colors.green.withValues(alpha: 0.1)
                            : showWrong
                                ? Colors.red.withValues(alpha: 0.1)
                                : isSelected
                                    ? Colors.blue.withValues(alpha: 0.08)
                                    : Colors.white,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Option letter
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: showCorrect
                                  ? Colors.green
                                  : showWrong
                                      ? Colors.red
                                      : isSelected
                                          ? Colors.blue
                                          : Colors.grey[300],
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: showCorrect || showWrong || isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Option text
                          Expanded(
                            child: Text(
                              widget.options[index],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: showCorrect
                                    ? Colors.green
                                    : showWrong
                                        ? Colors.red
                                        : Colors.black87,
                              ),
                            ),
                          ),

                          // Check or X icon
                          if (widget.isAnswered)
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Icon(
                                showCorrect ? Icons.check_circle : Icons.cancel,
                                color:
                                    showCorrect ? Colors.green : Colors.red,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
