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
    read -r -p "Enter project name (attendance_tracker_<name>): " project_name
    [[ "$project_name" =~ ^[A-Za-z0-9_-]+$ ]] || die "Use only letters, digits, '_' or '-'."
    PROJECT_DIR="attendance_tracker_${project_name}"
}

deploy_project() {
    preflight_checks
    ask_project_name
        if [ -e "$PROJECT_DIR" ]; then
        local answer

        read -r -p "'$PROJECT_DIR' already exists. Overwrite? (y/n): " answer
        [[ "$answer" =~ ^[Yy]$ ]] ||
	       	die "Aborted: '$PROJECT_DIR'  exists and was not modified."
        rm -rf "$PROJECT_DIR" || 
		die "Unable to remove existing '$PROJECT_DIR'."
    fi
        mkdir -p "$PROJECT_DIR/Helpers" "$PROJECT_DIR/reports" ||
        die "Creating directories FAILED."

    cp "$TEMPLATES_DIR/attendance_checker.py" "$PROJECT_DIR/" ||
	die "Copying attendance_checker.py FAILED"

    cp "$TEMPLATES_DIR/config.json" "$PROJECT_DIR/Helpers/" ||
        die "Copying config.json FAILED."

    echo "$PROJECT_DIR with Helpers/ and reports/ CREATED"
}

deploy_project
