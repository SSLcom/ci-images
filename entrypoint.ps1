Write-Host "Run CodeSigner"

$CODE_SIGN_TOOL_PATH="C:/CodeSignTool"
$env:CODE_SIGN_TOOL_PATH = "C:/CodeSignTool"

# Exec the specified command or fall back on bash
if ($args.Length -eq 0) {
    $CMD = "powershell"
} else {
    $CMD = $args
}

$CURRENT_ENV = "Production"
$ENVIRONMENT_NAME = $env:ENVIRONMENT_NAME.Replace('"', "")
if ($ENVIRONMENT_NAME -ne "PROD") {
    Copy-Item -Path "C:/CodeSignTool/conf/code_sign_tool.properties" -Destination "C:/CodeSignTool/conf/code_sign_tool.properties.production" -Force
    Copy-Item -Path "C:/CodeSignTool/conf/code_sign_tool_demo.properties" -Destination "C:/CodeSignTool/conf/code_sign_tool.properties" -Force
    $CURRENT_ENV = "Sandbox"
}
Write-Host "Running ESigner.com CodeSign Action on $CURRENT_ENV"
Write-Host ""

$COMMAND = "C:/CodeSignTool/CodeSignTool.bat"

# CMD Args
$COMMAND = "$COMMAND $($CMD -join ' ')"

# Authentication Info
if ($CMD -notcontains "--help") {
    if ($env:USERNAME) { $COMMAND = "$COMMAND -username=$env:USERNAME" }
    if ($env:PASSWORD) { $COMMAND = "$COMMAND -password=$env:PASSWORD" }

    if ($CMD -notcontains "get_credential_ids") {
        if ($env:CREDENTIAL_ID) { $COMMAND = "$COMMAND -credential_id=$env:CREDENTIAL_ID" }
        if ($CMD -notcontains "credential_info") {
            if ($env:TOTP_SECRET) { $COMMAND = "$COMMAND -totp_secret=$env:TOTP_SECRET" }
            if ($env:PROGRAM_NAME) { $COMMAND = "$COMMAND -program_name=$env:PROGRAM_NAME" }
            if ($env:FILE_PATH) { $COMMAND = "$COMMAND -input_file_path=$env:FILE_PATH" }
            if ($env:OUTPUT_PATH) { $COMMAND = "$COMMAND -output_dir_path=$env:OUTPUT_PATH" }
        }
    }
}

$RESULT = & Invoke-Expression $COMMAND | Out-String
if ($RESULT -match "Error" -OR $RESULT -match "Exception" -OR $RESULT -match "Missing required option" -OR $RESULT -match "Unmatched arguments from" -OR $RESULT -match "Unmatched argument" -OR $RESULT -match "Not a valid output directory") {
    Write-Host "Something Went Wrong. Please try again."
    Write-Host "$RESULT"
    exit 1
} else {
    if ($CMD -contains "sign")
    {
        $LOG_USERNAME = $USERNAME.Replace('"', "")
        $LOG_CREDENTIAL_ID = $CREDENTIAL_ID.Replace('"', "")
        Write-Host "Code signed successfully by ${LOG_USERNAME} using ${LOG_CREDENTIAL_ID} credential id"
    }
    Write-Host "$RESULT"
}

exit 0
