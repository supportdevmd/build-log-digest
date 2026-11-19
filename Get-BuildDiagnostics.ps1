[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $Path,

    [switch] $ErrorsOnly,

    [switch] $AsJson
)

$diagnosticPattern = [regex]::new(
    '^(?:(?<Origin>.+?)\s*:\s*)?(?:[^:]+?\s+)?(?<Severity>error|warning)\s+(?<Code>[A-Z][A-Z0-9]*\d+)\s*:\s*(?<Message>.*)$',
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
)
$ansiPattern = [regex]::new('\x1B\[[0-?]*[ -/]*[@-~]')
$unique = [System.Collections.Specialized.OrderedDictionary]::new([StringComparer]::Ordinal)

Get-Content -LiteralPath $Path -ErrorAction Stop | ForEach-Object {
    $line = $ansiPattern.Replace($_, '').Trim() -replace '^\d+>\s*', ''
    $diagnostic = $diagnosticPattern.Match($line)
    if ($diagnostic.Success) {
        $severity = $diagnostic.Groups['Severity'].Value.ToLowerInvariant()
        if (-not $ErrorsOnly -or $severity -eq 'error') {
            $origin = $diagnostic.Groups['Origin'].Value.Trim()
            $code = $diagnostic.Groups['Code'].Value.ToUpperInvariant()
            $message = $diagnostic.Groups['Message'].Value.Trim()
            $key = "$severity`n$code`n$origin`n$message"
            if ($unique.Contains($key)) {
                $unique[$key].Count++
            } else {
                $unique.Add($key, [pscustomobject]@{
                    Severity = $severity
                    Code = $code
                    Count = 1
                    Origin = $origin
                    Message = $message
                })
            }
        }
    }
}

if ($AsJson) {
    ConvertTo-Json -InputObject @($unique.Values)
} else {
    $unique.Values
}
