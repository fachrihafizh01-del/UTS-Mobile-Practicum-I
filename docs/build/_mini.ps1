$ErrorActionPreference = 'Stop'
$log = 'docs\build\_mini.log'
function L($m) { Add-Content $log $m }
L "start"
$word = New-Object -ComObject Word.Application
$word.Visible = $false; $word.DisplayAlerts = 0
L "app"
$doc = $word.Documents.Open((Resolve-Path 'docs\build\_mini.html').Path, $false, $false)
L "opened"
$doc.SaveAs2((Join-Path (Get-Location) 'docs\build\_mini.docx'), 16)
L "saved"
$doc.Close(0)
$word.Quit()
L "done"
