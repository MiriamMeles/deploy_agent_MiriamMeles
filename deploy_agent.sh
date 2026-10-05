#!/usr/bin/bash
# deploy_agent.sh - deploy, run and archive the Attendance Tracker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

cd "$SCRIPT_DIR" || exit 1

die() {
    echo "EROR: $*" >&2
    exit 1
}

preflight_checks() {
    local missing=0
    local tool

    for tool in python3 zip
    do    
        if ! command -v "$tool" >/dev/null 2>&1
	then
            echo "ERROR: '$tool' missing." >&2
            missing=1
        fi
    done
    [ "$missing" -eq 0 ] || die "Install the missing tool and try again."
    echo "Pre-flight installed: $(python3 --version)"
}

PROJECT_DIR=""

ask_project_name() {
    local project_name
    read -r -p "Project name (attendance_tracker_<name>): " project_name
    [[ "$project_name" =~ ^[A-Za-z0-9_-]+$ ]] || die "Name must use only letters, digits, '_' or '-'."
    PROJECT_DIR="attendance_tracker_${name}"
}

deploy_project() {
    preflight_checks
    ask_project_name
    echo "Using project directory: $PROJECT_DIR"
}

deploy_project
