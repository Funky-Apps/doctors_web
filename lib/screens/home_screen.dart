import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_web/core/widgets/round_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/constants/constants.dart';
import '../widgets/text_field_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? doctorId;
  String? doctorName;
  late Future<List<Map<String, dynamic>>> submissionsFuture;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginDoctor() async {
    String enteredId = _idController.text.trim();
    String enteredPassword = _passwordController.text.trim();

    final snapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .where('uid', isEqualTo: enteredId)
        .where('password', isEqualTo: enteredPassword)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        doctorId = enteredId;
        doctorName = snapshot.docs.first['name'];
        submissionsFuture = _fetchSubmissions(doctorId!);
        _showAccountDetailsDialog(snapshot.docs.first.data());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid ID or Password')),
      );
    }
  }

  void _showAccountDetailsDialog(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.person, size: 50, color: Colors.blue),
            SizedBox(width: 8),
            Text('Welcome, ${doctor['name'] ?? 'Unknown'}!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UID: ${doctor['uid'] ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Specialization: ${doctor['special_area'] ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Hospital: ${doctor['hospital'] ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Mobile Number: ${doctor['mobile_number'] ?? 'N/A'}'),
            SizedBox(height: 8),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Go to Registrations'),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchSubmissions(String doctorId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('submissions')
        .where('doctor_uid', isEqualTo: doctorId)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> _generatePDF(List<Map<String, dynamic>> submissions) async {
    final pdf = pw.Document();

    for (var submission in submissions) {
      final patientId = submission['patient_id'] ?? 'Unknown';
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(16.0),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Patient Registration Data',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),

                  // Section 1: Personal Information
                  pw.Text('1. Personal Information',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text('Patient ID: $patientId'),
                  pw.Text(
                      'Full Name: ${submission['patient_name'] ?? 'Unknown'}'),
                  pw.Text('Date of Birth: ${submission['dob'] ?? 'N/A'}'),
                  pw.Text('Gender: ${submission['gender'] ?? 'N/A'}'),
                  pw.Text('Email: ${submission['email'] ?? 'N/A'}'),
                  pw.Text(
                      'Phone Number: ${submission['phone_number'] ?? 'N/A'}'),
                  pw.Text('Address: ${submission['address'] ?? 'N/A'}'),
                  pw.Text(
                      'Emergency Contact: ${submission['emergency_contact'] ?? 'N/A'}'),

                  pw.SizedBox(height: 16),

                  // Section 2: Medical History
                  pw.Text('2. Medical History',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text(
                      'Pre-existing Conditions: ${submission['conditions']?.join(', ') ?? 'N/A'}'),
                  pw.Text(
                      'Current Medications: ${submission['medication'] ?? 'N/A'}'),
                  pw.Text(
                      'Past Surgeries: ${submission['surgeries'] ?? 'N/A'}'),
                  pw.Text(
                      'Known Allergies: ${submission['allergies'] ?? 'N/A'}'),

                  pw.SizedBox(height: 16),

                  // Section 3: Symptoms & Current Health Status
                  pw.Text('3. Symptoms & Current Health Status',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text(
                      'Symptoms: ${submission['symptoms']?.join(', ') ?? 'N/A'}'),
                  pw.Text('Pain Level: ${submission['pain_level'] ?? 'N/A'}'),
                  pw.Text('Recent Travel: ${submission['travel'] ?? 'N/A'}'),
                  pw.Text(
                      'Recent Sick Contact: ${submission['contact_with_sick_person'] ?? 'N/A'}'),

                  pw.SizedBox(height: 16),

                  // Section 4: Lifestyle & Habits
                  pw.Text('4. Lifestyle & Habits',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text('Smoking: ${submission['smoke'] ?? 'N/A'}'),
                  pw.Text(
                      'Alcohol Consumption: ${submission['alcohol'] ?? 'N/A'}'),
                  pw.Text('Exercise: ${submission['exercise'] ?? 'N/A'}'),
                  pw.Text('Sleep Duration: ${submission['sleep'] ?? 'N/A'}'),
                  pw.Text(
                      'Dietary Preferences: ${submission['dietary_preferences'] ?? 'N/A'}'),

                  pw.SizedBox(height: 16),

                  // Section 5: Additional Information
                  pw.Text('5. Additional Information',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text(
                      'Concerns: ${submission['additional_concerns'] ?? 'N/A'}'),
                  // pw.Text(
                  //     'Health Tips Subscription: ${submission['receive_email'] ?? 'N/A'}'),

                  pw.SizedBox(height: 16),

                  pw.Text(
                    'Submitted on: ${submission['submitted_at'] != null ? DateFormat('yyyy-MM-dd at HH:mm:ss').format(submission['submitted_at'].toDate()) : 'N/A'}',
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    final pdfBytes = await pdf.save();
    final blob = html.Blob([Uint8List.fromList(pdfBytes)], 'application/pdf');

    for (var submission in submissions) {
      final patientId = submission['patient_id'] ?? 'submissions';
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$patientId.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.lightBlue.shade100,
        title: Text(
            doctorId == null ? 'Doctor Login' : 'Submissions for $doctorName'),
      ),
      body: doctorId == null
          ? Container(
              margin: EdgeInsets.all(25),
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(Constants.appLogo, width: 300),
                  SizedBox(height: 20),
                  TextFieldWidget(
                    controller: _idController,
                    label: 'Doctor ID',
                    hint: 'Enter your ID',
                  ),
                  SizedBox(height: 10),
                  SizedBox(height: 10),
                  TextFieldWidget(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                  ),
                  SizedBox(height: 20),
                  RoundButton(onPressed: _loginDoctor, label: 'Login'),
                ],
              ),
            )
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: submissionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No submissions found.'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final submission = snapshot.data![index];
                    return Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          submission['patient_name'] ?? 'Unknown Patient',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          submission['phone_number'] ?? 'Unknown Phone',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.picture_as_pdf,
                              color: Colors.redAccent),
                          onPressed: () => _generatePDF([submission]),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
