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
