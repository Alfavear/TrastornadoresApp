<#
.SYNOPSIS
    Ejecutor de ciclos autonomos para TrastornadoresApp
.DESCRIPTION
    Corre los 4 ciclos en background con intervalos configurables.
    Lee/escribe estado en .opencode/state/cycle-state.json
.NOTES
    Requiere: opencode CLI en PATH, proyecto en D:\Projects\TrastornadoresApp
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('todos','verificacion','colaborativo','roadmap','seguridad')]
    [string]$Ciclo = 'todos',

    [Parameter(Mandatory=$false)]
    [ValidateSet('iniciar','parar','estado','ejecutar-una','reset')]
    [string]$Accion = 'iniciar',

    [Parameter(Mandatory=$false)]
    [int]$IntervaloMin = 5
)

$ProjectRoot = "D:\Projects\TrastornadoresApp"
$StateFile = "$ProjectRoot\.opencode\state\cycle-state.json"
$LogDir = "$ProjectRoot\.opencode\state\logs"

# Crear directorio de logs
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }

function LeerEstado {
    if (Test-Path $StateFile) {
        $json = Get-Content $StateFile -Raw
        $obj = $json | ConvertFrom-Json
        # Convert to mutable hashtable recursively
        $result = ConvertTo-Hashtable $obj
        Write-Host "DEBUG: Result type = $($result.GetType().Name)" -ForegroundColor Yellow
        return $result
    }
    return @{}
}

function ConvertTo-Hashtable {
    param($InputObject)
    if ($null -eq $InputObject) { return @{} }
    
    # Already a hashtable
    if ($InputObject -is [System.Collections.Hashtable]) {
        return $InputObject
    }
    
    # PSCustomObject from ConvertFrom-Json
    if ($InputObject -is [System.Management.Automation.PSCustomObject]) {
        $ht = @{}
        foreach ($prop in $InputObject.PSObject.Properties) {
            $ht[$prop.Name] = ConvertTo-Hashtable $prop.Value
        }
        return $ht
    }
    
    # Regular Dictionary
    if ($InputObject -is [System.Collections.IDictionary]) {
        $ht = @{}
        foreach ($key in $InputObject.Keys) {
            $ht[$key] = ConvertTo-Hashtable $InputObject[$key]
        }
        return $ht
    } elseif ($InputObject -is [System.Collections.IList]) {
        $arr = @()
        foreach ($item in $InputObject) {
            $arr += ConvertTo-Hashtable $item
        }
        return $arr
    } else {
        return $InputObject
    }
}

function GuardarEstado {
    param($Estado)
    $Estado | ConvertTo-Json -Depth 10 | Set-Content $StateFile
}

function Log {
    param([string]$Mensaje, [string]$CicloName = 'global')
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$timestamp] [$CicloName] $Mensaje"
    Write-Host $line
    $logFile = "$LogDir\cycle-$CicloName-$(Get-Date -Format 'yyyyMMdd').log"
    Add-Content -Path $logFile -Value $line
}

function EjecutarComandoOpenCode {
    param([string]$Comando, [string]$CicloName)
    Log "Ejecutando: $Comando" $CicloName
    try {
        $result = & opencode run "$Comando" 2>&1
        Log "OK: $result" $CicloName
        return @{ success = $true; output = $result }
    } catch {
        Log "ERROR: $_" $CicloName
        return @{ success = $false; error = $_ }
    }
}

function CicloVerificacion {
    param($Estado)
    Log "=== INICIO Verificacion Continua ===" 'verificacion'
    $estado = $Estado.cycles.'continuous-verification'
    $estado.lastRun = Get-Date -Format 'o'

    # Backend
    Log "Backend: lint + build + test" 'verificacion'
    $r = EjecutarComandoOpenCode "/check" 'verificacion'
    if (-not $r.success) {
        $estado.consecutiveFailures++
        $estado.lastResult = "FAIL: $($r.error)"
        GuardarEstado $Estado
        Log "=== FIN Verificacion (FALLO) ===" 'verificacion'
        return $Estado
    }

    # Frontend analyze
    Log "Frontend: flutter analyze" 'verificacion'
    $r2 = EjecutarComandoOpenCode "cd frontend; flutter analyze" 'verificacion'
    if (-not $r2.success -or $r2.output -match '\d+ issues? found') {
        $estado.consecutiveFailures++
        $estado.lastResult = "FAIL: flutter analyze issues"
    } else {
        $estado.consecutiveFailures = 0
        $estado.lastResult = "OK"
    }

    $estado.lastRun = Get-Date -Format 'o'
    $Estado.cycles.'continuous-verification' = $estado
    GuardarEstado $Estado
    Log "=== FIN Verificacion ($($estado.lastResult)) ===" 'verificacion'
    return $Estado
}

function CicloColaborativo {
    param($Estado)
    Log "=== INICIO Agentes Colaborativos ===" 'colaborativo'
    $estado = $Estado.cycles.'collaborative-agents'
    $estado.lastRun = Get-Date -Format 'o'
    $estado.currentPhase = 'validating'

    # Fase 1: functional-expert valida work item
    Log "Fase 1: functional-expert validando work item..." 'colaborativo'
    $r = EjecutarComandoOpenCode "functional-expert: Valida siguiente work item de ROADMAP/issues/TODOs. Devuelve ACCEPTED/REJECTED con criterios." 'colaborativo'
    if (-not $r.success -or $r.output -match 'REJECTED') {
        $estado.currentPhase = 'idle'
        $estado.lastResult = "NO_WORK_ITEM"
        $Estado.cycles.'collaborative-agents' = $estado
        GuardarEstado $Estado
        Log "=== FIN Colaborativo (sin work item valido) ===" 'colaborativo'
        return $Estado
    }

    $estado.currentPhase = 'implementing'
    $estado.workItem = @{ criteria = $r.output; timestamp = (Get-Date -Format 'o') }
    GuardarEstado $Estado

    # Fase 2: Implementacion (detecta backend vs frontend)
    Log "Fase 2: Implementando..." 'colaborativo'
    $r2 = EjecutarComandoOpenCode "backend-architect o flutter-dev: Implementa segun criterios: $($r.output)" 'colaborativo'
    if (-not $r2.success) {
        $estado.currentPhase = 'idle'
        $estado.lastResult = "IMPLEMENTATION_FAILED"
        $Estado.cycles.'collaborative-agents' = $estado
        GuardarEstado $Estado
        Log "=== FIN Colaborativo (FALLO implementacion) ===" 'colaborativo'
        return $Estado
    }

    # Fase 3: Code Review
    $estado.currentPhase = 'reviewing'
    GuardarEstado $Estado
    Log "Fase 3: Code Review..." 'colaborativo'
    $r3 = EjecutarComandoOpenCode "code-reviewer: Revisa git diff actual. Convenciones, Clean Arch, tests." 'colaborativo'
    if ($r3.output -match 'CHANGES_REQUESTED') {
        Log "Code review requiere cambios, volviendo a implementacion..." 'colaborativo'
        $estado.currentPhase = 'implementing'
        GuardarEstado $Estado
        # Segunda vuelta
        $r4 = EjecutarComandoOpenCode "backend-architect o flutter-dev: Fixea hallazgos code review: $($r3.output)" 'colaborativo'
        if (-not $r4.success) {
            $estado.currentPhase = 'idle'
            $estado.lastResult = "REVIEW_FAILED_AFTER_FIX"
            $Estado.cycles.'collaborative-agents' = $estado
            GuardarEstado $Estado
            return $Estado
        }
    }

    # Fase 4: Seguridad
    $estado.currentPhase = 'securing'
    GuardarEstado $Estado
    Log "Fase 4: Seguridad..." 'colaborativo'
    $r5 = EjecutarComandoOpenCode "security-reviewer: Audita codigo nuevo. Tabla hallazgos Critico/Alta/Media/Baja." 'colaborativo'
    if ($r5.output -match '(Critico|Alta)') {
        Log "Hallazgos seguridad criticos/altos, remediando..." 'colaborativo'
        $r6 = EjecutarComandoOpenCode "backend-architect: Remedia hallazgos seguridad: $($r5.output)" 'colaborativo'
        if (-not $r6.success) {
            $estado.currentPhase = 'idle'
            $estado.lastResult = "SECURITY_REMEDIATION_FAILED"
            $Estado.cycles.'collaborative-agents' = $estado
            GuardarEstado $Estado
            return $Estado
        }
        # Re-verificar
        $r7 = EjecutarComandoOpenCode "security-reviewer: Re-verifica tras remediacion." 'colaborativo'
    }

    # Fase 5: Documentacion
    $estado.currentPhase = 'documenting'
    GuardarEstado $Estado
    Log "Fase 5: Documentacion..." 'colaborativo'
    $r8 = EjecutarComandoOpenCode "bitacora-keeper: Documenta avance real en Bitacora.md, actualiza ROADMAP.md y AGENTS.md si aplica." 'colaborativo'

    $estado.currentPhase = 'idle'
    $estado.workItem = $null
    $estado.lastResult = "COMPLETED"
    $estado.lastRun = Get-Date -Format 'o'
    $Estado.cycles.'collaborative-agents' = $estado
    GuardarEstado $Estado
    Log "=== FIN Colaborativo (COMPLETADO) ===" 'colaborativo'
    return $Estado
}

function CicloRoadmap {
    param($Estado)
    Log "=== INICIO Roadmap-Driven ===" 'roadmap'
    $estado = $Estado.cycles.'roadmap-driven'
    $estado.lastRun = Get-Date -Format 'o'

    # Leer ROADMAP y encontrar siguiente [ ]
    Log "Leyendo ROADMAP.md..." 'roadmap'
    $r = EjecutarComandoOpenCode "bitacora-keeper: Lee ROADMAP.md, detecta siguiente item [ ] prioritario con dependencias resueltas. Devuelve seccion, item, agente sugerido." 'roadmap'
    if (-not $r.success -or $r.output -match 'NONE') {
        $estado.lastResult = "NO_PENDING_ITEMS"
        $Estado.cycles.'roadmap-driven' = $estado
        GuardarEstado $Estado
        Log "=== FIN Roadmap (sin items pendientes) ===" 'roadmap'
        return $Estado
    }

    # Validar con functional-expert
    Log "Validando valor ministerial..." 'roadmap'
    $r2 = EjecutarComandoOpenCode "functional-expert: Valida item ROADMAP: $($r.output). Valor ministerial real? Factible ahora?" 'roadmap'
    if ($r2.output -match 'NO|REJECT') {
        $estado.lastResult = "REJECTED_BY_FUNCTIONAL"
        $estado.completedItems += @{ item = $r.output; reason = $r2.output; timestamp = (Get-Date -Format 'o') }
        $Estado.cycles.'roadmap-driven' = $estado
        GuardarEstado $Estado
        return CicloRoadmap $Estado  # Recursivo: siguiente item
    }

    # Ejecutar con agente apropiado
    Log "Ejecutando item con agente asignado..." 'roadmap'
    $r3 = EjecutarComandoOpenCode "backend-architect o flutter-dev: Implementa item ROADMAP: $($r.output)" 'roadmap'
    if (-not $r3.success) {
        $estado.lastResult = "IMPLEMENTATION_FAILED"
        $Estado.cycles.'roadmap-driven' = $estado
        GuardarEstado $Estado
        return $Estado
    }

    # Verificacion + review + seguridad + docs
    $r4 = EjecutarComandoOpenCode "/check" 'roadmap'
    if (-not $r4.success) {
        $estado.lastResult = "VERIFICATION_FAILED"
        $Estado.cycles.'roadmap-driven' = $estado
        GuardarEstado $Estado
        return $Estado
    }

    $r5 = EjecutarComandoOpenCode "code-reviewer + security-reviewer: Revisa y audita implementacion." 'roadmap'
    $r6 = EjecutarComandoOpenCode "bitacora-keeper: Documenta, marca [x] en ROADMAP.md." 'roadmap'

    $estado.completedItems += @{ item = $r.output; timestamp = (Get-Date -Format 'o'); result = 'DONE' }
    $estado.lastResult = "COMPLETED"
    $estado.lastRun = Get-Date -Format 'o'
    $Estado.cycles.'roadmap-driven' = $estado
    GuardarEstado $Estado
    Log "=== FIN Roadmap (COMPLETADO: $($r.output)) ===" 'roadmap'
    return $Estado
}

function CicloSeguridad {
    param($Estado)
    Log "=== INICIO Seguridad Continua ===" 'seguridad'
    $estado = $Estado.cycles.'security-continuous'
    $estado.lastRun = Get-Date -Format 'o'

    $scope = $estado.scanScope
    Log "Escaneo scope: $scope" 'seguridad'
    $r = EjecutarComandoOpenCode "security-reviewer: Escaneo $scope completo contra checklist .opencode/skills/security-checklist/SKILL.md. Tabla hallazgos." 'seguridad'

    if ($r.output -match '(Critico|Alta)') {
        Log "Hallazgos Criticos/Alta detectados, remediando..." 'seguridad'
        $r2 = EjecutarComandoOpenCode "backend-architect: Remedia TODOS hallazgos Criticos/Alta: $($r.output)" 'seguridad'
        if ($r2.success) {
            # Re-escanear
            $r3 = EjecutarComandoOpenCode "security-reviewer: Re-verifica scope $scope tras remediacion." 'seguridad'
            if (-not ($r3.output -match '(Critico|Alta)')) {
                $estado.lastResult = "REMEDIATED"
            } else {
                $estado.lastResult = "REMEDIATION_INCOMPLETE"
                $estado.consecutiveFailures++
            }
        } else {
            $estado.lastResult = "REMEDIATION_FAILED"
            $estado.consecutiveFailures++
        }
    } else {
        $estado.lastResult = "CLEAN"
        $estado.consecutiveFailures = 0
    }

    # Documentar
    EjecutarComandoOpenCode "bitacora-keeper: Registra escaneo seguridad ${scope}: $($estado.lastResult)." 'seguridad' | Out-Null

    $estado.lastRun = Get-Date -Format 'o'
    # Rotar scope
    $scopes = @('full','deps','secrets','config','auth')
    $idx = $scopes.IndexOf($scope)
    $estado.scanScope = $scopes[($idx + 1) % $scopes.Count]
    $Estado.cycles.'security-continuous' = $estado
    GuardarEstado $Estado
    Log "=== FIN Seguridad ($($estado.lastResult)) ===" 'seguridad'
    return $Estado
}

# ===== MAIN =====
$Estado = LeerEstado
# Ensure full structure exists
if (-not $Estado) { $Estado = @{} }
if (-not $Estado.ContainsKey('global')) { $Estado['global'] = @{} }
if (-not $Estado.ContainsKey('cycles')) { $Estado['cycles'] = @{} }
if (-not $Estado['global'].ContainsKey('running')) { $Estado['global']['running'] = $false }

switch ($Accion) {
    'reset' {
        Log "RESET: Limpiando estado..."
        $Estado = @{
            version = 1
            lastRun = $null
            cycles = @{
                'continuous-verification' = @{ enabled=$true; intervalMinutes=5; lastRun=$null; lastResult=$null; consecutiveFailures=0 }
                'collaborative-agents' = @{ enabled=$true; intervalMinutes=15; lastRun=$null; lastResult=$null; currentPhase='idle'; workItem=$null }
                'roadmap-driven' = @{ enabled=$true; intervalMinutes=30; lastRun=$null; lastResult=$null; nextItemIndex=0; completedItems=@() }
                'security-continuous' = @{ enabled=$true; intervalMinutes=10; lastRun=$null; lastResult=$null; scanScope='full' }
            }
            global = @{ running=$false; pid=$null; startTime=$null }
        }
        GuardarEstado $Estado
        Log "Estado reseteado."
        exit 0
    }
    'estado' {
        $Estado | ConvertTo-Json -Depth 10
        exit 0
    }
    'parar' {
        $Estado['global']['running'] = $false
        GuardarEstado $Estado
        Log "Ciclos detenidos (flag running=false)."
        exit 0
    }
    'ejecutar-una' {
        Log "Ejecucion unica: $Ciclo"
        switch ($Ciclo) {
            'verificacion' { $Estado = CicloVerificacion $Estado }
            'colaborativo' { $Estado = CicloColaborativo $Estado }
            'roadmap' { $Estado = CicloRoadmap $Estado }
            'seguridad' { $Estado = CicloSeguridad $Estado }
            'todos' {
                $Estado = CicloVerificacion $Estado
                $Estado = CicloSeguridad $Estado
                $Estado = CicloColaborativo $Estado
                $Estado = CicloRoadmap $Estado
            }
        }
        exit 0
    }
    'iniciar' {
        if ($Estado['global']['running']) {
            Log "Ya hay ciclos corriendo (PID: $($Estado['global']['pid'])). Usa 'parar' primero."
            exit 1
        }
        $Estado['global']['running'] = $true
        $Estado['global']['startTime'] = Get-Date -Format 'o'
        $Estado['global']['pid'] = $PID
        GuardarEstado $Estado
        Log "=== INICIANDO CICLOS AUTONOMOS (PID: $PID) ==="

        # Loop principal
        while ($Estado['global']['running']) {
            $Estado = LeerEstado
            if (-not $Estado['global']['running']) { break }

            $now = Get-Date
            $ciclos = @(
                @{ name='verificacion'; key='continuous-verification'; fn={ CicloVerificacion $args[0] } },
                @{ name='seguridad'; key='security-continuous'; fn={ CicloSeguridad $args[0] } },
                @{ name='colaborativo'; key='collaborative-agents'; fn={ CicloColaborativo $args[0] } },
                @{ name='roadmap'; key='roadmap-driven'; fn={ CicloRoadmap $args[0] } }
            )

            foreach ($c in $ciclos) {
                $cicloEstado = $Estado['cycles'][$c.key]
                if (-not $cicloEstado['enabled']) { continue }
                $interval = $cicloEstado['intervalMinutes'] * 60
                $lastRun = if ($cicloEstado['lastRun']) { [DateTime]::Parse($cicloEstado['lastRun']) } else { [DateTime]::MinValue }
                $nextRun = $lastRun.AddSeconds($interval)
                if ($now -ge $nextRun) {
                    Log "Tiempo para ciclo: $($c.name)" $c.name
                    $Estado = & $c.fn $Estado
                }
            }

            Start-Sleep -Seconds 30  # Check cada 30 seg
        }
        Log "=== CICLOS DETENIDOS ==="
        exit 0
    }
    default {
        Log "Accion no reconocida: $Accion"
        exit 1
    }
}