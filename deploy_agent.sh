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

    template_roster

    echo "$PROJECT_DIR with Helpers/ and reports/ CREATED"
}

template_roster() {
    local students count

   students=$(( $(grep -c '' "$TEMPLATES_DIR/assets.csv") - 1 ))

   while true; do
        read -r -p "Number of studets to be copied (1-$students)? " count
        if [[ "$count" =~ ^[0-9]+$ ]] && [ "$count" -ge 1 ] && [ "$count" -le "$students" ]; then
            break
        fi

        echo "Please enter a whole number between 1 and $students."
    done

    head -n $((count + 1)) \
	    "$TEMPLATES_DIR/assets.csv" \
	    > "$PROJECT_DIR/Helpers/assets.csv" ||
            die "Failed to write roster."

    echo "Copied $count students (4 prior sessions each), so total_sessions stays 5."
}
deploy_project
