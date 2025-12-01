# PowerShell helper to load .env file and run docker compose
param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

# Read .env file and set environment variables
$envFile = ".\.env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*(.+?)=(.*)$') {
            $key = $matches[1]
            $value = $matches[2]
            # Skip lines that start with # (comments) and empty lines
            if (-not $key.StartsWith("#") -and $key.Trim()) {
                [Environment]::SetEnvironmentVariable($key, $value)
            }
        }
    }
    Write-Host "Loaded .env file" -ForegroundColor Green
}

# Run docker compose with the provided arguments
& docker compose @Arguments
