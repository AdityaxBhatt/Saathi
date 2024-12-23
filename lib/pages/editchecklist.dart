import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saathi/pages/checklist.dart';
import 'package:saathi/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditChecklistPage extends StatefulWidget {
  final dynamic checklist;
  final bool isPrivate;

  const EditChecklistPage({
    Key? key,
    required this.checklist,
    required this.isPrivate,
  }) : super(key: key);

  @override
  _EditChecklistPageState createState() => _EditChecklistPageState();
}

class _EditChecklistPageState extends State<EditChecklistPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController activityController = TextEditingController();
  TextEditingController documentController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.checklist.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFDE0),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFDE0),
        title: Text('Edit Checklist'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 16.0),
              _buildItemList(
                title: 'Locations',
                items: widget.checklist.locations,
                onRemove: (index) {
                  setState(() {
                    widget.checklist.removeLocation(index);
                  });
                },
                onUpdate: (index, newName) {
                  widget.checklist.updateLocation(index, newName);
                },
              ),
              _buildAddItemField(
                title: 'Add Location',
                controller: locationController,
                onAdd: () {
                  setState(() {
                    widget.checklist.addLocation(locationController.text);
                    locationController.clear();
                  });
                },
              ),
              SizedBox(height: 16.0),
              _buildItemList(
                title: 'Activities',
                items: widget.checklist.activities,
                onRemove: (index) {
                  setState(() {
                    widget.checklist.removeActivity(index);
                  });
                },
                onUpdate: (index, newName) {
                  widget.checklist.updateActivity(index, newName);
                },
              ),
              SizedBox(height: 16.0),
              _buildAddItemField(
                title: 'Add Activity',
                controller: activityController,
                onAdd: () {
                  setState(() {
                    widget.checklist.addActivity(activityController.text);
                    activityController.clear();
                  });
                },
              ),
              SizedBox(height: 16.0),
              _buildItemList(
                title: 'Documents',
                items: widget.checklist.documents,
                onRemove: (index) {
                  setState(() {
                    widget.checklist.removeDocument(index);
                  });
                },
                onUpdate: (index, newName) {
                  widget.checklist.updateDocument(index, newName);
                },
              ),
              _buildAddItemField(
                title: 'Add Document',
                controller: documentController,
                onAdd: () {
                  setState(() {
                    widget.checklist.addDocument(documentController.text);
                    documentController.clear();
                  });
                },
              ),
              SizedBox(height: 16.0),
              _buildItemList(
                title: 'Notes',
                items: widget.checklist.notes,
                onRemove: (index) {
                  setState(() {
                    widget.checklist.removeNote(index);
                  });
                },
                onUpdate: (index, newName) {
                  widget.checklist.updateNote(index, newName);
                },
              ),
              SizedBox(height: 16.0),
              _buildAddItemField(
                title: 'Add Note',
                controller: noteController,
                onAdd: () {
                  setState(() {
                    widget.checklist.addNote(noteController.text);
                    noteController.clear();
                  });
                },
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (widget.isPrivate) {
                        savePrivateChecklistChanges();
                      } else {
                        savePublicChecklistChanges();
                      }
                    },
                    child: Text('Save Changes'),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.isPrivate) {
                        delPrivateChecklistChanges();
                      } else {
                        delPublicChecklistChanges();
                      }
                    },
                    child: Text('Delete checklist'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddItemField({
    required String title,
    required TextEditingController controller,
    required Function() onAdd,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: title),
          ),
        ),
        IconButton(
          onPressed: onAdd,
          icon: Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildItemList({
    required String title,
    required List<ChecklistItem> items,
    required Function(int) onRemove,
    required Function(int, String) onUpdate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Column(
          children: List.generate(items.length, (index) {
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: items[index].name),
                    onChanged: (value) {
                      onUpdate(index, value);
                    },
                    decoration: InputDecoration(labelText: 'Enter $title'),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    onRemove(index);
                  },
                  icon: Icon(Icons.remove_circle),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  void savePrivateChecklistChanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String checklistKey = 'private_checklist_${widget.checklist.title}';

    // Update the checklist object with the changes
    widget.checklist.title = titleController.text;

    prefs.remove(checklistKey);
    prefs.setString(checklistKey, jsonEncode(widget.checklist.toJson()));

    // Navigate back to the previous screen
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChecklistDetailsPage(
          checklist: widget.checklist,
          isPrivate: true,
        ),
      ),
    );
  }

  void savePublicChecklistChanges() {
    widget.checklist.title = titleController.text;
    FirebaseFirestore.instance
        .collection('public_checklists')
        .doc(widget.checklist.id)
        .update(widget.checklist.toJson())
        .then((_) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChecklistDetailsPage(
            checklist: widget.checklist,
            isPrivate: false,
          ),
        ),
      );
    }).catchError((error) {
      print("Failed to update checklist: $error");
      // Handle error
    });
  }

  void delPrivateChecklistChanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String checklistKey = 'private_checklist_${widget.checklist.title}';

    // Update the checklist object with the changes
    widget.checklist.title = titleController.text;
    setState(() {
      prefs.remove(checklistKey);
    });

    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  void delPublicChecklistChanges() {
    widget.checklist.title = titleController.text;
    FirebaseFirestore.instance
        .collection('public_checklists')
        .doc(widget.checklist.id)
        .delete()
        .then((_) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    }).catchError((error) {
      print("Failed to delete checklist: $error");
      // Handle error
    });
  }
}
