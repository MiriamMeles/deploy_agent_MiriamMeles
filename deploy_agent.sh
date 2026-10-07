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

        echo "Choose roster setup:"
    echo "  A) Copy from templates/assets.csv"
    echo "  B) Generate a fresh roster"
    local option
    while true; do
	    read -r -p "Select an option A or B: " option
	   case "${option^^}" in
            A) template_roster; break ;;
            B) generate_roster; break ;;
            *) echo "Please type A or B." ;;
        esac
    done
 
    chmod +x "$PROJECT_DIR/attendance_checker.py" &&
    chmod 600 "$PROJECT_DIR/Helpers/config.json" ||
        die "Setting permissions FAILED."

    echo "Permissions SET:"
    ls -l "$PROJECT_DIR/attendance_checker.py" "$PROJECT_DIR/Helpers/config.json"

    update_thresholds

    echo "$PROJECT_DIRECTORY with Helpers/ and reports/ CREATED"

    echo "Verifying deployment by launching the application..."
    run_in_project "$PROJECT_DIR"

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

SAMPLE_NAMES=("Tedros Hawi" "Michael Omondi" "Arnold Geneva" "Derrick Opiyo" "Yorda Tekleab")
SAMPLE_EMAILS=("tedros@example.com" "michael@example.com" "arnold@example.com" "derrick@example.com"
               "yorda@example.com")

generate_roster() {
    local max=${#SAMPLE_NAMES[@]} count i

    while true; do
        read -r -p "How many students should be generated (1-$max)? " count

        if [[ "$count" =~ ^[0-9]+$ ]] &&
	[ "$count" -ge 1 ] &&
       	[ "$count" -le "$max" ]; then
            break
        fi

        echo "Enter a whole number between 1 and $max."
    done

    {
        echo "Email,Names,Attendance Count,Absence Count"

        for ((i = 0; i < count; i++)); do
            echo "${SAMPLE_EMAILS[$i]},${SAMPLE_NAMES[$i]},0,0"
        done
    } > "$PROJECT_DIR/Helpers/assets.csv" ||
	 die "Creating new roster FAILED."

        sed -i.bak -E \
        's/("total_sessions":[[:space:]]*)[0-9]+/\11/' \
        "$PROJECT_DIR/Helpers/config.json" ||
        die "Updating total_sessions FAILED."

    rm -f "$PROJECT_DIR/Helpers/config.json.bak"
    echo "Generated $count students (0/0 counts), so total_sessions set to 1."
}

read_threshold() {
    local label="$1"
    local default="$2" input

    while true; do
        read -r -p "New $label threshold [default $default]: " input

        input="${input:-$default}"

        if [[ "$input" =~ ^[0-9]+$ ]] && [ "$input" -le 100 ]; then
            echo "$input"
            return
        fi

        echo "Incorect input. Please enter a whole number between 0 and 100." >&2
    done
}

    update_thresholds() {
    local answer
    local warning
    local failure
    local config="$PROJECT_DIR/Helpers/config.json"

    read -r -p "Would you like to update attendance alert thresholds? (y/N): " answer

    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
	 echo "Default thresholds will be kept."
	 return
    fi
    while true; do
        warning=$(read_threshold "warning" 75)
        failure=$(read_threshold "failure" 50)

        if [ "$failure" -lt "$warning" ]; then
	    break
	fi

        echo "Failure threshold must be lower than the warning threshold."
    done

    sed -i.bak -E \
        -e "s/(\"warning\":[[:space:]]*)[0-9]+/\1${warning}/" \
        -e "s/(\"failure\":[[:space:]]*)[0-9]+/\1${failure}/" \
        "$config" || die "Updating attendance thresholds FAILED."

    rm -f "$config.bak"

    echo "Thresholds UPDATED: warning=$warning failure=$failure"
    grep -E '"(warning|failure)"' "$config"

}

run_in_project() {
    local dir="$1"
    [ -d "$dir" ] || die "Project '$dir' not found. Deploy it first."
    [ -f "$dir/attendance_checker.py" ] || die "'$dir' is not a valid deployment."
    ( cd "$dir" && python3 attendance_checker.py )
}

deploy_project
