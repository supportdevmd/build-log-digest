# Build Log Digest

Group repeated errors and warnings in a plain-text MSBuild or .NET build log. Use the result to find distinct failures without losing their source locations.

## Usage

```powershell
dotnet build --nologo > build.log 2>&1
.\Get-BuildDiagnostics.ps1 -Path .\build.log
.\Get-BuildDiagnostics.ps1 -Path .\build.log -ErrorsOnly -AsJson
```

Run with Windows PowerShell 5.1 or PowerShell 7. The script reads a local file and writes results to the console. It recognizes single-line English diagnostics with codes such as CS1002, MSB4019 and NU1603. Identical rows are grouped, including any repeats in the build summary. Results are ordered by the first occurrence of each diagnostic. Use the original log for multiline context, localized output, or messages without a code.

## Try it with a real build log

From this directory, run the included MSBuild project. It deliberately emits a warning and fails so you can see both diagnostic types.

```powershell
dotnet msbuild .\demo.proj -nologo -verbosity:normal > demo.log 2>&1
.\Get-BuildDiagnostics.ps1 -Path .\demo.log | Format-Table Severity, Code, Count, Message
```

```text
Severity Code     Count Message
-------- ----     ----- -------
warning  DEMO1001     2 Example build warning.
error    DEMO1002     2 Example build failure.
```

MSBuild prints each diagnostic during the build and again in its summary. The digest keeps one row for each diagnostic and records both occurrences.

[MSBuild diagnostic format](https://learn.microsoft.com/en-us/visualstudio/msbuild/msbuild-diagnostic-format-for-tasks)
