import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:docx_template/docx_template.dart';

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

  Future<void> _generateExcel(List<Map<String, dynamic>> submissions) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    sheet.appendRow([
      TextCellValue('Patient Name'),
      TextCellValue('DOB'),
      TextCellValue('Email'),
      TextCellValue('Phone Number'),
      TextCellValue('Address'),
      TextCellValue('Emergency Contact'),
      TextCellValue('Gender'),
      TextCellValue('Conditions'),
      TextCellValue('Medications'),
      TextCellValue('Surgeries'),
      TextCellValue('Allergies'),
      TextCellValue('Submitted At'),
    ]);

    for (var submission in submissions) {
      sheet.appendRow([
        TextCellValue(submission['patient_name'] ?? 'Unknown'),
        TextCellValue(submission['dob'] ?? 'N/A'),
        TextCellValue(submission['email'] ?? 'N/A'),
        TextCellValue(submission['phone_number'] ?? 'N/A'),
        TextCellValue(submission['address'] ?? 'N/A'),
        TextCellValue(submission['emergency_contact'] ?? 'N/A'),
        TextCellValue(submission['gender'] ?? 'N/A'),
        TextCellValue(submission['conditions'] ?? 'N/A'),
        TextCellValue(submission['medication'] ?? 'N/A'),
        TextCellValue(submission['surgeries'] ?? 'N/A'),
        TextCellValue(submission['allergies'] ?? 'N/A'),
        TextCellValue(submission['submitted_at'] != null
            ? DateFormat('dd/MM/yyyy').format(submission['submitted_at'].toDate())
            : 'N/A'),
      ]);
    }

    final excelBytes = await excel.encode();

    if (kIsWeb) {
      final blob = html.Blob([Uint8List.fromList(excelBytes!)],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'submissions.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  // Future<void> _generateWord(List<Map<String, dynamic>> submissions) async {
  //   try {
  //     final ByteData data = await rootBundle.load('assets/template.docx');
  //     final Uint8List bytes = data.buffer.asUint8List();
  //     final docx = await DocxTemplate.fromBytes(bytes);
  //
  //     final content = Content();
  //     final list = submissions.map((submission) {
  //       return RowContent()
  //         ..add(PlainTextContent("patient_name", submission['patient_name'] ?? 'Unknown'))
  //         ..add(PlainTextContent("dob", submission['dob'] ?? 'N/A'))
  //         ..add(PlainTextContent("email", submission['email'] ?? 'N/A'))
  //         ..add(PlainTextContent("phone_number", submission['phone_number'] ?? 'N/A'))
  //         ..add(PlainTextContent("address", submission['address'] ?? 'N/A'))
  //         ..add(PlainTextContent("emergency_contact", submission['emergency_contact'] ?? 'N/A'))
  //         ..add(PlainTextContent("gender", submission['gender'] ?? 'N/A'))
  //         ..add(PlainTextContent("conditions", submission['conditions'] ?? 'N/A'))
  //         ..add(PlainTextContent("medication", submission['medication'] ?? 'N/A'))
  //         ..add(PlainTextContent("surgeries", submission['surgeries'] ?? 'N/A'))
  //         ..add(PlainTextContent("allergies", submission['allergies'] ?? 'N/A'))
  //         ..add(PlainTextContent("submitted_at",
  //             submission['submitted_at'] != null
  //                 ? DateFormat('dd/MM/yyyy').format(submission['submitted_at'].toDate())
  //                 : 'N/A'));
  //     }).toList();
  //
  //     content.add(TableContent("table", list));
  //
  //     final docGenerated = await docx.generate(content);
  //     if (docGenerated != null) {
  //       if (kIsWeb) {
  //         final blob = html.Blob([docGenerated], 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
  //         final url = html.Url.createObjectUrlFromBlob(blob);
  //         final anchor = html.AnchorElement(href: url)
  //           ..setAttribute('download', 'submissions.docx')
  //           ..click();
  //         html.Url.revokeObjectUrl(url);
  //       } else {
  //         final outputDir = await getTemporaryDirectory();
  //         final filePath = '${outputDir.path}/submissions.docx';
  //         final file = File(filePath);
  //         await file.writeAsBytes(docGenerated);
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('File saved to $filePath')),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error generating Word file: $e')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue.shade100,
        title: Text(doctorId == null ? 'Doctor Login' : '$doctorName'),
      ),
      body: doctorId == null
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _idController, decoration: InputDecoration(labelText: 'Doctor ID')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _loginDoctor, child: Text('Login')),
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
              return ListTile(
                title: Text(submission['patient_name'] ?? 'Unknown Patient'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: Icon(Icons.download), onPressed: () => _generateExcel([submission])),
                    // IconButton(icon: Icon(Icons.file_copy), onPressed: () => _generateWord([submission]))
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
