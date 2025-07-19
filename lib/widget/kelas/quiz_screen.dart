// widget/kelas/quiz_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/main.dart' as MixpanelManager;

class QuizScreen extends StatefulWidget {
  final String moduleId;

  const QuizScreen({super.key, required this.moduleId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List quizzes = [];
  int currentIndex = 0;
  int score = 0;
  String? selectedOption;
  bool isAnswered = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://mediquick.my.id/Course/User/quiz_api.php?action=by_module&id=${widget.moduleId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'] is List) {
          setState(() {
            quizzes = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            quizzes = [];
            isLoading = false;
          });
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void submitAnswer() {
    final correct =
        (quizzes[currentIndex]['correct_option'] ?? '')
            .toString()
            .toUpperCase();

    if (selectedOption?.toUpperCase() == correct) {
      score++;
    }

    if (currentIndex < quizzes.length - 1) {
      setState(() {
        currentIndex++;
        selectedOption = null;
        isAnswered = false;
      });
    } else {
      showResult();
    }
  }

  void showResult() {
    // Tracking event ke Mixpanel
    MixpanelManager.mixpanel.track(
      "Quiz Completed",
      properties: {
        "module_id": widget.moduleId,
        "score": score,
        "total_questions": quizzes.length,
      },
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text("🎉 Kuis Selesai"),
            content: Text(
              "Skor kamu: $score dari ${quizzes.length}",
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Tutup",
                  style: TextStyle(fontSize: 16, color: Color(0xFF7FA1C3)),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (quizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Kuis")),
        body: const Center(
          child: Text("⚠️ Tidak ada soal tersedia untuk modul ini."),
        ),
      );
    }

    final quiz = quizzes[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Soal ${currentIndex + 1} / ${quizzes.length}"),
        backgroundColor: Color(0xFF7FA1C3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Soal dalam card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  quiz['question'] ?? '-',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Opsi jawaban
            Column(
              children:
                  ['A', 'B', 'C', 'D'].map((option) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              selectedOption == option
                                  ? Color(0xFF7FA1C3)
                                  : Colors.grey.shade300,
                        ),
                        color:
                            selectedOption == option
                                ? Colors.blue.shade50
                                : Colors.white,
                      ),
                      child: RadioListTile<String>(
                        title: Text(
                          quiz['option_${option.toLowerCase()}'] ?? '-',
                          style: const TextStyle(fontSize: 16),
                        ),
                        value: option,
                        groupValue: selectedOption,
                        onChanged: (val) {
                          setState(() {
                            selectedOption = val;
                            isAnswered = true;
                          });
                        },
                        activeColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 32),

            // Tombol
            ElevatedButton.icon(
              onPressed: isAnswered ? submitAnswer : null,
              icon: Icon(
                currentIndex == quizzes.length - 1
                    ? Icons.check
                    : Icons.arrow_forward,
              ),
              label: Text(
                currentIndex == quizzes.length - 1 ? "Selesai" : "Selanjutnya",
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7FA1C3),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
