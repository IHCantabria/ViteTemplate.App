# TODO: NO QUIERO VER ESTE FICHERO EN LOS REPO DE PROYECTOS. RENOMBRADLO A trivy.ps1 AL BAJAROS LA PLANTILLA

param(
    [string]$TrivyVersion = "0.64.1",
    [string]$ReportsFolder = "trivy-reports",
    [string]$ScanTarget = "."
)

# Configuration
$TempDownloadDir = "trivy-temp-download"
$TrivyZip = Join-Path $TempDownloadDir "trivy.zip"
$TrivyFolder = ".trivy-bin"
$TrivyExe = Join-Path $TrivyFolder "trivy.exe"
$HtmlTemplate = Join-Path $TrivyFolder "html.tpl"
$JsonReport = Join-Path $ReportsFolder "trivy-report.json"
$HtmlReport = Join-Path $ReportsFolder "trivy-report.html"

# Utility: Clean partial files
function Cleanup-PartialFiles {
    Write-Output "Cleaning up partial files..."
    if (Test-Path $TrivyZip) { Remove-Item $TrivyZip -Force -ErrorAction SilentlyContinue }
    if (Test-Path $TempDownloadDir) { Remove-Item $TempDownloadDir -Recurse -Force -ErrorAction SilentlyContinue }
    if (Test-Path $TrivyFolder) { Remove-Item $TrivyFolder -Recurse -Force -ErrorAction SilentlyContinue }
}

# Utility: Download Trivy binary
function Download-Trivy {
    if (Test-Path $TrivyFolder) {
        Write-Output "Trivy binary already exists. Reusing."
        return
    }

    try {
        Write-Output "Downloading Trivy v$TrivyVersion..."
        New-Item -ItemType Directory -Force -Path $TempDownloadDir | Out-Null

        $TrivyUrl = "https://github.com/aquasecurity/trivy/releases/download/v$TrivyVersion/trivy_${TrivyVersion}_windows-64bit.zip"
        Invoke-WebRequest -Uri $TrivyUrl -OutFile $TrivyZip

        Write-Output "Extracting Trivy..."
        Expand-Archive -Path $TrivyZip -DestinationPath $TrivyFolder -Force

        Remove-Item $TrivyZip -Force -ErrorAction SilentlyContinue
        Remove-Item $TempDownloadDir -Recurse -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Error "Error during Trivy download or extraction: $_"
        Cleanup-PartialFiles
        exit 1
    }
}

# Utility: Download HTML report template
function Download-TrivyTemplate {
    if (-not (Test-Path $HtmlTemplate)) {
        Write-Output "Downloading html.tpl template..."
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl" -OutFile $HtmlTemplate
    }
}

# Utility: Run Trivy scan
function Run-TrivyScan {
    if (-not (Test-Path $ReportsFolder)) {
        Write-Output "Creating reports directory..."
        New-Item -ItemType Directory -Path $ReportsFolder | Out-Null
    }

    Write-Output "Running Trivy scan (JSON report)..."
    & $TrivyExe fs --scanners vuln,secret,misconfig,license --license-full --ignore-unfixed --format json -o $JsonReport $ScanTarget

    if (-not (Test-Path $JsonReport)) {
        Write-Error "Failed to generate JSON report."
        exit 1
    }

    Write-Output "Generating HTML report..."
    & $TrivyExe fs --scanners vuln,secret,misconfig --ignore-unfixed --format template --template "@$HtmlTemplate" --output $HtmlReport $ScanTarget

    if (-not (Test-Path $HtmlReport)) {
        Write-Warning "Warning: Failed to generate HTML report."
    }
}

# Utility: Check vulnerabilities
function Check-Vulnerabilities {
    $reportContent = Get-Content -Raw -Path $JsonReport | ConvertFrom-Json

    foreach ($result in $reportContent.Results) {
        if ($result.Vulnerabilities -and $result.Vulnerabilities.Count -gt 0) {
            Write-Host "Vulnerabilities detected. Check $JsonReport or $HtmlReport for details." -ForegroundColor Red
            exit 1
        }
    }

    Write-Output "Scan completed with no vulnerabilities found."
}

# Execution flow
Download-Trivy
Download-TrivyTemplate
Run-TrivyScan
Check-Vulnerabilities

exit 0