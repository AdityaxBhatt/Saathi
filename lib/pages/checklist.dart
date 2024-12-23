import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saathi/pages/editchecklist.dart';
import 'package:saathi/pages/home.dart';

class ChecklistDetailsPage extends StatefulWidget {
  final dynamic checklist;
  final bool isPrivate;

  const ChecklistDetailsPage({
    Key? key,
    required this.checklist,
    required this.isPrivate,
  }) : super(key: key);

  @override
  _ChecklistDetailsPageState createState() => _ChecklistDetailsPageState();
}

class _ChecklistDetailsPageState extends State<ChecklistDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checklist Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${widget.checklist.title}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            buildChecklistSection(
              title: 'Locations to Visit',
              items: widget.checklist.locations,
            ),
            SizedBox(height: 16.0),
            buildChecklistSection(
              title: 'Documents to Carry',
              items: widget.checklist.documents,
            ),
            SizedBox(height: 16.0),
            buildChecklistSection(
              title: 'Activities to Do',
              items: widget.checklist.activities,
            ),
            SizedBox(height: 16.0),
            buildChecklistSection(
              title: 'Notes',
              items: widget.checklist.notes,
            ),
            SizedBox(height: 36.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditChecklistPage(
                      checklist: widget.checklist,
                      isPrivate: widget.isPrivate,
                    ),
                  ),
                );
              },
              child: Text('Edit Checklist'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChecklistSection({
    required String title,
    required List<ChecklistItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(items.length, (index) {
            return Row(
              children: [
                Checkbox(
                  value: items[index].isChecked,
                  onChanged: (value) {
                    setState(() {
                      items[index].isChecked = value ?? false;
                      FirebaseFirestore.instance
                          .collection('public_checklists')
                          .doc(widget.checklist.id)
                          .update(widget.checklist.toJson());
                    });
                  },
                ),
                Expanded(
                  child: Text(items[index].name),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
