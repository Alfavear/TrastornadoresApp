<#
.SYNOPSIS
    Simple autonomous cycles runner for TrastornadoresApp
.DESCRIPTION
    Runs verification, security, and roadmap cycles directly without opencode run
.NOTES
    Run in a separate PowerShell window for 24/7 operation
#>

$ProjectRoot = "D:\Projects\TrastornadoresApp"
$LogDir = "$ProjectRoot\.opencode\state\logs"
mkdir $LogDir -ErrorAction SilentlyContinue | Out-Null

function Log {
    param([string]$Msg, [string]$Cycle = 'global')
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$ts] [$Cycle] $Msg"
    Write-Host $line
    Add-Content -Path "$LogDir\cycle-$Cycle-$(Get-Date -Format 'yyyyMMdd').log" -Value $line
}

function RunCmd {
    param([string]$Cmd, [string]$Cycle, [string]$Dir = $ProjectRoot)
    Log "Ejecutando: $Cmd" $Cycle
    try {
        $result = Invoke-Expression "cd '$Dir'; $Cmd" 2>&1
        Log "OK`n$result" $Cycle
        return @{ success=$true; output=$result }
    } catch {
        Log "ERROR: $_" $Cycle
        return @{ success=$false; error=$_ }
    }
}

# ===== CYCLE FUNCTIONS =====

function CicloVerificacion {
    Log "=== INICIO Verificacion ===" 'verificacion'
    
    # Backend
    Log "Backend: lint" 'verificacion'
    $r = RunCmd "npm run lint" 'verificacion' "$ProjectRoot\backend"
    if (-not $r.success) { return }
    
    Log "Backend: build" 'verificacion'
    $r = RunCmd "npm run build" 'verificacion' "$ProjectRoot\backend"
    if (-not $r.success) { return }
    
    Log "Backend: test" 'verificacion'
    $r = RunCmd "npm test" 'verificacion' "$ProjectRoot\backend"
    if (-not $r.success) { return }
    
    # Frontend
    Log "Frontend: analyze" 'verificacion'
    $r = RunCmd "flutter analyze" 'verificacion' "$ProjectRoot\frontend"
    if (-not $r.success) { return }
    
    Log "Frontend: test" 'verificacion'
    $r = RunCmd "flutter test" 'verificacion' "$ProjectRoot\frontend"
    if (-not $r.success) { return }
    
    Log "=== FIN Verificacion (OK) ===" 'verificacion'
}

function CicloSeguridad {
    Log "=== INICIO Seguridad ===" 'seguridad'
    
    Log "npm audit" 'seguridad'
    $r = RunCmd "npm audit --audit-level=high" 'seguridad' "$ProjectRoot\backend"
    
    Log "flutter analyze security" 'seguridad'
    $r = RunCmd "flutter analyze" 'seguridad' "$ProjectRoot\frontend"
    
    Log "=== FIN Seguridad ===" 'seguridad'
}

function CicloRoadmap {
    Log "=== INICIO Roadmap ===" 'roadmap'
    
    # Check what's next in ROADMAP
    $roadmap = Get-Content "$ProjectRoot\ROADMAP.md" -Raw
    $pending = [regex]::Matches($roadmap, '-\s*\[\s\]\s*(\d+\.\d+)\s*(.+)')
    
    foreach ($match in $pending) {
        $item = $match.Groups[1].Value + " " + $match.Groups[2].Value
        Log "Siguiente item: $item" 'roadmap'
        
        # For now just log what's next
        # Real implementation would assign to backend-architect or flutter-dev
        break
    }
    
    Log "=== FIN Roadmap ===" 'roadmap'
}

# ===== MAIN LOOP =====
Log "=== INICIANDO CICLOS AUTONOMOS SIMPLES (PID: $PID) ==="

$intervals = @{
    'verificacion' = 5 * 60      # 5 min
    'seguridad'    = 10 * 60     # 10 min
    'roadmap'      = 30 * 60     # 30 min
}

$lastRun = @{
    'verificacion' = 0
    'seguridad'    = 0
    'roadmap'      = 0
}

while ($true) {
    $now = [DateTime]::Now.Ticks / 10000000  # seconds since epoch
    
    foreach ($cycle in $intervals.Keys) {
        if ($now - $lastRun[$cycle] -ge $intervals[$cycle]) {
            Log "Tiempo para ciclo: $cycle" $cycle
            
            switch ($cycle) {
                'verificacion' { CicloVerificacion }
                'seguridad'    { CicloSeguridad }
                'roadmap'      { CicloRoadmap }
            }
            
            $lastRun[$cycle] = $now
        }
    }
    
    Start-Sleep -Seconds 30
}

Log "=== CICLOS DETENIDOS ==="