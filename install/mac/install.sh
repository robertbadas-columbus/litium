#!/bin/bash
# . ~/.profile
# . ~/.bashrc
. ~/.nvm/nvm.sh

set -u

# Variables
desktop_path="$HOME/Desktop"
project_name="LitiumTutorial"
database_name="LitiumTutorial"
docker_dir="${desktop_path}/${project_name}/docker"
backend_dir="${desktop_path}/${project_name}/backend"
headless_dir="${desktop_path}/${project_name}/headless"
node_version="20"


# Cleanup when close signal
cleanup() {
    # Our cleanup code goes here
    for job in $(jobs -p); do
        kill -s SIGTERM $job >/dev/null 2>&1 || (sleep 10 && kill -9 $job >/dev/null 2>&1 &)
    done
    exit 1
}
trap 'trap " " SIGTERM; kill 0; wait; cleanup' SIGINT SIGTERM
sleep 30 &
sleep 40 &

# String formatters
if [[ -t 1 ]]; then
    tty_escape() { printf "\033[%sm" "$1"; }
else
    tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_green="$(tty_mkbold 32)"
tty_yellow="$(tty_mkbold 33)"
tty_grey="$(tty_mkbold 30)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

shell_join() {
    local arg
    printf "%s" "$1"
    shift
    for arg in "$@"; do
        printf " "
        printf "%s" "${arg// /\ }"
    done
}

chomp() {
    printf "%s" "${1/"$'\n'"/}"
}

pro() {
    printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

inf() {
    printf "${tty_grey}===>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

ok() {
    printf "${tty_green}$1${tty_reset} %s\n" "$(chomp "${2:-}")" >&2
}

warn() {
    printf "${tty_yellow}$1${tty_reset} %s\n" "$(chomp "${2:-}")" >&2
}

err() {
    printf "${tty_red}$1${tty_reset} %s\n" "$(chomp "${2:-}")" >&2
}

check_node_version() {
    local version=$1
    # Check if the Node.js version is already installed
    if ! nvm ls $version | grep -q "$version"; then
        err "Error: Node.js version $version is not found. Install it using:" "nvm install $version"
        exit 1
    fi
}

# Check if project folder exists
if [ -d "$desktop_path/$project_name" ]; then
    err "Error: Folder already exists. Aborting."
    err "$desktop_path/$project_name"
    exit 1
fi

# Check dependencies
dependencies=("dotnet" "docker-compose" "nvm")
for cmd in "${dependencies[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        err "Error: $cmd is not installed"
        exit 1
    fi
done
check_node_version $node_version

  
# Open Docker, only if is not running
if ! curl -s --unix-socket /var/run/docker.sock http/_ping 2>&1 >/dev/null; then
  warn "Starting Docker, please wait..."
  open /Applications/Docker.app
  sleep 1
fi

while true; do
  if curl -s --unix-socket /var/run/docker.sock http/_ping 2>&1 >/dev/null; then
    break
  fi
  sleep 1
done


# Start creating the project
# Create folder structers
mkdir -p "$docker_dir" "$backend_dir" "$headless_dir"

# Download docker-compose.yml
curl -L https://raw.githubusercontent.com/robertbadas-columbus/litium/main/install/mac/docker-compose.yml -o $docker_dir/docker-compose.yml

# Create litium project including storefront-api
cd $backend_dir && dotnet new litmvcacc --storefront-api
cd $headless_dir && dotnet new litreactacc &&


# Create folder Propterties and create launchSettings.json in that folder
mkdir -p "$backend_dir/Src/Litium.Accelerator.Mvc/Properties"
echo '{
    "profiles": {
      "Litium.Accelerator.Mvc": {
        "commandName": "Project",
        "launchBrowser": true,
        "environmentVariables": {
          "ASPNETCORE_ENVIRONMENT": "Development"
        },
        "applicationUrl": "https://localhost:5001;http://localhost:5000"
      }
    }
}' >"$backend_dir/Src/Litium.Accelerator.Mvc/Properties/launchSettings.json"

# Create file Litium.Accelerator.Mvc/appsettings.Development.json
echo '// Copy the elements from appsettings.json into this file for the settings you want to override
// that are common for developer configuration.
//
// For developer specific settings the "User secrets" should be used, see
// https://docs.microsoft.com/en-us/aspnet/core/security/app-secrets#manage-user-secrets-with-visual-studio
//
// Remember to set the environment variable ASPNETCORE_ENVIRONMENT with value "Development", example for web.config
// <environmentVariable name="ASPNETCORE_ENVIRONMENT" value="Development" />
{
  "Litium": {
    "Data": {
      "ConnectionString": "Pooling=true;User Id=sa;Password=Pass@word;Database='${database_name}';Server=127.0.0.1,5434;TrustServerCertificate=True",
      "EnableSensitiveDataLogging": false
    },
    "Folder": {
      "Local": "../../files",
      "Shared": null
    },
    "Elasticsearch": {
      "ConnectionString": "http://127.0.0.1:9200",
      "Username": null,
      "Password": null,
      "Prefix": "StorefrontV1",
      "Synonym": {
        "Server": null,
        "ApiKey": null
      }
    },
    "Redis": {
      "Prefix": "StorefrontV2",
      "Cache": {
        //"ConnectionString": "127.0.0.1:6379",
        "ConnectionString": null,
        "Password": null
      },
      "DistributedLock": {
        "ConnectionString": null,
        "Password": null
      },
      "ServiceBus": {
        "ConnectionString": null,
        "Password": null
      }
    },
    "Websites": {
      "Storefronts": {
        "headless-accelerator": {
          "host": "https://localhost:3001"
        }
      }
    }
  }
}' > "${backend_dir}/Src/Litium.Accelerator.Mvc/appsettings.Development.json"

# Create file env.local for the headless folder
echo '# The domain name for you Litium platform installation.
RUNTIME_LITIUM_SERVER_URL=https://localhost:5001
# If you using self-signed certificate for the Litium platform
# you may also need to add the following line to turn off certificate validation.
NODE_TLS_REJECT_UNAUTHORIZED="0"
' >"$headless_dir/.env.local"

# Yarn install on all folders
nvm install $node_version && nvm use $node_version && npm install -g yarn
cd $backend_dir/Src && yarn install && yarn build
cd $backend_dir/Src/Litium.Accelerator.Mvc && yarn install
cd $backend_dir/Src/Litium.Accelerator.Email && yarn install
cd $headless_dir && yarn install

# Start docker using docker-compose.yml
cd $docker_dir && docker-compose up -d

# Wait for connection to SQL server
warn "Waiting for connection to the SQL server."
while ! docker exec docker-sqlserver-1 /opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U sa -P 'Pass@word' -q "SELECT 1" >/dev/null 2>&1; do sleep 4; done

# SQL Connection established.
# Create database using docker
docker exec docker-sqlserver-1 /opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U sa -P 'Pass@word' -q "CREATE DATABASE ${database_name}"

# Update database with records and add a user
cd $backend_dir &&
dotnet litium-db update --connection "Pooling=true;User Id=sa;Password=Pass@word;Database=${database_name};Server=127.0.0.1,5434;TrustServerCertificate=True"
dotnet litium-db user --connection "Pooling=true;User Id=sa;Password=Pass@word;Database=${database_name};Server=127.0.0.1,5434;TrustServerCertificate=True" --login admin --password nimda

# Start .NET server
warn "Starting server. Please wait."
cd $backend_dir/Src/Litium.Accelerator.Mvc
dotnet run &

# Waiting for the .NET server to complete its process.
while true; do
    if [[ $(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/Litium) == "302" ]]; then
        sleep 1
        break
    fi
done
sleep 2

# Start litium-storefront proxy if its not allready running
if ! nc -zv 127.0.0.1 3001 &>/dev/null; then
    ~/.dotnet/tools/litium-storefront proxy --litium https://localhost:5001 --storefront http://localhost:3000 &
fi

# Import headless definitions
cd $headless_dir &&
~/.dotnet/tools/litium-storefront definition import --file "${headless_dir}/litium-definitions/**/*.yaml" --litium https://localhost:5001 --litium-username admin --litium-password nimda

# Export headless translations
~/.dotnet/tools/litium-storefront text convert-to-excel -i './litium-definitions/texts/*.yaml' -f './litium-definitions/texts/xls/texts.xlsx'

# Start headless
nvm use $node_version
yarn dev