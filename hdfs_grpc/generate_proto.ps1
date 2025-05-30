# Get the directory where the script resides
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Set specific directory variables
$definitionsDir = Join-Path $scriptDir "definitions"
$servicesDir = Join-Path $scriptDir "services"

# Create the services directory if it doesn't exist
if (-not (Test-Path -Path $servicesDir)) {
	New-Item -ItemType Directory -Path $servicesDir | Out-Null
}

# Get all definition files in the protocol definitions directory
$protoFiles = Get-ChildItem -Path $definitionsDir -Filter "*.proto"

# Loop through each file
foreach ($protoFile in $protoFiles) {
    Write-Host "Processing $($protoFile.Name)..."

    # Check if the file already has service files generated
    $protoBase = [System.IO.Path]::GetFileNameWithoutExtension($protoFile.Name)
    $matchingServices = Get-ChildItem -Path $servicesDir -Filter "$protoBase*"

    # If so check if they are outdated
    $outdatedServices = $false
    if ($matchingServices.Count -gt 0) {
        foreach ($serviceFile in $matchingServices) {
			# If the .proto file is newer, mark the services as outdated
            if ($protoFile.LastWriteTime -gt $serviceFile.LastWriteTime) {
                $outdatedServices = $true
                Write-Host "Outdated service file found: $($serviceFile.Name)"
                break
            }
        }
    }

    # Generate Ruby gRPC code from the .proto file if needed
    if ($outdatedServices -or ($matchingServices.Count -eq 0)) {
        Write-Host "Generating new protocol buffers for $($protoFile.Name)..."
        grpc_tools_ruby_protoc --proto_path=$definitionsDir `
            --ruby_out=$servicesDir `
            --grpc_out=$servicesDir `
            $protoFile.FullName
    }
    else {
        Write-Host "Service files for $($protoFile.Name) are up to date."
    }
}
