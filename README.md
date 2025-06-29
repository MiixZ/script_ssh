# Auto-Launch an SSH Session on Windows 11

This guide shows how to make Windows 11 open a PowerShell window and run

```powershell
ssh <ip-target>
```

every time the computer boots, without hard-coding the target IP in the script.
The IP (or hostname) is stored in a persistent environment variable and the script is triggered by a Scheduled Task, which is more reliable than the classic Startup folder. An ip can commonly be (on a remote server): 'user@ip'. It has 8 simple steps

## 0: Prerequisites

| Component          | Status on Windows 11  | Notes                                                              |
| ------------------ | --------------------- | ------------------------------------------------------------------ |
| OpenSSH Client     | Usually pre-installed | ssh.exe must be in %PATH%.                                         |
| PowerShell 7+      | Recommended           | The script runs fine on Windows PowerShell 5.1 too.                |
| Local admin rights | Required once         | To set the environment variable and create the Scheduled Task.too. |

## 1: Define Environment Variable

### By UI

- Press Win + I → System → About → Advanced system settings.
- Click Environment Variables… (bottom right).
- Under User variables click New…
  - Variable name: SSH_TARGET
  - Variable value: Any host u need (user@ip)
- OK → OK → Close Settings.

### 2: PowerShell method (persistent)

```powershell
[Environment]::SetEnvironmentVariable(
  'SSH_TARGET',
  'user@ip',
  'User'
)
```

Log out or open a new terminal and verify:

```powershell
PS> echo $Env:SSH_TARGET
```

## 3: Create a new PowerShell Script

Create a new script whenever you want (for example C:\Scripts\Connect-SSH.ps1)

```powershell
$target = $Env:SSH_TARGET
if (-not $target) {
  Write-Error "Environment variable SSH_TARGET is not set."
  exit 1
}

Start-Process pwsh -ArgumentList @(
  '-NoExit',
  '-Command', "ssh $target"
)
```

## 4: Allow Scripts to Run

If your system blocks scripts, set a less restrictive policy once:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**RemoteSigned** is generally safe for local scripts.

## 5: Create the scheduled task

- Press Win + S, search for Task Scheduled, right-click --> Run as administrator.
- In the right pane choose **Create Task**... (not Basic Task)

| Tab      | Setting          | Value                                                                                    |
| -------- | ---------------- | ---------------------------------------------------------------------------------------- |
| General  | Name             | Open SSH Session                                                                         |
|          | Description      | As you prefer.                                                                           |
|          | Security options | Run only when user is logged on (or whatever you want)                                   |
| Triggers | New…             | Begin the task: At log on                                                                |
| Actions  | New…             | Action: Start a program                                                                  |
|          |                  | Program/Script: powershell.exe                                                           |
|          |                  | Add arguments: -ExecutionPolicy Bypass -File "C:\Scripts\Connect-SSH.ps1" (or your rute) |
| Settings | --               | Keep the defaults or adjust as needed.                                                   |

- Click OK, enter your password if prompted.

## 6: Test It

- Right-click the task → Run → A new PowerShell window should appear and immediately try to connect via ssh <target>.
- Reboot or sign out/in to confirm the automatic launch.

## 7: Troubleshooting

| Symptom                                       | Fix                                                                                                  |
| --------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| “Environment variable SSH_TARGET is not set.” | Make sure the variable exists for the account that runs the task. Re-log after creating it.          |
| PowerShell window flashes and closes          | Remove -NoExit temporarily, or add Pause to see the error.                                           |
| Task never fires                              | Check the History tab in Task Scheduler. Make sure the trigger is At log on and the task is Enabled. |
| “Scripts disabled on this system”             | Adjust Execution Policy (Section 4).                                                                 |

## 8: (optional) Remove/Disable

- To stop auto-launching, simply disable or delete the task in Task Scheduler.
- Remove the environment variable with:

```powershell
[Environment]::SetEnvironmentVariable('SSH_TARGET', $null, 'User')
```

Enjoy hands-free SSH logins every time Windows 11 starts!

## Recommended

If you are interested and like to customize your own shell in Windows, I invite you to check my 'personal' branch where I use WindowsTerminal instead of PS, with a customizable profile that I have previously built. For more information, you can also visit this [public guide](https://freshman.tech/windows-terminal-guide/).
