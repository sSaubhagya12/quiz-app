import 'pdf_download_stub.dart'
    if (dart.library.html) 'pdf_download_web.dart';

void downloadPdfFile(List<int> bytes, String filename) {
  downloadPdf(bytes, filename);
}
