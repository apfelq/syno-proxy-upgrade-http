#!/bin/bash

# check if run as root
if [ $(id -u "$(whoami)") -ne 0 ]; then
	echo "SynoProxyUpgradeHttp needs to run as root!"
	exit 1
fi

# check if git is available
if command -v /usr/bin/git > /dev/null; then
	git="/usr/bin/git"
elif command -v /usr/local/git/bin/git > /dev/null; then
	git="/usr/local/git/bin/git"
elif command -v /opt/bin/git > /dev/null; then
	git="/opt/bin/git"
else
	echo "Git not found therefore no autoupdate. Please install the official package \"Git Server\", SynoCommunity's \"git\" or Entware's."
	git=""
fi

# save today's date
today=$(date +'%Y-%m-%d')

# self update run once daily
if [ ! -z "${git}" ] && [ -d "$(dirname "$0")/.git" ] && [ -f "$(dirname "$0")/autoupdate" ]; then
	if [ ! -f /tmp/.synoProxyUpgradeHttpUpdate ] || [ "${today}" != "$(date -r /tmp/.synoProxyUpgradeHttpUpdate +'%Y-%m-%d')" ]; then
		echo "Checking for updates..."
		# touch file to indicate update has run once
		touch /tmp/.synoProxyUpgradeHttpUpdate
		# change dir and update via git
		cd "$(dirname "$0")" || exit 1
		$git fetch
		commits=$($git rev-list HEAD...origin/master --count)
		if [ $commits -gt 0 ]; then
			echo "Found a new version, updating..."
			$git pull --force
			echo "Executing new version..."``
			exec "$(pwd -P)/synoProxyUpgradeHttp.sh" "$@"
			# In case executing new fails
			echo "Executing new version failed."
			exit 1
		fi
		echo "No updates available."
	else
		echo "Already checked for updates today."
	fi
fi

# Save if service restart is needed
nginxReload=0

# Check if we need to add upgrade
if grep -Eq '^ +proxy_set_header +Content-Security-Policy +upgrade-insecure-requests;$' /etc/nginx/app.d/server.ReverseProxy.conf; then
	sed -Ei 's|(^ +proxy_set_header +Content-Security-Policy +upgrade-insecure-requests;$)|\1 return 301 https://$host$request_uri;|g' /etc/nginx/app.d/server.ReverseProxy.conf
	echo "nginx proxy config modified."
	((nginxReload++))
else
	echo "nginx proxy config untouched."
fi

# Restart service if needed
if [ $nginxReload -gt 0 ]; then
	/usr/bin/nginx -s reload
	echo "Reloaded nginx."
fi

exit 0