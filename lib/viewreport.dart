import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Viewreport extends StatefulWidget {
  final String userid;
  const Viewreport({super.key, required this.userid});

  @override
  State<Viewreport> createState() => _ViewreportState();
}

class _ViewreportState extends State<Viewreport> {
  List<Map<String, dynamic>> reports = [];
  int reportCount = 0;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.userid)
          .collection('report')
          .get();

      List<Map<String, dynamic>> fetchedReports = querySnapshot.docs.map((doc) {
        return {
          'reportcreated': doc['reportcreated'],
          'reporttitle': doc['reporttitle'],
          'userID': doc['userID'],
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

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMMM d, yyyy h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show the total number of reports in a card-like widget
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Total Reports: $reportCount',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
                          border: Border.all(color: Colors.white, width: 1)),
                      child: DataTable(
                        columnSpacing: 12,
                        horizontalMargin: 10,
                        headingTextStyle: const TextStyle(color: Colors.white),
                        dataTextStyle: const TextStyle(color: Colors.white),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Report Created',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Report Title',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'User ID',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: reports.map((report) {
                          return DataRow(
                            cells: [
                              DataCell(Text(formatTimestamp(
                                  report['reportcreated']))), // Format the date
                              DataCell(Text(report['reporttitle'])),
                              DataCell(Text(report['userID'])),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      'No reports available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
