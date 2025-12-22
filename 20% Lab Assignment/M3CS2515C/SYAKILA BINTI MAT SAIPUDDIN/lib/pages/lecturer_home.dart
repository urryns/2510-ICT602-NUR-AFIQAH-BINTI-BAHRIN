import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';

class LecturerHome extends StatefulWidget {
  const LecturerHome({super.key});

  @override
  State<LecturerHome> createState() => _LecturerHomeState();
}

class _LecturerHomeState extends State<LecturerHome> {
  final testController = TextEditingController();
  final assignmentController = TextEditingController();
  final projectController = TextEditingController();

  String? selectedStudentUid;
  List<QueryDocumentSnapshot> students = [];

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    setState(() {
      students = snapshot.docs;
      if (students.isNotEmpty) {
        selectedStudentUid = students.first.id;
      }
    });
  }

  double get carryMark {
    final test = double.tryParse(testController.text) ?? 0;
    final assignment = double.tryParse(assignmentController.text) ?? 0;
    final project = double.tryParse(projectController.text) ?? 0;

    return (test * 0.20) + (assignment * 0.10) + (project * 0.20);
  }

  Future<void> saveMarks() async {
    if (selectedStudentUid == null) return;

    final test = double.tryParse(testController.text) ?? 0;
    final assignment = double.tryParse(assignmentController.text) ?? 0;
    final project = double.tryParse(projectController.text) ?? 0;

    final weightedScore = carryMark;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(selectedStudentUid)
        .update({
      'carryMark': {
        'test': test,
        'assignment': assignment,
        'project': project,
        'weightedScore': weightedScore,
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Carry marks saved successfully (${weightedScore.toStringAsFixed(2)})',
        ),
      ),
    );

    // Go back to Login Page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecturer - Carry Marks"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: _logout,
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
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 12,
            color: Colors.white.withOpacity(0.9),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                shrinkWrap: true,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedStudentUid,
                    decoration: const InputDecoration(
                      labelText: "Select Student",
                    ),
                    items: students.map((student) {
                      final data = student.data() as Map<String, dynamic>;
                      final name = data['username'] ?? 'Unknown Student';

                      return DropdownMenuItem(
                        value: student.id,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStudentUid = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: testController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Test (20%)",
                      prefixIcon: Icon(Icons.assignment),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: assignmentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Assignment (10%)",
                      prefixIcon: Icon(Icons.assignment_turned_in),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: projectController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Project (20%)",
                      prefixIcon: Icon(Icons.work),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Calculated Carry Mark: ${carryMark.toStringAsFixed(2)} / 50",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: saveMarks,
                    icon: const Icon(Icons.save),
                    label: const Text("SAVE"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
