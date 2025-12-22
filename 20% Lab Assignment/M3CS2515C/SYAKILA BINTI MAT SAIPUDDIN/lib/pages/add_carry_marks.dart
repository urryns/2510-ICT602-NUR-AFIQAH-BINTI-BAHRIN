import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCarryMarksPage extends StatefulWidget {
  final String studentId;
  final String studentName;

  const AddCarryMarksPage({
    Key? key,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

  @override
  State<AddCarryMarksPage> createState() => _AddCarryMarksPageState();
}

class _AddCarryMarksPageState extends State<AddCarryMarksPage> {
  final testController = TextEditingController();
  final assignmentController = TextEditingController();
  final projectController = TextEditingController();

  Future<void> saveMarks() async {
    double test = double.parse(testController.text);
    double assignment = double.parse(assignmentController.text);
    double project = double.parse(projectController.text);

    double weightedScore =
        (test * 0.20) + (assignment * 0.10) + (project * 0.20);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.studentId)
        .update({
      'carryMark': {
        'test': test,
        'assignment': assignment,
        'project': project,
        'weightedScore': weightedScore,
      }
    });

    // ✅ GO BACK TO LECTURER DASHBOARD
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Carry marks saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Marks - ${widget.studentName}'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: testController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Test (20%)'),
            ),
            TextField(
              controller: assignmentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Assignment (10%)'),
            ),
            TextField(
              controller: projectController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Project (20%)'),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: saveMarks,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
