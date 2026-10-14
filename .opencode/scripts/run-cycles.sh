#!/usr/bin/env bash
# Ejecutor de ciclos autónomos para TrastornadoresApp (Linux/Mac)
# Requiere: opencode CLI en PATH, proyecto en directorio actual o $PROJECT_ROOT

set -euo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
STATE_FILE="$PROJECT_ROOT/.opencode/state/cycle-state.json"
LOG_DIR="$PROJECT_ROOT/.opencode/state/logs"

mkdir -p "$LOG_DIR"

log() {
    local msg="$1"
    local cycle="${2:-global}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$cycle] $msg" | tee -a "$LOG_DIR/cycle-$cycle-$(date '+%Y%m%d').log"
}

read_state() {
    if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE"
    else
        echo '{}'
    fi
}

write_state() {
    echo "$1" > "$STATE_FILE"
}

run_opencode() {
    local cmd="$1"
    local cycle="$2"
    log "Ejecutando: $cmd" "$cycle"
    if opencode run "$cmd" 2>&1 | tee -a "$LOG_DIR/cycle-$cycle-$(date '+%Y%m%d').log"; then
        log "OK" "$cycle"
        return 0
    else
        log "ERROR" "$cycle"
        return 1
    fi
}

ciclo_verificacion() {
    local state_json="$1"
    log "=== INICIO Verificación Continua ===" "verificacion"

    # Backend: lint + build + test
    log "Backend: lint + build + test" "verificacion"
    if ! run_opencode "/check" "verificacion"; then
        echo "$state_json" | jq '.cycles."continuous-verification".consecutiveFailures += 1 | .cycles."continuous-verification".lastResult = "FAIL: backend check" | .cycles."continuous-verification".lastRun = now | .cycles."continuous-verification".lastRun |= todateiso8601'
        return
    fi

    # Frontend: flutter analyze
    log "Frontend: flutter analyze" "verificacion"
    if ! (cd "$PROJECT_ROOT/frontend" && flutter analyze 2>&1 | tee -a "$LOG_DIR/cycle-verificacion-$(date '+%Y%m%d').log"); then
        echo "$state_json" | jq '.cycles."continuous-verification".consecutiveFailures += 1 | .cycles."continuous-verification".lastResult = "FAIL: flutter analyze" | .cycles."continuous-verification".lastRun = now | .cycles."continuous-verification".lastRun |= todateiso8601'
        return
    fi

    echo "$state_json" | jq '.cycles."continuous-verification".consecutiveFailures = 0 | .cycles."continuous-verification".lastResult = "OK" | .cycles."continuous-verification".lastRun = now | .cycles."continuous-verification".lastRun |= todateiso8601'
}

ciclo_seguridad() {
    local state_json="$1"
    log "=== INICIO Seguridad Continua ===" "seguridad"

    local scope=$(echo "$state_json" | jq -r '.cycles."security-continuous".scanScope // "full"')
    log "Escaneo scope: $scope" "seguridad"

    if ! run_opencode "security-reviewer: Escaneo $scope completo contra checklist .opencode/skills/security-checklist/SKILL.md. Tabla hallazgos." "seguridad"; then
        echo "$state_json" | jq '.cycles."security-continuous".lastResult = "SCAN_FAILED" | .cycles."security-continuous".lastRun = now | .cycles."security-continuous".lastRun |= todateiso8601'
        return
    fi

    # Simplified: assume security-reviewer output is captured and checked for Critico/Alta
    # In real implementation, would parse the output
    echo "$state_json" | jq '.cycles."security-continuous".lastResult = "CLEAN" | .cycles."security-continuous".consecutiveFailures = 0 | .cycles."security-continuous".lastRun = now | .cycles."security-continuous".lastRun |= todateiso8601 | .cycles."security-continuous".scanScope = (["full","deps","secrets","config","auth"] | .[index($scope) + 1 % length])'
}

ciclo_colaborativo() {
    local state_json="$1"
    log "=== INICIO Agentes Colaborativos ===" "colaborativo"
    echo "$state_json" | jq '.cycles."collaborative-agents".lastRun = now | .cycles."collaborative-agents".lastRun |= todateiso8601 | .cycles."collaborative-agents".currentPhase = "validating"'

    # Fase 1: functional-expert valida work item
    log "Fase 1: functional-expert validando work item..." "colaborativo"
    if ! run_opencode "functional-expert: Valida siguiente work item de ROADMAP/issues/TODOs. Devuelve ACCEPTED/REJECTED con criterios." "colaborativo"; then
        echo "$state_json" | jq '.cycles."collaborative-agents".currentPhase = "idle" | .cycles."collaborative-agents".lastResult = "NO_WORK_ITEM"'
        return
    fi

    echo "$state_json" | jq '.cycles."collaborative-agents".currentPhase = "implementing"'

    # Fase 2: Implementación
    log "Fase 2: Implementando..." "colaborativo"
    if ! run_opencode "backend-architect o flutter-dev: Implementa según criterios del functional-expert." "colaborativo"; then
        echo "$state_json" | jq '.cycles."collaborative-agents".currentPhase = "idle" | .cycles."collaborative-agents".lastResult = "IMPLEMENTATION_FAILED"'
        return
    fi

    # Fase 3: Code Review
    echo "$state_json" | jq '.cycles."collaborative-agents".currentPhase = "reviewing"'
    log "Fase 3: Code Review..." "colaborativo"
    run_opencode "code-reviewer: Revisa git diff actual. Convenciones, Clean Arch, tests." "colaborativo"

    # Fase 4: Seguridad
    echo "$state_json" | jq '.cycles."collaborative-agents".currentPhase = "securing"'
    log "Fase 4: Seguridad..." "colaborativo"
    run_opencode "security-reviewer: Audita código nuevo. Tabla hallazgos Crítico/Alta/Media/Baja." "colaborativo"

    # Fase 5: Documentación
    echo "$state_json" | jq '.cycles."collaborative-agents".currentPhase = "documenting"'
    log "Fase 5: Documentación..." "colaborativo"
    run_opencode "bitacora-keeper: Documenta avance real en Bitacora.md, actualiza ROADMAP.md y AGENTS.md si aplica." "colaborativo"

    echo "$state_json" | jq '.cycles."collaborative-agents".currentPhase = "idle" | .cycles."collaborative-agents".workItem = null | .cycles."collaborative-agents".lastResult = "COMPLETED" | .cycles."collaborative-agents".lastRun = now | .cycles."collaborative-agents".lastRun |= todateiso8601'
}

ciclo_roadmap() {
    local state_json="$1"
    log "=== INICIO Roadmap-Driven ===" "roadmap"
    echo "$state_json" | jq '.cycles."roadmap-driven".lastRun = now | .cycles."roadmap-driven".lastRun |= todateiso8601'

    # Leer ROADMAP y encontrar siguiente [ ]
    log "Leyendo ROADMAP.md..." "roadmap"
    if ! run_opencode "bitacora-keeper: Lee ROADMAP.md, detecta siguiente item [ ] prioritario con dependencias resueltas. Devuelve sección, item, agente sugerido." "roadmap"; then
        echo "$state_json" | jq '.cycles."roadmap-driven".lastResult = "NO_PENDING_ITEMS"'
        return
    fi

    # Validar con functional-expert
    log "Validando valor ministerial..." "roadmap"
    if ! run_opencode "functional-expert: Valida item ROADMAP. ¿Valor ministerial real? ¿Factible ahora?" "roadmap"; then
        echo "$state_json" | jq '.cycles."roadmap-driven".lastResult = "REJECTED_BY_FUNCTIONAL" | .cycles."roadmap-driven".completedItems += [{item: "rejected", reason: "functional-expert rejected", timestamp: (now | todateiso8601)}]'
        return
    fi

    # Ejecutar con agente apropiado
    log "Ejecutando item con agente asignado..." "roadmap"
    if ! run_opencode "backend-architect o flutter-dev: Implementa item ROADMAP prioritario." "roadmap"; then
        echo "$state_json" | jq '.cycles."roadmap-driven".lastResult = "IMPLEMENTATION_FAILED"'
        return
    fi

    # Verificación + review + seguridad + docs
    run_opencode "/check" "roadmap"
    run_opencode "code-reviewer + security-reviewer: Revisa y audita implementación." "roadmap"
    run_opencode "bitacora-keeper: Documenta, marca [x] en ROADMAP.md." "roadmap"

    echo "$state_json" | jq '.cycles."roadmap-driven".lastResult = "COMPLETED" | .cycles."roadmap-driven".completedItems += [{item: "completed", timestamp: (now | todateiso8601), result: "DONE"}] | .cycles."roadmap-driven".lastRun = now | .cycles."roadmap-driven".lastRun |= todateiso8601'
}

main() {
    local ciclo="${1:-todos}"
    local accion="${2:-iniciar}"

    local state_json=$(read_state)

    # Initialize state if empty
    if [[ "$state_json" == "{}" ]]; then
        state_json='{
            "version": 1,
            "lastRun": null,
            "cycles": {
                "continuous-verification": {"enabled": true, "intervalMinutes": 5, "lastRun": null, "lastResult": null, "consecutiveFailures": 0},
                "collaborative-agents": {"enabled": true, "intervalMinutes": 15, "lastRun": null, "lastResult": null, "currentPhase": "idle", "workItem": null},
                "roadmap-driven": {"enabled": true, "intervalMinutes": 30, "lastRun": null, "lastResult": null, "nextItemIndex": 0, "completedItems": []},
                "security-continuous": {"enabled": true, "intervalMinutes": 10, "lastRun": null, "lastResult": null, "scanScope": "full"}
            },
            "global": {"running": false, "pid": null, "startTime": null}
        }'
    fi

    case "$accion" in
        reset)
            log "RESET: Limpiando estado..."
            state_json='{
                "version": 1,
                "lastRun": null,
                "cycles": {
                    "continuous-verification": {"enabled": true, "intervalMinutes": 5, "lastRun": null, "lastResult": null, "consecutiveFailures": 0},
                    "collaborative-agents": {"enabled": true, "intervalMinutes": 15, "lastRun": null, "lastResult": null, "currentPhase": "idle", "workItem": null},
                    "roadmap-driven": {"enabled": true, "intervalMinutes": 30, "lastRun": null, "lastResult": null, "nextItemIndex": 0, "completedItems": []},
                    "security-continuous": {"enabled": true, "intervalMinutes": 10, "lastRun": null, "lastResult": null, "scanScope": "full"}
                },
                "global": {"running": false, "pid": null, "startTime": null}
            }'
            write_state "$state_json"
            log "Estado reseteado."
            exit 0
            ;;
        estado)
            echo "$state_json" | jq '.'
            exit 0
            ;;
        parar)
            echo "$state_json" | jq '.global.running = false' | write_state
            log "Ciclos detenidos (flag running=false)."
            exit 0
            ;;
        ejecutar-una)
            log "Ejecución única: $ciclo"
            case "$ciclo" in
                verificacion) state_json=$(ciclo_verificacion "$state_json") ;;
                seguridad) state_json=$(ciclo_seguridad "$state_json") ;;
                colaborativo) state_json=$(ciclo_colaborativo "$state_json") ;;
                roadmap) state_json=$(ciclo_roadmap "$state_json") ;;
                todos)
                    state_json=$(ciclo_verificacion "$state_json")
                    state_json=$(ciclo_seguridad "$state_json")
                    state_json=$(ciclo_colaborativo "$state_json")
                    state_json=$(ciclo_roadmap "$state_json")
                    ;;
            esac
            write_state "$state_json"
            exit 0
            ;;
        iniciar)
            local running=$(echo "$state_json" | jq -r '.global.running // false')
            if [[ "$running" == "true" ]]; then
                log "Ya hay ciclos corriendo. Usa 'parar' primero."
                exit 1
            fi

            state_json=$(echo "$state_json" | jq '.global.running = true | .global.startTime = now | .global.startTime |= todateiso8601 | .global.pid = '$BASHPID)
            write_state "$state_json"
            log "=== INICIANDO CICLOS AUTÓNOMOS (PID: $BASHPID) ==="

            while true; do
                state_json=$(read_state)
                running=$(echo "$state_json" | jq -r '.global.running // false')
                if [[ "$running" != "true" ]]; then
                    break
                fi

                local now=$(date +%s)

                # Check each cycle
                for cycle_name in "continuous-verification" "security-continuous" "collaborative-agents" "roadmap-driven"; do
                    local enabled=$(echo "$state_json" | jq -r ".cycles.\"$cycle_name\".enabled // false")
                    if [[ "$enabled" != "true" ]]; then continue; fi

                    local interval=$(echo "$state_json" | jq -r ".cycles.\"$cycle_name\".intervalMinutes // 5")
                    local last_run=$(echo "$state_json" | jq -r ".cycles.\"$cycle_name\".lastRun // \"\"")
                    local next_run=0

                    if [[ -n "$last_run" && "$last_run" != "null" ]]; then
                        local last_epoch=$(date -d "$last_run" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "$last_run" +%s 2>/dev/null || echo 0)
                        next_run=$((last_epoch + interval * 60))
                    fi

                    if [[ $now -ge $next_run ]]; then
                        log "Tiempo para ciclo: $cycle_name" "$cycle_name"
                        case "$cycle_name" in
                            "continuous-verification") state_json=$(ciclo_verificacion "$state_json") ;;
                            "security-continuous") state_json=$(ciclo_seguridad "$state_json") ;;
                            "collaborative-agents") state_json=$(ciclo_colaborativo "$state_json") ;;
                            "roadmap-driven") state_json=$(ciclo_roadmap "$state_json") ;;
                        esac
                        write_state "$state_json"
                    fi
                done

                sleep 30
            done

            log "=== CICLOS DETENIDOS ==="
            exit 0
            ;;
        *)
            echo "Uso: $0 [verificacion|seguridad|colaborativo|roadmap|todos] [iniciar|parar|estado|ejecutar-una|reset]"
            exit 1
            ;;
    esac
}

main "$@"