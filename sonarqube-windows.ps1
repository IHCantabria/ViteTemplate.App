# TODO: NO QUIERO VER ESTE FICHERO EN LOS REPO DE PROYECTOS. RENOMBRADLO A sonar.ps1 AL BAJAROS LA PLANTILLA

# This script sets up and runs SonarQube Scanner on a Windows machine.

# Replace "SONAR_TOKEN_KEY" with your user sonar key
# Replace "PROJECT_KEY" with your actual project key

param(
    [string]$SonarScannerVersion = "7.2.0.5079",
    [string]$ProjectKey = "PROJECT_KEY",
    [string]$SonarHostUrl = "http://ihsonarqube.ihcantabria.com:9000",
    [string]$SonarToken = "SONAR_TOKEN_KEY",
    [string]$ProjectDir = ".",
    [string]$ReportsFolder = "sonar-reports",
    [switch]$SkipConnectivityTest = $false
)

# Configuration
$WorkspaceRoot = $(Get-Location).Path
$TempDownloadDir = Join-Path $WorkspaceRoot "sonar-temp-download"
$SonarDirectory = Join-Path $WorkspaceRoot ".sonar"
$SonarScannerHome = Join-Path $SonarDirectory "sonar-scanner-$SonarScannerVersion-windows-x64"
$ScannerZip = Join-Path $TempDownloadDir "sonar-scanner.zip"
$ScannerWorkDir = Join-Path $WorkspaceRoot ".scannerwork"
$ScannerExecutable = Join-Path $SonarScannerHome "bin\sonar-scanner.bat"

# Utility: Clean partial files and working directories
function Cleanup-PartialFiles {
    param([bool]$IncludeScanner = $false)
    
    Write-Output "Cleaning up partial files..."
    
    $pathsToClean = @($ScannerZip, $TempDownloadDir, $ScannerWorkDir)
    if ($IncludeScanner) { $pathsToClean += $SonarDirectory }
    
    foreach ($path in $pathsToClean) {
        if (Test-Path $path) {
            Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Output "Removed: $path"
        }
    }
}

# Utility: Download SonarQube Scanner
function Download-SonarScanner {
    if (Test-Path $ScannerExecutable) {
        Write-Output "SonarQube Scanner already exists and is functional. Reusing."
        return
    }

    try {
        Write-Output "Downloading SonarQube Scanner v$SonarScannerVersion..."
        
        # Create directories
        New-Item -ItemType Directory -Force -Path $TempDownloadDir | Out-Null
        New-Item -ItemType Directory -Force -Path $SonarDirectory | Out-Null

        $ScannerUrl = "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SonarScannerVersion-windows-x64.zip"
        
        Write-Output "Downloading from: $ScannerUrl"
        Invoke-WebRequest -Uri $ScannerUrl -OutFile $ScannerZip -UseBasicParsing
        
        # Verify download
        if (-not (Test-Path $ScannerZip) -or (Get-Item $ScannerZip).Length -eq 0) {
            throw "Failed to download SonarQube Scanner or file is empty"
        }

        Write-Output "Extracting SonarQube Scanner..."
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($ScannerZip, $SonarDirectory)
        
        # Verify extraction
        if (-not (Test-Path $ScannerExecutable)) {
            throw "SonarQube Scanner executable not found after extraction"
        }

        # Cleanup download files
        Remove-Item $ScannerZip -Force -ErrorAction SilentlyContinue
        Remove-Item $TempDownloadDir -Recurse -Force -ErrorAction SilentlyContinue

        Write-Output "SonarQube Scanner setup completed successfully."
    } catch {
        Write-Error "Error during SonarQube Scanner download or extraction: $_"
        Cleanup-PartialFiles -IncludeScanner $true
        exit 1
    }
}

# Utility: Validate configuration
function Validate-Configuration {
    Write-Output "Validating configuration..."
    $hasErrors = $false
    
    # Validate SonarQube token
    if ([string]::IsNullOrWhiteSpace($SonarToken) -or $SonarToken -eq "SONAR_TOKEN_KEY") {
        Write-Error "Invalid SONAR_TOKEN. Please provide a valid SonarQube authentication token."
        $hasErrors = $true
    }
    
    # Validate project key
    if ([string]::IsNullOrWhiteSpace($ProjectKey) -or $ProjectKey -eq "PROJECT_KEY") {
        Write-Error "Invalid PROJECT_KEY. Please provide a valid SonarQube project key."
        $hasErrors = $true
    }
    
    # Validate SonarQube host URL
    if ([string]::IsNullOrWhiteSpace($SonarHostUrl)) {
        Write-Error "Invalid SONAR_HOST_URL. Please provide a valid SonarQube server URL."
        $hasErrors = $true
    }
    
    # Validate project directory
    if (-not (Test-Path $ProjectDir)) {
        Write-Error "Project directory does not exist: $ProjectDir"
        $hasErrors = $true
    }
    
    # Validate SonarQube Scanner version format
    if (-not ($SonarScannerVersion -match '^\d+\.\d+\.\d+\.\d+$')) {
        Write-Warning "SonarQube Scanner version format may be incorrect: $SonarScannerVersion"
    }
    
    if ($hasErrors) {
        Write-Error "Configuration validation failed. Please fix the errors above."
        exit 1
    }
    
    Write-Output "Configuration validation passed successfully."
}

# Utility: Test SonarQube server connectivity
function Test-SonarQubeConnectivity {
    if ($SkipConnectivityTest) {
        Write-Output "Connectivity test skipped by user request."
        return
    }
    
    Write-Output "Testing SonarQube server connectivity..."
    
    try {
        $response = Invoke-WebRequest -Uri "$SonarHostUrl/api/system/status" -Method GET -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Output "SonarQube server is accessible."
            return $true
        } else {
            Write-Warning "SonarQube server responded with status: $($response.StatusCode)"
            return $false
        }
    } catch {
        Write-Warning "Could not connect to SonarQube server: $_"
        Write-Output "Proceeding with scan (server may still be accessible during scan)..."
        return $false
    }
}

# Utility: Create reports directory
function Create-ReportsDirectory {
    if (-not (Test-Path $ReportsFolder)) {
        Write-Output "Creating reports directory: $ReportsFolder"
        New-Item -ItemType Directory -Path $ReportsFolder | Out-Null
    }
}

# Utility: Configure SonarQube environment
function Configure-SonarEnvironment {
    Write-Output "Configuring SonarQube environment..."
    
    # Set environment variables
    $env:SONAR_SCANNER_HOME = $SonarScannerHome
    $env:SONAR_SCANNER_OPTS = "-server"
    $env:SONAR_TOKEN = $SonarToken
    
    # Add to PATH if not already present
    $binPath = Join-Path $SonarScannerHome "bin"
    if ($env:Path -notlike "*$binPath*") {
        $env:Path += ";$binPath"
        Write-Output "Added SonarQube Scanner to PATH: $binPath"
    } else {
        Write-Output "SonarQube Scanner already in PATH"
    }
}

# Utility: Run SonarQube scan
function Run-SonarScan {
    Write-Output "Verifying project directory..."
    $absoluteProjectDir = Resolve-Path $ProjectDir -ErrorAction SilentlyContinue
    if (-not $absoluteProjectDir -or -not (Test-Path $absoluteProjectDir)) {
        Write-Error "Project directory does not exist: $ProjectDir"
        exit 1
    }

    Write-Output "Project directory: $absoluteProjectDir"
    Write-Output "Starting SonarQube scan..."
    
    # Set working directory
    $originalLocation = Get-Location
    Set-Location -Path $absoluteProjectDir

    # Build scan arguments
    $arguments = @(
        "-Dsonar.projectKey=$ProjectKey",
        "-Dsonar.sources=.",
        "-Dsonar.host.url=$SonarHostUrl",
        "-Dsonar.working.directory=$ScannerWorkDir"
    )

    # Add optional report output if reports folder exists
    if (Test-Path $ReportsFolder) {
        $reportPath = Join-Path $ReportsFolder "sonar-report.xml"
        $arguments += "-Dsonar.analysis.mode=issues"
        $arguments += "-Dsonar.report.export.path=$reportPath"
    }

    try {
        Write-Output "Executing: $ScannerExecutable"
        Write-Output "Arguments: $($arguments -join ' ')"
        
        $process = Start-Process -FilePath $ScannerExecutable -ArgumentList $arguments -NoNewWindow -Wait -PassThru

        if ($process.ExitCode -eq 0) {
            Write-Output "SonarQube scan completed successfully."
        } else {
            Write-Error "SonarQube scan failed with exit code: $($process.ExitCode)"
            exit 1
        }
    } catch {
        Write-Error "Error during SonarQube scan execution: $_"
        exit 1
    } finally {
        # Restore original location
        Set-Location -Path $originalLocation
        
        # Clean up scanner work directory
        if (Test-Path $ScannerWorkDir) {
            Write-Output "Cleaning up scanner work directory..."
            Remove-Item $ScannerWorkDir -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
}



# Execution flow
try {
    Write-Output "=== SonarQube Scanner Automation Script ==="
    Write-Output "Scanner Version: $SonarScannerVersion"
    Write-Output "Project Key: $ProjectKey"
    Write-Output "Host URL: $SonarHostUrl"
    Write-Output "Project Directory: $ProjectDir"
    Write-Output "Reports Folder: $ReportsFolder"
    Write-Output "Skip Connectivity Test: $SkipConnectivityTest"
    Write-Output "================================================"
    
    Validate-Configuration
    Test-SonarQubeConnectivity
    Create-ReportsDirectory
    Download-SonarScanner
    Configure-SonarEnvironment
    Run-SonarScan
    
    Write-Output "=== SonarQube analysis completed successfully! ==="
} catch {
    Write-Error "Script execution failed: $_"
    Cleanup-PartialFiles
    exit 1
}

exit 0