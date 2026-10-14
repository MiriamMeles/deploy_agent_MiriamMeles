# Student Attendance Tracker: Deploy Agent
### By Miriam Meles (MiriamMeles)

`deploy_agent.sh` is a shell script that builds a complete Student Attendance Tracker workspace for you. It creates the folders, copies the files, builds the class roster, locks down the config file, lets you change the alert thresholds, runs the app, archives its logs, and cleans up safely if you interrupt it.

---

## How to Run the Script

**Step 1: Open your terminal and go to the project folder:**
```bash
cd ~/deploy_agent_MiriamMeles
```

**Step 2: Make the script executable (only needed once):**
```bash
chmod +x deploy_agent.sh
```

**Step 3: Start it:**
```bash
./deploy_agent.sh
```

**Step 4: Choose a feature from the menu:**
```
=== Attendance Tracker ===
1) Deploy the application
2) Start the application
3) Archive log files
4) Exit
```

You can also skip the menu with a flag:
```bash
./deploy_agent.sh deploy
./deploy_agent.sh run
./deploy_agent.sh archive
```

**Requirements:** bash, python3 and zip. The script checks for python3 and zip first and stops with a clear message if either is missing.

---

## Ctrl+C and Ctrl+Z During Deployment

While a project is being created, the script traps **Ctrl+C** (SIGINT) and **Ctrl+Z** (SIGTSTP). If you press either one mid-deploy, it will not leave a half-made folder behind. Instead it:

1. prints a message that the deployment was interrupted,
2. zips whatever exists so far into `attendance_tracker_<name>_archive.zip`,
3. deletes the incomplete project folder,
4. closes the session cleanly.

The trap is only active while the project is being built. It is switched off before the app launches, so it never interferes with a marking session.

### How to Test It

**Step 1: Start a deployment:**
```bash
./deploy_agent.sh
```

**Step 2: Choose `1`, enter a name such as `trap1`, and choose `A`.**

**Step 3: At the "Number of students to be copied" prompt, press Ctrl+C** (or Ctrl+Z).

You will see:
```
!! Deployment interrupted by user.
-> Archiving incomplete project into attendance_tracker_trap1_archive.zip ...
-> Archive created: attendance_tracker_trap1_archive.zip
-> Removing incomplete directory attendance_tracker_trap1 ...
Session closed cleanly.
```

**Step 4: Confirm it worked:**
```bash
ls
```
The zip file is there and the `attendance_tracker_trap1` folder is gone.

**Step 5: Look inside the archive without extracting it:**
```bash
unzip -l attendance_tracker_trap1_archive.zip
```

### What the .zip Contains

Whatever had been created at the moment of the interrupt:
```
attendance_tracker_trap1/
attendance_tracker_trap1/Helpers/
attendance_tracker_trap1/Helpers/config.json
attendance_tracker_trap1/reports/
attendance_tracker_trap1/attendance_checker.py
```

If you press Ctrl+C before anything has been created (for example at the name prompt), there is nothing to archive and the script just exits cleanly.

---

## Project Folder Structure After Running

**The repository:**
```
deploy_agent_MiriamMeles/
├── deploy_agent.sh
├── README.md
├── .gitignore
└── templates/
    ├── attendance_checker.py
    ├── assets.csv
    └── config.json
```

**A deployed project** (for example, after choosing Deploy and naming it `v1`):
```
attendance_tracker_v1/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
```

**After the app has run** (the app creates the two logs itself):
```
attendance_tracker_v1/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    ├── attendance.log
    └── absent.log
```

**After archiving the logs** (each log goes into its own folder with a timestamp in the name):
```
attendance_tracker_v1/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
├── reports/
│   ├── attendance.log
│   └── absent.log
└── archives/
    ├── attendance/
    │   └── attendance_YYYYMMDD_HHMMSS.log
    └── absent/
        └── absent_YYYYMMDD_HHMMSS.log
```

If nobody was marked absent, `absent.log` is never created, so only the `attendance/` archive appears and the script reports that `absent.log` was skipped.

### How the Structure Was Tested
After each deployment I ran:
```bash
find attendance_tracker_v1 | sort
```
and compared the output with the required structure from the assignment.


## How Deploy Works

Choosing **Deploy** runs these steps in order:

1. **Pre-flight checks:** confirms `python3` and `zip` are installed and prints the Python version. If either is missing, the script stops with a clear error.
2. **Project name:** asks for a name (letters, digits, `_` and `-` only) and builds `attendance_tracker_<name>/`. If that folder already exists, you choose to overwrite it or abort. Nothing is overwritten silently.
3. **Structure and files:** creates `Helpers/` and `reports/`, then copies `attendance_checker.py` and `config.json` unmodified from `templates/`.
4. **Roster:** you choose how `Helpers/assets.csv` is built (see below).
5. **Permissions:** `attendance_checker.py` is made executable (`chmod +x`) and `Helpers/config.json` is restricted to owner read/write (`chmod 600`). The script prints the result with `ls -l`.
6. **Thresholds:** offers to update the alert thresholds (see below).
7. **Verify:** launches the app. A successful start shows that the structure, roster and config work together.


### Roster Options
- **Option A, copy from the template:** asks how many students (1 to 10) and copies that many rows plus the header from `templates/assets.csv`. Each sample student has 4 prior sessions recorded.
- **Option B, generate a fresh roster:** asks how many students (1 to 5) and builds the rows from sample name and email arrays inside the script. Attendance and absence counts start at 0.

Both prompts reject anything that is not a whole number in range.

### Why `total_sessions` Changes
`total_sessions` in `config.json` is the number of prior sessions in the roster plus one (today's session).
- Option A has 4 prior sessions, so `total_sessions` stays **5**.
- Option B has no prior sessions, so the script sets `total_sessions` to **1** using `sed`.

### Updating the Alert Thresholds
The script asks whether you want to change the attendance alert thresholds. If you answer yes:
1. It asks for a **warning** value (default 75) and a **failure** value (default 50). Pressing Enter keeps the default.
2. Each value must be a whole number from 0 to 100, and failure must be lower than warning. Otherwise you are asked again, so `sed` never receives bad input.
3. `sed` then edits only the number on the `"warning"` and `"failure"` lines of `Helpers/config.json`. The file is not reformatted or reordered.


## Running the Application

Choose **Start the application** from the menu (or run `./deploy_agent.sh run`), then enter the project name. The script runs `python3 attendance_checker.py` inside that project. The app asks you to mark each student present (`P`) or absent (`A`), updates `Helpers/assets.csv`, and writes the session logs into `reports/`.

---

## Archiving the Log Files

After a run, choose **Archive log files** (or run `./deploy_agent.sh archive`) and enter the project name.

- `reports/attendance.log` is copied to `archives/attendance/attendance_YYYYMMDD_HHMMSS.log`
- `reports/absent.log` is copied to `archives/absent/absent_YYYYMMDD_HHMMSS.log`

The timestamp makes every archived copy unique and traceable. The script prints which logs were archived and their final paths. If a log does not exist (for example, nobody was absent, so `absent.log` was never created), the script reports that it was skipped and carries on without crashing. The original logs stay in `reports/`.

---
## Video to Explain How the Code Works
https://drive.google.com/drive/u/0/my-drive
