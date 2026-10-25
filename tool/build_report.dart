// Membangun docs/build/laporan.html dari docs/LAPORAN_UTS.md.
// HTML ini kemudian dikonversi ke .docx/.pdf oleh Word (lihat tool/build_docx.ps1).
//
// Jalankan: dart run tool/build_report.dart
import 'dart:convert';
import 'dart:io';

import 'package:markdown/markdown.dart' as md;

void main() {
  final root = Directory.current.path;
  final source = File('$root/docs/LAPORAN_UTS.md');
  if (!source.existsSync()) {
    stderr.writeln('Berkas ${source.path} tidak ditemukan.');
    exit(1);
  }

  var markdown = source.readAsStringSync();

  // Logo fakultas: kotak placeholder agar terlihat saat dicetak.
  markdown = markdown.replaceAll(
    '[SISIPKAN LOGO FAKULTAS]',
    '\n\n<div class="logo">LOGO<br>FAKULTAS</div>\n\n',
  );

  // Ganti penanda tertentu dengan gambar yang sudah tersedia.
  const images = <String, String>{
    'Palet warna dan contoh penerapannya pada komponen': 'palet.png',
    'Diagram alur navigasi': 'alur-navigasi.png',
    'Halaman Beranda': 'beranda.png',
    'Halaman Daftar per Kategori': 'daftar.png',
    'Halaman Detail Gerakan': 'detail.png',
  };

  images.forEach((label, file) {
    final marker = '[SISIPKAN GAMBAR/SCREENSHOT: $label]';
    final isDiagram = file == 'palet.png' || file == 'alur-navigasi.png';
    final cssClass = isDiagram ? 'diagram' : 'shot';
    markdown = markdown.replaceAll(
      marker,
      '\n\n<p class="figure"><img class="$cssClass" src="../screenshots/$file" alt="$label"></p>\n\n',
    );
  });

  var html = md.markdownToHtml(
    markdown,
    extensionSet: md.ExtensionSet.gitHubWeb,
    encodeHtml: false,
  );

  // Page break: <div style="page-break-after:always"></div> dari Markdown
  // diubah menjadi paragraf ber-page-break-before agar dihormati Word.
  html = html.replaceAll(
    '<div style="page-break-after: always;"></div>',
    '<p class="pb">&nbsp;</p>',
  );
  html = html.replaceAll(
    '<div style="page-break-after: always;"></div>\n',
    '<p class="pb">&nbsp;</p>',
  );

  // Bungkus halaman judul (sebelum <hr /> pertama) dengan class cover.
  final firstHr = html.indexOf('<hr />');
  if (firstHr != -1) {
    final cover = html.substring(0, firstHr);
    final rest = html.substring(firstHr + '<hr />'.length);
    html = '<div class="cover">$cover</div>$rest';
  }

  // Sisa penanda diberi sorotan kuning agar terlihat saat dicetak.
  html = html.replaceAllMapped(
    RegExp(r'\[SISIPKAN[^\]]*\]'),
    (match) => '<span class="ph">${match[0]}</span>',
  );

  // Caption gambar dan tabel dibuat rata tengah.
  html = html.replaceAllMapped(
    RegExp(r'<p><strong>(Gambar [^<]+)</strong>([^<]*)</p>'),
    (match) => '<p class="caption"><strong>${match[1]}</strong>${match[2]}</p>',
  );
  html = html.replaceAllMapped(
    RegExp(r'<p><strong>(Tabel [^<]+)</strong>([^<]*)</p>'),
    (match) => '<p class="caption"><strong>${match[1]}</strong>${match[2]}</p>',
  );

  final document = '''
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="utf-8">
<title>Laporan UTS Mobile Programming - Tapak</title>
<style>
  @page { size: A4; margin: 2.54cm; }
  body {
    font-family: "Times New Roman", serif;
    font-size: 12pt;
    line-height: 1.5;
    color: #000000;
    margin: 0;
  }
  h1 {
    font-family: "Arial", sans-serif;
    font-size: 16pt;
    font-weight: bold;
    text-align: center;
    text-transform: uppercase;
    margin: 0 0 6pt 0;
    page-break-after: avoid;
  }
  h2 {
    font-family: "Arial", sans-serif;
    font-size: 13pt;
    font-weight: bold;
    margin: 18pt 0 8pt 0;
    page-break-after: avoid;
  }
  h3 {
    font-family: "Arial", sans-serif;
    font-size: 12pt;
    font-weight: bold;
    margin: 14pt 0 6pt 0;
    page-break-after: avoid;
  }
  p { margin: 0 0 8pt 0; text-align: justify; }
  ul, ol { margin: 0 0 10pt 0; padding-left: 24pt; }
  li { margin-bottom: 4pt; text-align: justify; }
  table {
    border-collapse: collapse;
    width: 100%;
    margin: 6pt 0 12pt 0;
    font-size: 9.5pt;
    page-break-inside: avoid;
  }
  th, td {
    border: 1px solid #000000;
    padding: 4pt 6pt;
    vertical-align: top;
    text-align: left;
  }
  th { background-color: #E9E9E9; font-weight: bold; }
  code {
    font-family: "Consolas", monospace;
    font-size: 9.5pt;
    background-color: #F4F4F4;
    padding: 1pt 2pt;
  }
  pre {
    font-family: "Consolas", monospace;
    font-size: 8pt;
    line-height: 1.2;
    background-color: #F7F7F7;
    border: 1px solid #D8D8D8;
    padding: 6pt 8pt;
    margin: 6pt 0 12pt 0;
    white-space: pre-wrap;
  }
  pre code { background: none; padding: 0; font-size: 8pt; }
  hr { display: none; }
  .pb { page-break-before: always; margin: 0; font-size: 1pt; line-height: 1pt; }
  .cover { text-align: center; }
  .cover h1 { font-size: 18pt; margin-bottom: 8pt; }
  .cover h2 { font-size: 14pt; margin: 0 0 24pt 0; }
  .cover p { text-align: center; margin: 4pt 0; }
  .cover strong { font-size: 12pt; }
  .logo {
    width: 3.6cm;
    height: 3.6cm;
    margin: 18pt auto;
    border: 1px dashed #888888;
    color: #777777;
    font-family: "Arial", sans-serif;
    font-size: 9pt;
    line-height: 1.4;
    padding-top: 1.35cm;
    box-sizing: border-box;
    text-align: center;
  }
  .figure { text-align: center; margin: 10pt 0 4pt 0; page-break-inside: avoid; }
  .figure img { display: block; margin: 0 auto; }
  img.shot { width: 6.5cm; height: auto; }
  img.diagram { width: 15.2cm; height: auto; }
  .caption {
    text-align: center;
    font-size: 10pt;
    margin: 2pt 0 12pt 0;
    page-break-after: avoid;
  }
  .caption strong { font-weight: bold; }
  .ph {
    background-color: #FFF2A8;
    font-weight: bold;
  }
</style>
</head>
<body>
$html
</body>
</html>
''';

  final outDir = Directory('$root/docs/build');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);
  final outFile = File('${outDir.path}/laporan.html');
  outFile.writeAsBytesSync(<int>[
    0xEF, 0xBB, 0xBF, // BOM agar Word membaca UTF-8 dengan benar
    ...utf8.encode(document),
  ]);

  stdout.writeln('HTML dibuat: ${outFile.path}');
}
