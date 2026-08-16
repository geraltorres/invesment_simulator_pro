import 'dart:convert';
import 'dart:js_interop';
import 'package:pdf/widgets.dart' as pw;
import 'package:web/web.dart' as web;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // Solo para Web

Future<void> downloadPdfWeb(pw.Document pdf, String fileName) async {
  final bytes = await pdf.save();
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "$fileName.pdf")
    ..click();
  html.Url.revokeObjectUrl(url);
}

void downloadFileWeb(String content, String fileName, String mimeType) {
  final bytes = utf8.encode(content);
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);

  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = fileName;
  anchor.click();

  web.URL.revokeObjectURL(url);
}
