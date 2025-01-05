import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profluenceadmin/viewreport.dart';

class Repostlogs extends StatefulWidget {
  const Repostlogs({super.key});

  @override
  State<Repostlogs> createState() => _RepostlogsState();
}

class _RepostlogsState extends State<Repostlogs> {
  List<Map<String, dynamic>> userData = [];
  List<Map<String, dynamic>> filteredData = [];
  int rowsPerPage = 25; // Number of rows per page
  int currentPage = 0; // Current page number
  String searchQuery = ''; // Search query text

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> fetchUserData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>> users = snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      setState(() {
        userData = users;
        filteredData = users;
      });
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
  }

  // Function to handle pagination logic
  List<Map<String, dynamic>> getPaginatedData() {
    int start = currentPage * rowsPerPage;
    int end = start + rowsPerPage;
    return filteredData.sublist(
        start, end > filteredData.length ? filteredData.length : end);
  }

  Future<void> updatemute(String userid, int status) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userid)
          .update({'ismute': status});
      setState(() {
        fetchUserData();
      });
    } catch (error) {
      debugPrint("$error");
    }
  }

  Future<void> updateBanning(String userid, int status) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userid)
          .update({'isvalid': status});
      setState(() {
        fetchUserData();
      });
    } catch (error) {
      debugPrint("$error");
    }
  }

  void search(String query) {
    setState(() {
      searchQuery = query;
      filteredData = userData
          .where((user) =>
              user['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              user['email']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  bool isviewreport = false;
  String userid = "";
  @override
  Widget build(BuildContext context) {
    return isviewreport == false
        ? Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 340,
                    child: TextField(
                      onChanged: search,
                      style: const TextStyle(
                          color: Colors.white), // Set text color to white
                      decoration: InputDecoration(
                        hintText: 'Search by name or email',
                        hintStyle: const TextStyle(
                            color: Colors
                                .white70), // Set hint text color to a lighter white
                        prefixIcon: const Icon(Icons.search,
                            color: Colors.white), // Set the icon color to white
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors.white), // Set border color to white
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors
                                  .white), // Set focused border color to white
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                // Data table
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 1)),
                      child: DataTable(
                        headingTextStyle: const TextStyle(color: Colors.white),
                        dataTextStyle: const TextStyle(color: Colors.white),
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('School ID')),
                          DataColumn(label: Text('Status')),
                          DataColumn(
                              label: Center(child: Text('Select Option'))),
                        ],
                        rows: getPaginatedData().map((user) {
                          return DataRow(cells: [
                            DataCell(Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    foregroundImage:
                                        NetworkImage(user['profileImage']),
                                  ),
                                  Text(user['name'] ?? 'No Name'),
                                ],
                              ),
                            )),
                            DataCell(Text(user['email'] ?? 'No Email')),
                            DataCell(Text(user['schoolId'] ?? 'No School ID')),
                            DataCell(Icon(Icons.circle_rounded,
                                color: user['isonline'] == 1
                                    ? Colors.greenAccent
                                    : Colors.white)),
                            DataCell(Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent),
                                  onPressed: () {
                                    updateBanning(user['userid'],
                                        user['isvalid'] == 1 ? 2 : 1);
                                  },
                                  child: Text(
                                    user['isvalid'] == 1 ? "Ban" : "Unban",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.greenAccent),
                                  onPressed: () {
                                    setState(() {
                                      userid = user['userid'];
                                      isviewreport = true;
                                      debugPrint(userid);
                                    });
                                  },
                                  child: const Text(
                                    "Report logs",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                // Pagination controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: currentPage > 0
                          ? () {
                              setState(() {
                                currentPage--;
                              });
                            }
                          : null,
                    ),
                    Text(
                      'Page ${currentPage + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      onPressed:
                          (currentPage + 1) * rowsPerPage < filteredData.length
                              ? () {
                                  setState(() {
                                    currentPage++;
                                  });
                                }
                              : null,
                    ),
                  ],
                ),
              ],
            ),
          )
        : Viewreport(userid: userid);
  }

  void showmodallogs(String userid) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("User Logs"),
          content: SizedBox(
            width: 183,
            height: 230,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('userlogs')
                        .doc(userid)
                        .collection('logs')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LinearProgressIndicator();
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return const Text("No Current Logs");
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final docData = snapshot.data!.docs[index].data();
                            return SizedBox(
                              width: 153,
                              height: 80,
                              child: ListTile(
                                title: Text(
                                  docData['logs'] ?? 'No Log Data',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                subtitle: Text(docData['created'] != null
                                    ? formatTimestamp(docData['created'])
                                    : 'No Timestamp'),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('MMMM d, yyyy, h:mm a').format(dateTime);
    return formattedDate;
  }
}
