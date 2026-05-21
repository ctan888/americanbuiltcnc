$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$indexPath = Join-Path $repoRoot "index.html"
$thanksPath = Join-Path $repoRoot "thankyou.html"

if (-not (Test-Path -LiteralPath $indexPath)) {
    throw "Missing index.html at $indexPath"
}
if (-not (Test-Path -LiteralPath $thanksPath)) {
    throw "Missing thankyou.html at $thanksPath"
}

$tmpIndex = Join-Path $env:TEMP "americanbuiltcnc-index.html"
$tmpThanks = Join-Path $env:TEMP "americanbuiltcnc-thankyou.html"
Copy-Item -LiteralPath $indexPath -Destination $tmpIndex -Force
Copy-Item -LiteralPath $thanksPath -Destination $tmpThanks -Force

$tmpIndexForWsl = $tmpIndex -replace "\\", "/"
$tmpThanksForWsl = $tmpThanks -replace "\\", "/"
$tmpIndexWsl = (& wsl wslpath -a $tmpIndexForWsl).Trim()
$tmpThanksWsl = (& wsl wslpath -a $tmpThanksForWsl).Trim()
$key = "/home/ctan/.ssh/dareeat-key.pem"
$hostName = "ubuntu@107.23.75.91"

& wsl -- scp -i $key -o StrictHostKeyChecking=accept-new $tmpIndexWsl "${hostName}:/tmp/index.html"
& wsl -- scp -i $key -o StrictHostKeyChecking=accept-new $tmpThanksWsl "${hostName}:/tmp/thankyou.html"
& wsl -- ssh -i $key $hostName "sudo mkdir -p /var/www/americanbuiltcnc && sudo cp /tmp/index.html /var/www/americanbuiltcnc/index.html && sudo cp /tmp/thankyou.html /var/www/americanbuiltcnc/thankyou.html"

$homeResp = Invoke-WebRequest -Uri "https://americanbuiltcnc.com/" -UseBasicParsing -TimeoutSec 20
$thanksResp = Invoke-WebRequest -Uri "https://americanbuiltcnc.com/thankyou.html" -UseBasicParsing -TimeoutSec 20

if (-not $homeResp.Content.Contains("Enclosed fiber lasers for small shops")) {
    throw "Deploy verification failed: homepage marker not found."
}
if (-not $thanksResp.Content.Contains("Thanks. We got your request.")) {
    throw "Deploy verification failed: thank-you marker not found."
}

Write-Host "Deployed americanbuiltcnc.com"
