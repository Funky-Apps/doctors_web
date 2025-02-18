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
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid ID or Password')),
      );
    }
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Patient Submissions',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              for (var submission in submissions)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Name: ${submission['patient_name'] ?? 'Unknown'}'),
                    pw.Text('DOB: ${submission['dob'] ?? 'N/A'}'),
                    pw.Text('Email: ${submission['email'] ?? 'N/A'}'),
                    pw.Text('Phone: ${submission['phone_number'] ?? 'N/A'}'),
                    pw.Text('Address: ${submission['address'] ?? 'N/A'}'),
                    pw.Text(
                        'Emergency Contact: ${submission['emergency_contact'] ?? 'N/A'}'),
                    pw.Text('Gender: ${submission['gender'] ?? 'N/A'}'),
                    pw.Text(
                        'Conditions: ${submission['conditions'].join(', ') ?? 'N/A'}'),
                    pw.Text(
                        'Medications: ${submission['medication'] ?? 'N/A'}'),
                    pw.Text('Surgeries: ${submission['surgeries'] ?? 'N/A'}'),
                    pw.Text('Allergies: ${submission['allergies'] ?? 'N/A'}'),
                    pw.Text(
                        'Symptoms: ${submission['symptoms'].join(', ') ?? 'N/A'}'),
                    pw.Text('Pain Level: ${submission['pain_level'] ?? 'N/A'}'),
                    pw.Text('Travel: ${submission['travel'] ?? 'N/A'}'),
                    pw.Text(
                        'Contact with Sick Person: ${submission['contact_with_sick_person'] ?? 'N/A'}'),
                    pw.Text('Smoke: ${submission['smoke'] ?? 'N/A'}'),
                    pw.Text('Alcohol: ${submission['alcohol'] ?? 'N/A'}'),
                    pw.Text('Exercise: ${submission['exercise'] ?? 'N/A'}'),
                    pw.Text('Sleep: ${submission['sleep'] ?? 'N/A'}'),
                    pw.Text(
                        'Dietary Preferences: ${submission['dietary_preferences'] ?? 'N/A'}'),
                    pw.Text(
                        'Additional Concerns: ${submission['additional_concerns'] ?? 'N/A'}'),
                    pw.Text(
                        'Submitted At: ${submission['submitted_at'] != null ? DateFormat('dd/MM/yyyy').format(submission['submitted_at'].toDate()) : 'N/A'}'),
                    pw.Divider(),
                  ],
                )
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();
    final blob = html.Blob([Uint8List.fromList(pdfBytes)], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'submissions.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.lightBlue.shade100,
        title: Text(doctorId == null ? 'Doctor Login' : 'Submissions for $doctorName'),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          icon: Icon(Icons.picture_as_pdf, color: Colors.redAccent),
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
