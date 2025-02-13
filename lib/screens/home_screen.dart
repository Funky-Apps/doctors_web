import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart'; // Import the excel package
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:html' as html;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedDoctorId;
  String? selectedDoctorName;

  late Future<List<Map<String, dynamic>>> submissionsFuture;

  @override
  void initState() {
    super.initState();
    selectedDoctorId = null;
    selectedDoctorName = null;
  }

  // Fetch doctors
  Future<List<Map<String, dynamic>>> _fetchDoctors() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('doctors').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Fetch submissions for selected doctor
  Future<List<Map<String, dynamic>>> _fetchSubmissions(String doctorId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('submissions')
        .where('doctor_uid', isEqualTo: doctorId)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Generate Excel for web
  Future<void> _generateExcel(List<Map<String, dynamic>> submissions) async {
    try {
      var excel = Excel.createExcel(); // Create new Excel instance
      Sheet sheet = excel['Sheet1']; // Create sheet in Excel

      // Add headers
      sheet.appendRow([
        TextCellValue('Patient Name'),
        TextCellValue('Age'),
        TextCellValue('Phone Number'),
        TextCellValue('Do You Have Allergies'),
        TextCellValue('Do You Have Chronic Diseases'),
        TextCellValue('Do You Smoke'),
        TextCellValue('Do You Have High Blood Pressure'),
        TextCellValue('Have You Had Any Surgeries'),
        TextCellValue('Submitted At'),
      ]);

      // Add submission data
      for (var submission in submissions) {
        sheet.appendRow([
          TextCellValue(submission['patient_name'] ?? 'Unknown'),
          TextCellValue(submission['age']?.toString() ?? 'N/A'),
          TextCellValue(submission['phone_number'] ?? 'N/A'),
          TextCellValue(submission['do_you_have_allergies'] ?? 'N/A'),
          TextCellValue(submission['do_you_have_chronic_diseases'] ?? 'N/A'),
          TextCellValue(submission['do_you_smoke'] ?? 'N/A'),
          TextCellValue(submission['do_you_have_high_blood_pressure'] ?? 'N/A'),
          TextCellValue(submission['have_you_had_any_surgeries'] ?? 'N/A'),
          TextCellValue(submission['submitted_at'] != null
              ? DateFormat('dd/MM/yyyy')
                  .format(submission['submitted_at'].toDate())
              : 'N/A'),
        ]);
      }

      // Encode Excel content
      final excelBytes = await excel.encode();

      if (kIsWeb) {
        // Web - trigger download of the Excel file
        final blob = html.Blob([
          excelBytes
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = 'blank'
          ..download = 'submission.xlsx'
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile/Desktop (Android/iOS or macOS/Windows) - save Excel to the file system
        final output = await getTemporaryDirectory();
        final file = File('${output.path}/submission.xlsx');
        await file.writeAsBytes(excelBytes!);
      }
    } catch (e) {
      print('Error generating or downloading the file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue.shade100,
        title: Text(
          selectedDoctorId == null || selectedDoctorName == null
              ? 'Please select a doctor'
              : 'ID: $selectedDoctorId Name: $selectedDoctorName',
        ),
        actions: [
          FutureBuilder<List<Map<String, dynamic>>>(
            // Fetch doctors list
            future: _fetchDoctors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return IconButton(
                  icon: Icon(Icons.error),
                  onPressed: () {},
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return IconButton(
                  icon: Icon(Icons.error),
                  onPressed: () {},
                );
              }

              final doctors = snapshot.data!;

              return PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    selectedDoctorId = value;
                    selectedDoctorName = doctors
                        .firstWhere((doctor) => doctor['uid'] == value)['name'];

                    // Fetch the submissions when a doctor is selected
                    submissionsFuture = _fetchSubmissions(selectedDoctorId!);
                  });
                },
                itemBuilder: (BuildContext context) {
                  return doctors.map((doctor) {
                    return PopupMenuItem<String>(
                      value: doctor['uid'],
                      child: Text(doctor['name']),
                    );
                  }).toList();
                },
              );
            },
          ),
        ],
      ),
      body: selectedDoctorId == null
          ? Center(child: Text('Please select a doctor'))
          : FutureBuilder<List<Map<String, dynamic>>>(
              // Fetch submissions
              future: submissionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No submissions found.'));
                }

                final submissions = snapshot.data!;

                return ListView.builder(
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final submission = submissions[index];
                    return Column(
                      children: [
                        Card(
                          color: Colors.white,
                          child: ListTile(
                            title: Text(submission['patient_name'] ?? 'Unknown Patient'),
                            subtitle: Text(
                              'Age: ${submission['age']}, Phone: ${submission['phone_number']}',
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.download),
                              onPressed: () => _generateExcel([submission]),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Submission Details'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Patient Name: ${submission['patient_name']}'),
                                          Text('Age: ${submission['age']}'),
                                          Text('Phone Number: ${submission['phone_number']}'),
                                          Text('Do You Have Allergies: ${submission['do_you_have_allergies']}'),
                                          Text('Do You Have Chronic Diseases: ${submission['do_you_have_chronic_diseases']}'),
                                          Text('Do You Smoke: ${submission['do_you_smoke']}'),
                                          Text('Do You Have High Blood Pressure: ${submission['do_you_have_high_blood_pressure']}'),
                                          Text('Have You Had Any Surgeries: ${submission['have_you_had_any_surgeries']}'),
                                          Text('Submitted At: ${submission['submitted_at'] != null ? DateFormat('dd/MM/yyyy').format(submission['submitted_at'].toDate()) : 'N/A'}'),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        Divider(),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }
}
