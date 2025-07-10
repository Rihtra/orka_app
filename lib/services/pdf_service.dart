// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'models/pendaftaran_model.dart';

// class PDFService {
//   static Future<void> generatePendaftaranPDF(StatusUKM status) async {
//     // Request permission untuk Android
//     if (Platform.isAndroid) {
//       var status = await Permission.storage.request();
//       if (!status.isGranted) {
//         throw Exception('Storage permission denied');
//       }
//     }

//     // Create PDF document
//     final pdf = pw.Document();

//     // Load font asset (pastikan font ada di pubspec.yaml)
//     final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
//     final ttf = pw.Font.ttf(fontData);
    
//     final fontBoldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
//     final ttfBold = pw.Font.ttf(fontBoldData);

//     // Add page
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               // Header
//               pw.Container(
//                 width: double.infinity,
//                 padding: pw.EdgeInsets.all(20),
//                 decoration: pw.BoxDecoration(
//                   color: PdfColors.blue,
//                   borderRadius: pw.BorderRadius.circular(10),
//                 ),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text(
//                       'SURAT KETERANGAN PENDAFTARAN',
//                       style: pw.TextStyle(
//                         font: ttfBold,
//                         fontSize: 20,
//                         color: PdfColors.white,
//                       ),
//                     ),
//                     pw.SizedBox(height: 5),
//                     pw.Text(
//                       'Unit Kegiatan Mahasiswa',
//                       style: pw.TextStyle(
//                         font: ttf,
//                         fontSize: 14,
//                         color: PdfColors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               pw.SizedBox(height: 30),
              
//               // Informasi Organisasi
//               pw.Container(
//                 padding: pw.EdgeInsets.all(15),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.grey300),
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text(
//                       'INFORMASI ORGANISASI',
//                       style: pw.TextStyle(
//                         font: ttfBold,
//                         fontSize: 16,
//                         color: PdfColors.blue,
//                       ),
//                     ),
//                     pw.SizedBox(height: 15),
//                     _buildInfoRow('Nama Organisasi', status.name, ttf, ttfBold),
//                     _buildInfoRow('Kategori', status.category, ttf, ttfBold),
//                     _buildInfoRow('Deskripsi', status.description, ttf, ttfBold),
//                     if (status.divisi != null)
//                       _buildInfoRow('Divisi', status.divisi!, ttf, ttfBold),
//                   ],
//                 ),
//               ),

//               pw.SizedBox(height: 20),

//               // Informasi Pendaftar
//               pw.Container(
//                 padding: pw.EdgeInsets.all(15),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.grey300),
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text(
//                       'INFORMASI PENDAFTAR',
//                       style: pw.TextStyle(
//                         font: ttfBold,
//                         fontSize: 16,
//                         color: PdfColors.blue,
//                       ),
//                     ),
//                     pw.SizedBox(height: 15),
//                     _buildInfoRow('Nama', status.nama ?? '-', ttf, ttfBold),
//                     _buildInfoRow('NIM', status.nim ?? '-', ttf, ttfBold),
//                     _buildInfoRow('Program Studi', status.prodi ?? '-', ttf, ttfBold),
//                     _buildInfoRow('Semester', status.semester ?? '-', ttf, ttfBold),
//                     _buildInfoRow('No. WhatsApp', status.nomorWa ?? '-', ttf, ttfBold),
//                   ],
//                 ),
//               ),

//               pw.SizedBox(height: 20),

//               // Status Pendaftaran
//               pw.Container(
//                 padding: pw.EdgeInsets.all(15),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.grey300),
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text(
//                       'STATUS PENDAFTARAN',
//                       style: pw.TextStyle(
//                         font: ttfBold,
//                         fontSize: 16,
//                         color: PdfColors.blue,
//                       ),
//                     ),
//                     pw.SizedBox(height: 15),
//                     _buildInfoRow('Status', status.status, ttf, ttfBold),
//                     _buildInfoRow('Tanggal Pendaftaran', status.registrationDate, ttf, ttfBold),
//                     if (status.jadwalWawancara != null)
//                       _buildInfoRow('Jadwal Wawancara', status.jadwalWawancara!, ttf, ttfBold),
//                   ],
//                 ),
//               ),

//               pw.SizedBox(height: 20),

//               // Alasan Bergabung
//               if (status.alasan != null) ...[
//                 pw.Container(
//                   padding: pw.EdgeInsets.all(15),
//                   decoration: pw.BoxDecoration(
//                     border: pw.Border.all(color: PdfColors.grey300),
//                     borderRadius: pw.BorderRadius.circular(8),
//                   ),
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text(
//                         'ALASAN BERGABUNG',
//                         style: pw.TextStyle(
//                           font: ttfBold,
//                           fontSize: 16,
//                           color: PdfColors.blue,
//                         ),
//                       ),
//                       pw.SizedBox(height: 15),
//                       pw.Text(
//                         status.alasan!,
//                         style: pw.TextStyle(
//                           font: ttf,
//                           fontSize: 12,
//                           lineSpacing: 1.5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],

//               pw.Spacer(),

//               // Footer
//               pw.Container(
//                 width: double.infinity,
//                 padding: pw.EdgeInsets.symmetric(vertical: 15),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border(
//                     top: pw.BorderSide(color: PdfColors.grey300, width: 1),
//                   ),
//                 ),
//                 child: pw.Column(
//                   children: [
//                     pw.Text(
//                       'Dokumen ini dibuat secara otomatis oleh sistem',
//                       style: pw.TextStyle(
//                         font: ttf,
//                         fontSize: 10,
//                         color: PdfColors.grey,
//                       ),
//                     ),
//                     pw.SizedBox(height: 5),
//                     pw.Text(
//                       'Tanggal Cetak: ${DateTime.now().toString().substring(0, 19)}',
//                       style: pw.TextStyle(
//                         font: ttf,
//                         fontSize: 10,
//                         color: PdfColors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     // Save PDF
//     final String fileName = 'Pendaftaran_${status.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    
//     if (Platform.isAndroid) {
//       final directory = await getExternalStorageDirectory();
//       final file = File('${directory!.path}/$fileName');
//       await file.writeAsBytes(await pdf.save());
      
//       // Share file
//       await Share.shareXFiles([XFile(file.path)], text: 'Surat Keterangan Pendaftaran UKM');
//     } else if (Platform.isIOS) {
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/$fileName');
//       await file.writeAsBytes(await pdf.save());
      
//       // Share file
//       await Share.shareXFiles([XFile(file.path)], text: 'Surat Keterangan Pendaftaran UKM');
//     }
//   }

//   static pw.Widget _buildInfoRow(String label, String value, pw.Font regularFont, pw.Font boldFont) {
//     return pw.Padding(
//       padding: pw.EdgeInsets.only(bottom: 8),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Container(
//             width: 120,
//             child: pw.Text(
//               '$label:',
//               style: pw.TextStyle(
//                 font: boldFont,
//                 fontSize: 12,
//                 color: PdfColors.grey700,
//               ),
//             ),
//           ),
//           pw.Expanded(
//             child: pw.Text(
//               value,
//               style: pw.TextStyle(
//                 font: regularFont,
//                 fontSize: 12,
//                 color: PdfColors.black,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }