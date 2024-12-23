import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:saathi/pages/checklist.dart';
import 'package:saathi/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final User? user;
  const HomePage({Key? key, this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PrivateChecklist> privateChecklists = [];
  List<PublicChecklist> publicChecklists = [];
  List<String> numbersList = NumberGenerator().numbers;
  @override
  void initState() {
    super.initState();
    _loadChecklists();
    _loadPublicChecklists();
  }

  Future<void> _pullRefresh() async {
    List<String> freshNumbers = await NumberGenerator().slowNumbers();
    setState(() {
      numbersList = freshNumbers;
    });
    // why use freshNumbers var? https://stackoverflow.com/a/52992836/2301224
  }

  Future<void> _loadChecklists() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    List<String>? checklistsJson = [];

    for (String key in keys) {
      checklistsJson.add(prefs.getString(key).toString());
    }
    if (checklistsJson != null) {
      setState(() {
        privateChecklists = checklistsJson
            .map((json) => PrivateChecklist.fromJson(jsonDecode(json)))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFDE0),
      // appBar: AppBar(
      //   backgroundColor: Color(0xFFFFFDE0),
      //   title: Text(
      //     'Travel App',
      //     style: TextStyle(fontSize: 30),
      //   ),
      // ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null && snapshot.data!.exists) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    String userName = data['name'];
                    return DrawerHeader(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Text('Hi, $userName',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          // You can add more widgets here if needed
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF5E17EB),
                      ),
                    );
                  } else {
                    return DrawerHeader(
                      child: Text(
                        'User not found',
                        style: TextStyle(color: Colors.white),
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF5E17EB),
                      ),
                    );
                  }
                }

                return DrawerHeader(
                  child: Text(
                      'Loading...'), // Show a loading indicator while fetching data
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                _signOut(context);
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: Center(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SAATHI',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Text('Private Checklists',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 12,
                        ),
                        privateChecklists.isEmpty
                            ? Text('No private checklists available.')
                            : Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: privateChecklists.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 70),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Card(
                                          elevation: 5,
                                          shape: BeveledRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: ListTile(
                                            shape: RoundedRectangleBorder(
                                              //<-- SEE HERE

                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            tileColor: Color(0xFF5E17EB),
                                            title: Text(
                                              privateChecklists[index].title,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChecklistDetailsPage(
                                                    checklist:
                                                        privateChecklists[
                                                            index],
                                                    isPrivate: true,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                        SizedBox(height: 20),
                        Text('Public Checklists',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        publicChecklists.isEmpty
                            ? Text('No public checklists available.')
                            : Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: publicChecklists.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          right: 12, bottom: 10),
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                          //<-- SEE HERE
                                          side: BorderSide(width: 1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        tileColor: Color(0xFFFFFDE0),
                                        title: Text(
                                          publicChecklists[index].title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChecklistDetailsPage(
                                                checklist:
                                                    publicChecklists[index],
                                                isPrivate: false,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        children: [
          Positioned(
            right: 80,
            bottom: 15,
            child: FloatingActionButton(
              backgroundColor: Color(0xFF5E17EB),
              heroTag: 'back',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CreatePublicChecklistPage(isPrivate: false)),
                );
              },
              child: const Icon(
                Icons.group,
                size: 40,
                color: Colors.white,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            right: 10,
            child: FloatingActionButton(
              backgroundColor: Color(0xFF5E17EB),
              heroTag: 'next',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CreatePublicChecklistPage(isPrivate: true)),
                );
              },
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
// Add more floating buttons if you want
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Clear any persisted authentication state
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userLoggedIn');

      // Navigate to the sign-in screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );

      // Clear Google Sign-In state to force user to sign in again
      await GoogleSignIn().signOut();
    } catch (e) {
      print("Error signing out: $e");
      // Handle sign out error
    }
  }

  Future<void> _loadPublicChecklists() async {
    // Get the email ID of the current user
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    // Query public checklists from Firestore
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('public_checklists').get();

    setState(() {
      publicChecklists = querySnapshot.docs
          .map((doc) => PublicChecklist.fromSnapshot(doc))
          .where((checklist) => checklist.isSharedWithUser(userEmail!))
          .toList();
    });
  }
}

class PrivateChecklist {
  String title;
  final List<ChecklistItem> locations;
  final List<ChecklistItem> documents;
  final List<ChecklistItem> activities;
  final List<ChecklistItem> notes;

  PrivateChecklist({
    required this.title,
    required this.locations,
    required this.documents,
    required this.activities,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'locations': locations.map((item) => item.toJson()).toList(),
      'documents': documents.map((item) => item.toJson()).toList(),
      'activities': activities.map((item) => item.toJson()).toList(),
      'notes': notes.map((item) => item.toJson()).toList(),
    };
  }

  factory PrivateChecklist.fromJson(Map<String, dynamic> json) {
    return PrivateChecklist(
      title: json['title'],
      locations: (json['locations'] as List)
          .map((item) => ChecklistItem.fromJson(item))
          .toList(),
      documents: (json['documents'] as List)
          .map((item) => ChecklistItem.fromJson(item))
          .toList(),
      activities: (json['activities'] as List)
          .map((item) => ChecklistItem.fromJson(item))
          .toList(),
      notes: (json['notes'] as List)
          .map((item) => ChecklistItem.fromJson(item))
          .toList(),
    );
  }
  void addLocation(String locationName) {
    locations.add(ChecklistItem(name: locationName));
  }

  // Method to remove a location
  void removeLocation(int index) {
    locations.removeAt(index);
  }

  // Method to update a location
  void updateLocation(int index, String newName) {
    locations[index].name = newName;
  }

  void addActivity(String activityName) {
    activities.add(ChecklistItem(name: activityName));
  }

  // Method to remove an activity
  void removeActivity(int index) {
    activities.removeAt(index);
  }

  // Method to update an activity
  void updateActivity(int index, String newName) {
    activities[index].name = newName;
  }

  // Method to add a document
  void addDocument(String documentName) {
    documents.add(ChecklistItem(name: documentName));
  }

  // Method to remove a document
  void removeDocument(int index) {
    documents.removeAt(index);
  }

  // Method to update a document
  void updateDocument(int index, String newName) {
    documents[index].name = newName;
  }

  void addNote(String documentName) {
    notes.add(ChecklistItem(name: documentName));
  }

  // Method to remove a document
  void removeNote(int index) {
    notes.removeAt(index);
  }

  // Method to update a document
  void updateNote(int index, String newName) {
    notes[index].name = newName;
  }
}

class PublicChecklist {
  String id;
  String title;
  List<ChecklistItem> locations;
  List<ChecklistItem> documents;
  List<ChecklistItem> activities;
  List<String> sharedUsers;
  String creatorEmail;
  List<ChecklistItem> notes; // Add notes field

  PublicChecklist({
    required this.id,
    required this.title,
    required this.locations,
    required this.documents,
    required this.activities,
    required this.sharedUsers,
    required this.creatorEmail,
    required this.notes, // Initialize notes field
  });

  // Add toJson method to convert PublicChecklist to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'locations': locations.map((item) => item.toJson()).toList(),
      'documents': documents.map((item) => item.toJson()).toList(),
      'activities': activities.map((item) => item.toJson()).toList(),
      'notes': notes.map((item) => item.toJson()).toList(),
      'sharedUsers': sharedUsers,
      'creatorEmail': creatorEmail,
    };
  }

  factory PublicChecklist.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return PublicChecklist(
      id: snapshot.id, // Assign the document ID to the id field
      title: data['title'] ?? '',
      locations: (data['locations'] as List<dynamic>? ?? [])
          .map((item) => ChecklistItem.fromJson(item))
          .toList(),
      documents: (data['documents'] as List<dynamic>? ?? [])
          .map((item) => ChecklistItem.fromJson(item))
          .toList(),
      activities: (data['activities'] as List<dynamic>? ?? [])
          .map((item) => ChecklistItem.fromJson(item))
          .toList(),
      sharedUsers: (data['sharedUsers'] as List<dynamic>? ?? [])
          .map((user) => user.toString())
          .toList(),
      creatorEmail: data['creatorEmail'] ?? '',
      notes: (data['notes'] as List<dynamic>? ?? [])
          .map((item) => ChecklistItem.fromJson(item))
          .toList(),
    );
  }

  // Method to check if a user is shared with this checklist
  bool isSharedWithUser(String userEmail) {
    return sharedUsers.contains(userEmail);
  }

  // Method to add a user to the shared users list
  void addUserToShared(String userEmail) {
    sharedUsers.add(userEmail);
  }

  // Method to remove a user from the shared users list
  void removeUserFromShared(String userEmail) {
    sharedUsers.remove(userEmail);
  }

  // Method to mark an item complete
  void markItemComplete(ChecklistItem item) {
    // Implement marking item complete
  }
  void addLocation(String locationName) {
    locations.add(ChecklistItem(name: locationName));
  }

  // Method to remove a location
  void removeLocation(int index) {
    locations.removeAt(index);
  }

  // Method to update a location
  void updateLocation(int index, String newName) {
    locations[index].name = newName;
  }

  void addActivity(String activityName) {
    activities.add(ChecklistItem(name: activityName));
  }

  // Method to remove an activity
  void removeActivity(int index) {
    activities.removeAt(index);
  }

  // Method to update an activity
  void updateActivity(int index, String newName) {
    activities[index].name = newName;
  }

  // Method to add a document
  void addDocument(String documentName) {
    documents.add(ChecklistItem(name: documentName));
  }

  // Method to remove a document
  void removeDocument(int index) {
    documents.removeAt(index);
  }

  // Method to update a document
  void updateDocument(int index, String newName) {
    documents[index].name = newName;
  }

  void addNote(String documentName) {
    documents.add(ChecklistItem(name: documentName));
  }

  // Method to remove a document
  void removeNote(int index) {
    documents.removeAt(index);
  }

  // Method to update a document
  void updateNote(int index, String newName) {
    documents[index].name = newName;
  }
}

class ChecklistItem {
  String name;
  bool isChecked; // Add isChecked property

  ChecklistItem(
      {required this.name,
      this.isChecked = false}); // Initialize isChecked with false

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isChecked': isChecked
    }; // Include isChecked in JSON serialization
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
        name: json['name'],
        isChecked: json['isChecked'] ??
            false); // Initialize isChecked with false if not present in JSON
  }
}

class CreatePublicChecklistPage extends StatefulWidget {
  final bool isPrivate;

  CreatePublicChecklistPage({super.key, required this.isPrivate});
  @override
  _CreatePublicChecklistPageState createState() =>
      _CreatePublicChecklistPageState();
}

class _CreatePublicChecklistPageState extends State<CreatePublicChecklistPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController activityController = TextEditingController();
  TextEditingController documentController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  List<ChecklistItem> locations = [];
  List<ChecklistItem> activities = [];
  List<ChecklistItem> documents = [];
  List<String> sharedUsers = [];
  List<ChecklistItem> notes = [];
  List<PrivateChecklist> privateChecklists = [];

  // Lists to track checked state
  List<bool> locationCheckedList = [];
  List<bool> activityCheckedList = [];
  List<bool> documentCheckedList = [];
  List<bool> noteCheckedList = [];

  @override
  void initState() {
    super.initState();
    // Initialize checked lists with false values for all items
    locationCheckedList = List.generate(locations.length, (_) => false);
    activityCheckedList = List.generate(activities.length, (_) => false);
    documentCheckedList = List.generate(documents.length, (_) => false);
    noteCheckedList = List.generate(documents.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Checklist'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Checklist Name'),
            ),
            SizedBox(height: 16.0),
            _buildChecklistInputField(
              title: 'Locations to Visit',
              items: locations,
              checkedList: locationCheckedList,
              controller: locationController,
            ),
            SizedBox(height: 16.0),
            _buildChecklistInputField(
              title: 'Activities to Do',
              items: activities,
              checkedList: activityCheckedList,
              controller: activityController,
            ),
            SizedBox(height: 16.0),
            _buildChecklistInputField(
              title: 'Documents to Carry',
              items: documents,
              checkedList: documentCheckedList,
              controller: documentController,
            ),
            SizedBox(height: 16.0),
            _buildChecklistInputField(
              title: 'Notes',
              items: notes,
              checkedList: noteCheckedList,
              controller: noteController,
            ),
            SizedBox(height: 16.0),
            if (!widget.isPrivate)
              TextField(
                controller: userIdController,
                decoration:
                    InputDecoration(labelText: 'Enter User IDs to Share'),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _createChecklist,
              child: Text('Create Checklist'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistInputField({
    required String title,
    required List<ChecklistItem> items,
    required List<bool> checkedList,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            TextEditingController itemController = TextEditingController(
              text: items[index].name,
            );
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: itemController,
                    onChanged: (value) {
                      items[index].name = value;
                    },
                    decoration: InputDecoration(labelText: 'Enter $title'),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      items.removeAt(index);
                    });
                  },
                  icon: Icon(Icons.remove_circle),
                ),
              ],
            );
          },
        ),
        IconButton(
          onPressed: () {
            setState(() {
              items.add(ChecklistItem(name: ''));
            });
          },
          icon: Icon(Icons.add_circle),
        ),
      ],
    );
  }

  void _createChecklist() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? creatorEmail = user?.email;
    String checklistName = nameController.text.trim();
    if (checklistName.isNotEmpty && creatorEmail != null) {
      List<String> sharedUserEmails =
          userIdController.text.split(',').map((e) => e.trim()).toList();
      // Include creator's email in the shared users list
      sharedUserEmails.add(creatorEmail);
      PublicChecklist newChecklist = PublicChecklist(
        title: checklistName,
        locations: List.from(locations),
        documents: List.from(documents),
        activities: List.from(activities),
        sharedUsers: sharedUserEmails,
        creatorEmail: creatorEmail,
        id: "",
        notes: List.from(notes),
      );
      // Save checklist to Firestore
      if (widget.isPrivate) {
        PrivateChecklist list = PrivateChecklist(
          title: checklistName,
          locations: List.from(locations),
          documents: List.from(documents),
          activities: List.from(activities),
          notes: List.from(notes),
        );
        privateChecklists.add(
          PrivateChecklist(
            title: checklistName,
            locations: List.from(locations),
            documents: List.from(documents),
            activities: List.from(activities),
            notes: List.from(notes),
          ),
        );
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String checklistKey = 'private_checklist_${checklistName}';

        prefs.setString(checklistKey, jsonEncode(list.toJson()));
      } else {
        DocumentReference checklistRef = await FirebaseFirestore.instance
            .collection('public_checklists')
            .add(newChecklist.toJson());

        // Get the ID of the newly created checklist document
        String checklistId = checklistRef.id;

        // Update the checklist with the document ID
        await checklistRef.update({'id': checklistId});
      }

      // Navigate back to the home page
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter checklist name')),
      );
    }
  }
}

class NumberGenerator {
  Future<List<String>> slowNumbers() async {
    return Future.delayed(
      const Duration(milliseconds: 1000),
      () => numbers,
    );
  }

  List<String> get numbers => List.generate(5, (index) => number);

  String get number => Random().nextInt(99999).toString();
}
