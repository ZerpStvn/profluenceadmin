import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Enrolledusers extends StatefulWidget {
  const Enrolledusers({super.key});

  @override
  State<Enrolledusers> createState() => _EnrolledusersState();
}

class _EnrolledusersState extends State<Enrolledusers> {
  List<Map<String, dynamic>> reports = [];
  int reportCount = 0;

  @override
  void initState() {
    super.initState();
    fetchEnrolled();
  }

  Future<void> fetchEnrolled() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('enrolled').get();

      List<Map<String, dynamic>> fetchedReports = querySnapshot.docs.map((doc) {
        return {
          'email': doc['email'],
          'name': doc['name'],
          'schoolid': doc['schoolid'],
        };
      }).toList();

      setState(() {
        reports = fetchedReports;
        reportCount = reports.length;
      });
    } catch (error) {
      debugPrint('Error fetching reports: $error');
    }
  }

  Future<void> addNewEnrolledUser(
      String name, String email, String schoolid) async {
    try {
      await FirebaseFirestore.instance.collection('enrolled').add({
        'name': name,
        'email': email,
        'schoolid': schoolid,
      });

      // Refresh the list after adding a new user
      fetchEnrolled();
    } catch (error) {
      debugPrint('Error adding new enrolled user: $error');
    }
  }

  void showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final schoolIdController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Enrolled User'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: schoolIdController,
                    decoration: const InputDecoration(labelText: 'School ID'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a school ID';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Add the new user to Firestore
                  addNewEnrolledUser(
                    nameController.text.trim(),
                    emailController.text.trim(),
                    schoolIdController.text.trim(),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show the total number of reports in a card-like widget
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Total Enrolled: $reportCount',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: showAddUserDialog,
                child: const Text("Add new"),
              ),
            ],
          ),
          // Display reports in a DataTable
          Expanded(
            child: reports.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: DataTable(
                        columnSpacing: 12,
                        horizontalMargin: 10,
                        headingTextStyle: const TextStyle(color: Colors.white),
                        dataTextStyle: const TextStyle(color: Colors.white),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'School ID',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: reports.map((report) {
                          return DataRow(
                            cells: [
                              DataCell(Text(report['name'])), // Name
                              DataCell(Text(report['email'])), // Email
                              DataCell(Text(report['schoolid'])), // School ID
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      'No Enrolled users available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
