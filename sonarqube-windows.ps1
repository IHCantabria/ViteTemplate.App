# TODO: NO QUIERO VER ESTE FICHERO EN LOS REPO DE PROYECTOS. RENOMBRADLO A sonar.ps1 AL BAJAROS LA PLANTILLA

# This script sets up and runs SonarQube Scanner on a Windows machine.

# Replace "SONAR_TOKEN_KEY" with your user sonar key
# Replace "PROJECT_KEY" with your actual project key

# Set SonarQube Scanner version
$env:SONAR_SCANNER_VERSION = "5.0.1.3006"

# Set directory for SonarQube Scanner
$env:SONAR_DIRECTORY = [System.IO.Path]::Combine($(Get-Location).Path, ".sonar")

# Set SonarQube Scanner home path
$env:SONAR_SCANNER_HOME = "$env:SONAR_DIRECTORY/sonar-scanner-$env:SONAR_SCANNER_VERSION-windows"

# Check if the directory already exists
if (-not (Test-Path $env:SONAR_SCANNER_HOME)) {
    # Create new directory for scanner
    New-Item -Path $env:SONAR_SCANNER_HOME -ItemType Directory

    # Download SonarQube Scanner zip file
    $webClient = New-Object System.Net.WebClient
    $scannerZipPath = "$env:SONAR_DIRECTORY/sonar-scanner.zip"
    $webClient.DownloadFile("https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$env:SONAR_SCANNER_VERSION-windows.zip", $scannerZipPath)

    # Add type for compression file system
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    # Unzip the scanner
    [System.IO.Compression.ZipFile]::ExtractToDirectory($scannerZipPath, $env:SONAR_DIRECTORY)

    # Remove the downloaded zip file
    Remove-Item $scannerZipPath -Force -ErrorAction SilentlyContinue

    Write-Host "SonarQube Scanner setup completed."
} else {
    Write-Host "Directory already exists: $env:SONAR_SCANNER_HOME"
}

# Add SonarQube Scanner to the system PATH
$env:Path += ";$env:SONAR_SCANNER_HOME/bin"

# Set SonarQube Scanner options
$env:SONAR_SCANNER_OPTS = "-server"

# Function to run SonarQube Scanner
function Run-SonarQubeScanner {
    param (
        [string]$projectKey,
        [string]$projectDir,
        [string]$sonarHostUrl
    )

    # Verify the project directory exists
    if (-not (Test-Path $projectDir)) {
        Write-Host "Project directory does not exist: $projectDir"
        return
    }

    # Navigate to the project folder
    Set-Location -Path $projectDir

    # Run SonarQube Scanner
    Start-Process -FilePath "sonar-scanner.bat" -ArgumentList @(
        "-Dsonar.projectKey=$projectKey",
        "-Dsonar.sources=.",
        "-Dsonar.host.url=$sonarHostUrl"
    ) -NoNewWindow -Wait

    # Check for successful execution
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Scanner Successful"
    } else {
        Write-Host "Scanner encountered an error"
    }

    # Clean up .scannerwork and .sonar directories
    if (Test-Path ".scannerwork") {
        Remove-Item ".scannerwork" -Force -Recurse -ErrorAction SilentlyContinue
    }

    if (Test-Path ".sonar") {
        Remove-Item ".sonar" -Force -Recurse -ErrorAction SilentlyContinue
    }
}

# Configure a SONAR_TOKEN environment variable
$env:SONAR_TOKEN = "SONAR_TOKEN_KEY"
#Example $env:SONAR_TOKEN = "sqp_52d82142d471229e4d8df0a0435a87e26de5f447

# Example usage: Run SonarQube Scanner for your project
Run-SonarQubeScanner -projectKey "PROJECT_KEY" -projectDir "." -sonarHostUrl "http://ihsonarqube.ihcantabria.com:9000"
#Example Run-SonarQubeScanner -projectKey "DEMO-PYTHON" -projectDir "." -sonarHostUrl "http://ihsonarqube.ihcantabria.com:9000"

# Indicate that the exception after successful scan is non-critical
Write-Host "Ignoring non-critical exception encountered after successful scan."

# Keep console open
Write-Host "Press any key to exit..."
[void][System.Console]::ReadKey($true)