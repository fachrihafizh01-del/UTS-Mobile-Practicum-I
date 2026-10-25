# Mengonversi docs/build/laporan.html menjadi .docx dan .pdf memakai Microsoft Word.
# Jalankan setelah: dart run tool/build_report.dart
#
# Catatan: berkas sementara dibuat di folder temp karena Word dapat menggantung
# saat menyimpan langsung ke folder yang tersinkronisasi OneDrive. Hasil akhir
# disalin ke docs/ setelah konversi selesai.
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$html = Join-Path $root 'docs\build\laporan.html'
$outDocx = Join-Path $root 'docs\Laporan_UTS_Tapak.docx'
$outPdf  = Join-Path $root 'docs\Laporan_UTS_Tapak.pdf'

if (-not (Test-Path $html)) {
  throw "HTML belum dibuat. Jalankan: dart run tool/build_report.dart"
}

$tmpDir = Join-Path $env:TEMP 'opencode'
New-Item -ItemType Directory -Force $tmpDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$rawDocx = Join-Path $tmpDir "laporan_raw_$stamp.docx"
$finalDocx = Join-Path $tmpDir "laporan_final_$stamp.docx"
$tmpPdf = Join-Path $tmpDir "laporan_$stamp.pdf"
$logPath = Join-Path $tmpDir 'build.log'

Remove-Item $logPath -ErrorAction SilentlyContinue
function Write-Log([string]$message) {
  Add-Content -Path $logPath -Value "$(Get-Date -Format HH:mm:ss) $message"
}

$word = $null
try {
  Write-Log 'Mulai: membuka Word'
  $word = New-Object -ComObject Word.Application
  $word.Visible = $false
  $word.DisplayAlerts = 0
  Start-Sleep -Milliseconds 500

  # 1) HTML -> DOCX
  Write-Log 'Membuka HTML'
  $doc = $word.Documents.Open($html, $false, $false)
  Write-Log 'Menyimpan DOCX awal'
  $doc.SaveAs2($rawDocx, 16)   # wdFormatXMLDocument
  $doc.Close(0)
  Write-Log "DOCX awal: $((Get-Item $rawDocx).Length) byte"

  # 2) Sematkan gambar (Word mengimpor gambar HTML sebagai tautan),
  #    lalu atur ukuran A4 dan margin 2,54 cm.
  Write-Log 'Membuka DOCX awal'
  $doc = $word.Documents.Open($rawDocx, $false, $false)
  for ($i = 1; $i -le $doc.InlineShapes.Count; $i++) {
    $shape = $doc.InlineShapes.Item($i)
    if ($null -ne $shape.LinkFormat) {
      $shape.LinkFormat.SavePictureWithDocument = $true
    }
  }
  Write-Log 'Gambar disematkan'

  $pageSetup = $doc.Sections.Item(1).PageSetup
  $pageSetup.PaperSize = 7      # wdPaperA4
  $pageSetup.TopMargin = 72     # 2,54 cm
  $pageSetup.BottomMargin = 72
  $pageSetup.LeftMargin = 72
  $pageSetup.RightMargin = 72
  Write-Log "Ukuran halaman: $($pageSetup.PageWidth) x $($pageSetup.PageHeight) pt"

  $doc.SaveAs2($finalDocx, 16)
  Write-Log 'DOCX final disimpan'
  $doc.ExportAsFixedFormat($tmpPdf, 17)  # wdExportFormatPDF
  Write-Log 'PDF diekspor'

  $pages = $doc.ComputeStatistics(2)     # wdStatisticPages
  $words = $doc.ComputeStatistics(0)     # wdStatisticWords
  $doc.Close(0)
  Write-Log "Selesai: $pages halaman, $words kata"
}
finally {
  if ($null -ne $word) {
    $word.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
  }
}

Copy-Item -Path $finalDocx -Destination $outDocx -Force
Copy-Item -Path $tmpPdf -Destination $outPdf -Force

Write-Output "DOCX    : $outDocx"
Write-Output "PDF     : $outPdf"
Write-Output "Halaman : $pages"
Write-Output "Kata    : $words"
