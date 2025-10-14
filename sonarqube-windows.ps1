# TODO: NO QUIERO VER ESTE FICHERO EN LOS REPO DE PROYECTOS. RENOMBRADLO A sonar.ps1 AL BAJAROS LA PLANTILLA

# This script automates the download, configuration, and execution of SonarQube Scanner on Windows.
# It also includes validation of configuration parameters, connectivity tests to the SonarQube server,
# and checks the Quality Gate status after the scan.

#usage:
#   .\sonarqube-windows.ps1 -SonarScannerVersion "7.2.0.5079" -ProjectKey "my_project_key" -SonarHostUrl "http://mysonarqube.server:9000" -SonarToken "my_sonar_token" -ProjectDir "path\to\my\project" -SkipConnectivityTest -SkipQualityGateCheck
#
# Parameters:
#   -SonarScannerVersion  : SonarQube Scanner version (default: "7.2.0.5079")
#   -ProjectKey           : SonarQube project key (default: "PROJECT_KEY")
#   -SonarHostUrl         : SonarQube server URL (default: "http://ihsonarqube.ihcantabria.com:9000")
#   -SonarToken           : SonarQube authentication token (default: "SONAR_TOKEN_KEY")
#   -ProjectDir           : Project directory to scan (default: ".")
#   -SkipConnectivityTest : Skip server connectivity test (switch)
#   -SkipQualityGateCheck : Skip Quality Gate verification (switch)

param(
    [string]$SonarScannerVersion = "7.2.0.5079",
    [string]$ProjectKey = "PROJECT_KEY",
    [string]$SonarHostUrl = "https://ihsonarqube.ihcantabria.com",
    [string]$SonarToken = "SONAR_TOKEN_KEY",
    [string]$ProjectDir = ".",
    [switch]$SkipConnectivityTest = $false,
    [switch]$SkipQualityGateCheck = $false
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

# Utility: Validate SonarQube token and permissions
function Test-SonarQubeAuthentication {
    Write-Output "Validating SonarQube authentication..."
    
    try {
        $headers = @{
            "Authorization" = "Bearer $SonarToken"
        }
        
        # Test authentication with a simple API call
        $authTestUrl = "$SonarHostUrl/api/authentication/validate"
        $response = Invoke-WebRequest -Uri $authTestUrl -Headers $headers -Method GET -UseBasicParsing -TimeoutSec 10
        
        if ($response.StatusCode -eq 200) {
            $authData = $response.Content | ConvertFrom-Json
            if ($authData.valid -eq $true) {
                Write-Output "Token authentication successful."
                return $true
            } else {
                Write-Error "Token is not valid."
                return $false
            }
        } else {
            Write-Warning "Authentication test returned status: $($response.StatusCode)"
            return $false
        }
    } catch {
        if ($_.Exception.Message -match "403") {
            Write-Error "Authentication failed (403 Forbidden). Please check your SonarQube token."
            Write-Output "Token troubleshooting:"
            Write-Output "1. Verify the token is correct and not expired"
            Write-Output "2. Ensure the token has 'Execute Analysis' permissions"
            Write-Output "3. Check if the project key '$ProjectKey' exists and you have access to it"
            Write-Output "4. Verify the SonarQube server URL: $SonarHostUrl"
        } elseif ($_.Exception.Message -match "401") {
            Write-Error "Authentication failed (401 Unauthorized). Token may be invalid or expired."
        } else {
            Write-Warning "Could not validate authentication: $_"
        }
        return $false
    }
}

# Utility: Check Quality Gate status
function Check-QualityGate {
    if ($SkipQualityGateCheck) {
        Write-Output "Quality Gate check skipped by user request."
        return
    }
    
    Write-Output "Checking Quality Gate status..."
    
    # First validate authentication
    if (-not (Test-SonarQubeAuthentication)) {
        Write-Error "Cannot proceed with Quality Gate check due to authentication issues."
        exit 1
    }
    
    try {
        $maxAttempts = 5
        $attempt = 0
        $qualityGateChecked = $false
        
        $headers = @{
            "Authorization" = "Bearer $SonarToken"
        }
        
        while ($attempt -lt $maxAttempts -and -not $qualityGateChecked) {
            $attempt++
            Write-Output "Attempt $attempt/$maxAttempts - Checking Quality Gate status..."
            
            try {
                # Get project status from SonarQube API
                $qualityGateUrl = "$SonarHostUrl/api/qualitygates/project_status?projectKey=$ProjectKey"
                $response = Invoke-WebRequest -Uri $qualityGateUrl -Headers $headers -Method GET -UseBasicParsing -TimeoutSec 15
                $qualityGateData = $response.Content | ConvertFrom-Json
                
                # Check if we have valid quality gate data
                if ($qualityGateData.projectStatus -and $qualityGateData.projectStatus.status) {
                    $projectStatus = $qualityGateData.projectStatus.status
                    Write-Output "Quality Gate Status: $projectStatus"
                    $qualityGateChecked = $true
                    
                    if ($projectStatus -eq "ERROR") {
                        Write-Host "Quality Gate FAILED! The project has critical issues that need to be addressed." -ForegroundColor Red
                        
                        # Show detailed information about failed conditions
                        if ($qualityGateData.projectStatus.conditions) {
                            Write-Host "Failed conditions:" -ForegroundColor Yellow
                            foreach ($condition in $qualityGateData.projectStatus.conditions) {
                                if ($condition.status -eq "ERROR") {
                                    Write-Host "  - $($condition.metricKey): $($condition.actualValue) (threshold: $($condition.errorThreshold))" -ForegroundColor Red
                                }
                            }
                        }
                        
                        Write-Host "Please check the SonarQube dashboard for detailed analysis: $SonarHostUrl/dashboard?id=$ProjectKey" -ForegroundColor Yellow
                        exit 1
                    } elseif ($projectStatus -eq "WARN") {
                        Write-Warning "Quality Gate passed with warnings. Consider reviewing the issues found."
                        
                        # Show warning conditions
                        if ($qualityGateData.projectStatus.conditions) {
                            Write-Host "Warning conditions:" -ForegroundColor Yellow
                            foreach ($condition in $qualityGateData.projectStatus.conditions) {
                                if ($condition.status -eq "WARN") {
                                    Write-Host "  - $($condition.metricKey): $($condition.actualValue) (threshold: $($condition.warningThreshold))" -ForegroundColor Yellow
                                }
                            }
                        }
                    } else {
                        Write-Output "Quality Gate PASSED! No critical issues found."
                    }
                    break
                } else {
                    Write-Warning "Quality Gate data not yet available. Analysis may still be processing..."
                    if ($attempt -lt $maxAttempts) {
                        Start-Sleep -Seconds 10
                    }
                }
                
            } catch {
                $errorMessage = $_.Exception.Message
                if ($errorMessage -match "403") {
                    Write-Error "Access denied (403) when checking Quality Gate. Possible causes:"
                    Write-Output "1. Token lacks permissions for project '$ProjectKey'"
                    Write-Output "2. Project key '$ProjectKey' does not exist"
                    Write-Output "3. Token does not have 'Browse' permissions on the project"
                    exit 1
                } elseif ($errorMessage -match "404") {
                    Write-Warning "Project not found (404). Analysis may not be complete yet..."
                    if ($attempt -lt $maxAttempts) {
                        Start-Sleep -Seconds 10
                    }
                } else {
                    Write-Warning "Could not check Quality Gate status (attempt $attempt): $errorMessage"
                    if ($attempt -lt $maxAttempts) {
                        Start-Sleep -Seconds 10
                    }
                }
            }
        }
        
        if (-not $qualityGateChecked) {
            Write-Warning "Could not retrieve Quality Gate status after $maxAttempts attempts."
            Write-Output "Analysis completed but Quality Gate status is unknown."
            Write-Output "Please check manually: $SonarHostUrl/dashboard?id=$ProjectKey"
        }
        
    } catch {
        Write-Warning "Could not retrieve Quality Gate status: $_"
        Write-Output "Analysis completed but Quality Gate status is unknown."
        Write-Output "Please check manually: $SonarHostUrl/dashboard?id=$ProjectKey"
    }
}



# Execution flow
try {
    Write-Output "=== SonarQube Scanner Automation Script ==="
    Write-Output "Scanner Version: $SonarScannerVersion"
    Write-Output "Project Key: $ProjectKey"
    Write-Output "Host URL: $SonarHostUrl"
    Write-Output "Project Directory: $ProjectDir"
    Write-Output "Skip Connectivity Test: $SkipConnectivityTest"
    Write-Output "Skip Quality Gate Check: $SkipQualityGateCheck"
    Write-Output "================================================"
    
    Validate-Configuration
    Test-SonarQubeConnectivity
    Download-SonarScanner
    Configure-SonarEnvironment
    Run-SonarScan
    Check-QualityGate
    
    Write-Output "=== SonarQube analysis completed successfully! ==="
} catch {
    Write-Error "Script execution failed: $_"
    Cleanup-PartialFiles
    exit 1
}

exit 0