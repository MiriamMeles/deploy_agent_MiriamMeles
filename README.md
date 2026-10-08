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
