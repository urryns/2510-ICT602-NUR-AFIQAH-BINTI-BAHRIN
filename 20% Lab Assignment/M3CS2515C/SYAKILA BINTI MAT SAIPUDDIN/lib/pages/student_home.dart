import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class StudentHome extends StatelessWidget {
  const StudentHome({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // Calculate final exam target
  int calculateFinalExamTarget(double carryMark, int targetTotal) {
    final required = targetTotal - carryMark;
    if (required > 50) return -1; // Impossible
    if (required < 0) return 0; // Secured
    return required.ceil();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Grading scheme
    final gradeMap = {
      'A+': 90,
      'A': 80,
      'A-': 75,
      'B+': 70,
      'B': 65,
      'B-': 60,
      'C+': 55,
      'C': 50,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A5ACD), Color(0xFF00BFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final carry = data['carryMark'] ?? {};
            final carryMark = (carry['weightedScore'] ?? 0).toDouble();

            return Center(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Your Carry Marks",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Test:"),
                            Text("${carry['test'] ?? 0}"),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Assignment:"),
                            Text("${carry['assignment'] ?? 0}"),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Project:"),
                            Text("${carry['project'] ?? 0}"),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Total Carry Mark: ${carryMark.toStringAsFixed(2)} / 50",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          "Final Exam Target Scores (out of 50):",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Compact progress bars for each grade
                        ...gradeMap.entries.map((entry) {
                          final target = calculateFinalExamTarget(
                              carryMark, entry.value);

                          Color color;
                          double progress;
                          String displayText;

                          if (target == -1) {
                            color = Colors.red;
                            progress = 1.0;
                            displayText = "Impossible";
                          } else if (target == 0) {
                            color = Colors.blue;
                            progress = 1.0;
                            displayText = "Secured";
                          } else {
                            color = Colors.green;
                            progress = carryMark / (carryMark + target);
                            displayText = "$target";
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      displayText,
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                LinearProgressIndicator(
                                  value: progress.clamp(0.0, 1.0),
                                  color: color,
                                  backgroundColor: Colors.grey[300],
                                  minHeight: 6,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
