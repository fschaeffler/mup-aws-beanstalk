#!/bin/bash

# When nvm is installed, $HOME isn't set
# resulting in nvm installed /.nvm
export NVM_DIR="/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" >/dev/null 2>&1

nvm use default --delete-prefix --silent

# Check for currently available RAM size
RAM_SIZE=$(free | awk '/^Mem:/{print $2}')
RAM_SIZE_MB=$(echo $(($RAM_SIZE / 1024)))

# Calculate node-process RAM size
half_ram_size=$(echo $(($RAM_SIZE_MB / 2)))
NODE_RAM_SIZE="1024"
if [[ $half_ram_size -le "1024" ]]; then
	NODE_RAM_SIZE="1024"
elif [[ $half_ram_size -le "2048" ]]; then
	NODE_RAM_SIZE="2084"
elif [[ $half_ram_size -le "4096" ]]; then
	NODE_RAM_SIZE="4096"
elif [[ $half_ram_size -le "8192" ]]; then
	NODE_RAM_SIZE="8192"
fi

echo "Node version"
echo $(node --version)
echo "Npm version"
echo $(npm --version)
echo "RAM size"
echo "$RAM_SIZE_MB Mb"
echo "RAM size for node-process"
echo $NODE_RAM_SIZE

export METEOR_SETTINGS=$(node -e 'console.log(decodeURIComponent(process.env.METEOR_SETTINGS_ENCODED))')

echo "=> Starting health check server"
node health-check.js 'start' &

echo "=> Starting App"
node --max-old-space-size=$NODE_RAM_SIZE --max_old_space_size=$NODE_RAM_SIZE main.js
