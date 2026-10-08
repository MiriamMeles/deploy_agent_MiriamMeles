
# deploy_agent

`deploy_agent.sh` deploys, runs and archives logs for the Student Attendance Tracker (`attendance_checker.py`, unmodified).

## Requirements
bash, python3 and zip. The script checks that python3 and zip are installed before deploying.

## How to run
```bash
chmod +x deploy_agent.sh
./deploy_agent.sh            # interactive menu
./deploy_agent.sh deploy     # or: run | archive
```

The menu has four options: 1) Deploy, 2) Start the application, 3) Archive log files, 4) Exit.
