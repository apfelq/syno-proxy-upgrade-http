# SynoProxyUpgradeHttp

This script sets up static client IPs when using OpenVPN of `VPN Server` package.

#### 1. Notes

- The script is able to automatically update itself using `git`.

#### 2. Installation

##### 2.1 Install Git (optional)

- install the package `Git Server` on your Synology NAS, make sure it is running (requires sometimes extra action in `Package Center` and `SSH` running)
- alternatively add SynoCommunity to `Package Center` and install the `Git` package ([https://synocommunity.com/](https://synocommunity.com/#easy-install))
- you can also use `entware` (<https://github.com/Entware/Entware>)

##### 2.2 Install this script (using git)

- create a shared folder e. g. `sysadmin` (you want to restrict access to administrators and hide it in the network)
- connect via `ssh` to the NAS and execute the following commands

```bash
# navigate to the shared folder
cd /volume1/sysadmin
# clone the following repo
git clone https://github.com/apfelq/syno-proxy-upgrade-http
# to enable autoupdate
touch syno-proxy-upgrade-http/autoupdate
```

##### 2.3 Install this script (manually)

- create a shared folder e. g. `sysadmin` (you want to restrict access to administrators and hide it in the network)
- copy your `synoProxyUpgradeHttp.sh` to `sysadmin` using e. g. `File Station` or `scp`
- make the script executable by connecting via `ssh` to the NAS and executing the following command

```bash
chmod 755 /volume1/syno-proxy-upgrade-http/synoProxyUpgradeHttp.sh
```

#### 3. Setup

##### 3.1 Create Reverse Proxy

- On your DiskStation go to `Control Panel > Application Portal > Reverse Proxy`
- Add an entry for HTTP (the values in `Destination` are irrelevant)
- Under `Custom Header` add this:

    - `Header Name`: `Content-Security-Policy`
    - `Value`: `upgrade-insecure-requests`
    
    (The script will look for this custom header and add a redirect to HTTPS)

##### 3.2 Execute Script

- run script manually (as root)

```bash
/volume1/sysadmin/syno-proxy-upgrade-http/synoProxyUpgradeHttp.sh
```

*AND/OR*

- create a task in the `Task Scheduler` via WebGUI

```
# Type
Scheduled task > User-defined script

# General
Task:    SynoProxyUpgradeHttp
User:    root
Enabled: yes

# Schedule
Run on the following days: Daily
First run time:            00:00
Frequency:                 Every 1 hour(s)
Last run time:			   23:00

# Task Settings
User-defined script: /volume1/sysadmin/syno-proxy-upgrade-http/synoProxyUpgradeHttp.sh
```
