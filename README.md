# 3-iX-WSL-CC

[![IXSYSTEMS INC.](https://codeberg.org/arpatek/3-iX-WSL-CC/raw/branch/main/IMAGES/iX_Logo.png)](https://www.ixsystems.com/)

## _Automation Scripts for TrueNAS Systems & Custom Servers_

> **Archived** — This suite was purpose-built for iXsystems' internal production environment and is no longer maintained. Internal hostnames, IPs, and credentials have been replaced with placeholders (e.g. `<PBS_ARCHIVE_HOST>`, `<DB_HOST>`, `<TRUENAS_ROOT_PASSWORD>`).

These scripts were used for Client Configuration (CC) and Software Quality Control (SWQC) to configure and validate system configuration based on iX Redbooks & customer needs.

- Automating Redbook qualified configuration
- Allowed for increased throughput without additional personnel
- Log and archive configuration results
- Gather system information & debug files to automate the SWQC process

## Features

- Multi-script menu driven by `dialog` TUI
- WSL-based — works on any Windows system running [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/about)
- Batch configuration via _KEY.txt_ input file
- Supermicro Update Manager ([SUM](https://www.supermicro.com/en/solutions/management-software/supermicro-update-manager)) integration for batch BIOS configuration & [OOB/DCMS](https://store.supermicro.com/us_en/software/software-license-key-activation-usage) license activation
- Error checking and pass/fail validation logic
- GOLD file diffing — first unit in KEY.txt becomes the baseline; all others are diffed against it for configuration consistency

## Dependencies

The following must be installed on the WSL Ubuntu VM:

- [IPMITOOL](https://linux.die.net/man/1/ipmitool) — Utility for controlling IPMI-enabled devices
- [SSHPASS](https://linux.die.net/man/1/sshpass) — Non-interactive SSH password provider
- [PV](https://linux.die.net/man/1/pv) — Monitor the progress of data through a pipe
- [POSTGRESQL-CLIENT](https://ubuntu.com/server/docs/databases-postgresql) — PostgreSQL client for querying the internal STD parts database
- [SQLITE3](https://linux.die.net/man/1/sqlite3) — SQLite3 command line interface
- [PYTHON3](https://www.python.org/downloads/) — Required for Redfish BIOS scripts
- [PDFGREP](https://pdfgrep.org/) — Search text in PDF files (used for work order scanning)
- [LYNX](https://linux.die.net/man/1/lynx) — Text-mode browser used to parse PBS log HTML
- [CURL](https://linux.die.net/man/1/curl) — Transfer URLs
- [GIT](https://linux.die.net/man/1/git) — Version control
- [ZSH](https://linux.die.net/man/1/zsh) — Z shell

## Setup

[WSL](https://learn.microsoft.com/en-us/windows/wsl/install) must be installed on any Windows PC.

Open a PowerShell prompt (Run as Administrator) and type:
```powershell
wsl --install
```

Once your Ubuntu user is set up, update repositories:
```bash
sudo apt-get update && sudo apt-get full-upgrade -y
```

Install required dependencies:
```bash
sudo apt install ipmitool sshpass pv postgresql-client sqlite3 python3 dialog pdfgrep lynx curl git zsh -y
```

Install [oh-my-zsh](https://ohmyz.sh/):
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Copy the custom theme:
```bash
cp ~/3-iX-WSL-CC/SETUP/3eyedgod.zsh-theme ~/.oh-my-zsh/themes/
```

Set the theme in `.zshrc`:
```bash
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="3eyedgod"/g' ~/.zshrc
```

Add aliases to `.zshrc`:
```zsh
alias ixcc="cd ~/3-iX-WSL-CC;./3-iX-CC.sh"
alias 1up="sudo hwclock -s && sudo apt-get update && sudo apt-get full-upgrade -y && sudo apt-get autoremove -y"
alias sums="cd ~/3-iX-WSL-CC/SUMS/"
alias oob="./sum -l OOB-LIC.txt -c ActivateProductKey"
alias dcms="./sum -l DCMS-LIC.txt -c ActivateProductKey"
```

## License

MIT — see [LICENSE](LICENSE)
