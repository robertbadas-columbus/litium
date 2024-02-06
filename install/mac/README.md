# Litium 8 installation on Mac - MVC Accelerator & React Headless

This repository provides step-by-step instructions for installing Litium 8 on a Mac with ARM architecture, utilizing the Sonoma OS. Follow the guidelines in this documentation for a seamless installation process.

<pre>
<b>Litium versions used for this tutorial</b>
- Litium.Storefront.Cli 1.0.0-rc-03
- Litium.Accelerator.React.Templates 1.0.0-rc-02
- Litium.Accelerator.Templates 8.13.1
</pre>


## 📐 Usage
- Install dependencies
- Configure Litium 8
- Create new litium project

### Dependencies list

  - Litium Docs account https://docs.litium.com/system_pages/createlitiumaccount
  - Brew
  - .NET SDK version 8 and 7
  - Docker
  - nvm *(Used to install and use multiple node versions. Litium needs node 18.17.0)*
  - yarn


## ⚙️ Install dependencies
### Litium Docs account
Create the account using your work email address.
```
https://docs.litium.com/system_pages/createlitiumaccount
```

### Brew
If you haven't installed Homebrew, execute the following code in the terminal:
```sh
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else;
    echo -e "\033[1;33mHombrew is already installed\033[0m"
fi
```

### NVM
If you haven't installed nvm, execute the following code in the terminal.
```sh
brew install nvm &&
mkdir ~/.nvm &&
echo -e '\nexport NVM_DIR="$HOME/.nvm"\n[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm\n[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion' >> ~/.zprofile && source ~/.zprofile
nvm install 18.17.0 && npm i -g yarn &&
```

### Docker
If you haven't installed Docker, follow the link below.
<pre>
<a href="https://www.docker.com">https://www.docker.com</a>
</pre>

### .NET
If you haven't installed .NET SDK versions 7 and 8, follow the links below.<br>It's crucial to select the download from the "Build apps - SDK" section and the options macOS Arm64.
<pre>
<a href="https://dotnet.microsoft.com/en-us/download/dotnet/8.0">https://dotnet.microsoft.com/en-us/download/dotnet/8.0</a>
<a href="https://dotnet.microsoft.com/en-us/download/dotnet/7.0">https://dotnet.microsoft.com/en-us/download/dotnet/7.0</a>
</pre>

### Restart Terminal
Restart the terminal so the installations we have done takes effect.


## ⚙️ Configure Litium 8
### Nuget
Execute in the terminal to integrate the Litium NuGet source into your .NET environment, using the credentials from your earlier Litium Docs account setup.
Use your username, NOT the emailadress.<br>
```sh
dotnet nuget add source https://nuget.litium.com/nuget -n Litium -u YOUR_USERNAME -p YOUR_PASSWORD --store-password-in-clear-text
```

### Docker
Execute in the terminal to integrate the Litium Cloud Docker registry into your environment, using the credentials associated with your earlier Litium Docs account.<br>
Use your username, NOT the emailadress.<br>
Enter your password for Litium Cloud when prompted.
```sh
docker login registry.litium.cloud -u YOUR_USERNAME
```

### Litium Storefront and Litium template
Execute in the terminal to install Litium Storefront and Litium template
```sh
dotnet tool update -g Litium.Storefront.Cli --version "1.0.0-rc-03" --no-cache && dotnet new install "Litium.Accelerator.React.Templates::1.0.0-rc-02" && dotnet new install "Litium.Accelerator.Templates::8.13.1"
```

*For most recent Litium versions, execute this code instead. Please note, there's a possibility it could disrupt the installation process.*
```sh
dotnet tool update -g Litium.Storefront.Cli --version "1.0.0-rc-*" --no-cache && dotnet new install "Litium.Accelerator.React.Templates::1.0.0-rc-*" && dotnet new install "Litium.Accelerator.Templates"
```

### Certificate
Execute in the terminal to add self-signed certificate. This step is crucial for ensuring proper functionality of Litium.<br>
When prompted for a password, enter your Mac login password to complete the installation of the new certificate. (Can happen two times)
```sh
mkdir -p ~/.litium-config &&
curl -L https://github.com/robertbadas-columbus/litium/install/mac/localhost.config -o ~/.litium-config/localhost.config &&
cd ~/.litium-config
_pass=$(openssl rand -hex 8)
openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -keyout localhost.key -out localhost.crt -config localhost.config -subj "/CN=localhost" &&
openssl pkcs12 -export -out localhost.pfx -inkey localhost.key -in localhost.crt -passout pass:"$_pass" &&
dotnet dev-certs https --clean &&
dotnet dev-certs https -ep ./localhost.pfx --password "$_pass" --trust
rm -r ~/.litium-config &&
cd ~/ &&
echo -e "\033[1;33mPassword used for certificate: $_pass\033[0m"
```


## Create new litium project
Execute in the terminal to create three folders on your desktop and download the necessary files.<br>
```sh
desktop_path="$HOME/Desktop" &&
project_name="LitiumTutorial" &&

if [ -d "$desktop_path/$project_name" ]; then
    echo -e "\033[1;33mFolder already exists. Aborting.\033[0m" &&
    return
fi

docker_dir="${desktop_path}/${project_name}/docker" &&
backend_dir="${desktop_path}/${project_name}/backend" &&
headless_dir="${desktop_path}/${project_name}/headless" &&

mkdir -p "$docker_dir" "$backend_dir" "$headless_dir" &&
cd $backend_dir &&
dotnet new litmvcacc --storefront-api &&
mkdir -p "$backend_dir/Src/Litium.Accelerator.Mvc/Properties" && 
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
}' >"$backend_dir/Src/Litium.Accelerator.Mvc/Properties/launchSettings.json" &&

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
      "ConnectionString": "Pooling=true;User Id=sa;Password=Pass@word;Database=LitiumTutorial;Server=127.0.0.1,5434;TrustServerCertificate=True",
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
}' >"${backend_dir}/Src/Litium.Accelerator.Mvc/appsettings.Development.json"


echo '# The domain name for you Litium platform installation.
RUNTIME_LITIUM_SERVER_URL=https://localhost:5001
# If you using self-signed certificate for the Litium platform
# you may also need to add the following line to turn off certificate validation.
NODE_TLS_REJECT_UNAUTHORIZED="0"
' >"$headless_dir/.env.local"

curl -L https://github.com/robertbadas-columbus/litium/install/mac/docker-compose.yml -o $docker_dir/docker-compose.yml &&
nvm use "18.17.0" && 
cd $backend_dir/Src/Litium.Accelerator.Mvc && yarn install
cd $backend_dir/Src/Litium.Accelerator.Email && yarn install
cd $headless_dir && dotnet new litreactacc && yarn install
cd $docker_dir && docker-compose up -d &&
cd $backend_dir &&
echo -e "\033[1;33mWaiting for connection to the SQL server.\033[0m" &&
while ! docker exec docker-sqlserver-1 /opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U sa -P 'Pass@word' -q "SELECT 1" >/dev/null 2>&1; do sleep 4; done

docker exec docker-sqlserver-1 /opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U sa -P 'Pass@word' -q "CREATE DATABASE LitiumTutorial" &&
dotnet litium-db update --connection "Pooling=true;User Id=sa;Password=Pass@word;Database=LitiumTutorial;Server=127.0.0.1,5434;TrustServerCertificate=True" &&
dotnet litium-db user --connection "Pooling=true;User Id=sa;Password=Pass@word;Database=LitiumTutorial;Server=127.0.0.1,5434;TrustServerCertificate=True" --login admin --password nimda &&
dotnet restore &&
echo -e "\033[1;33mStarting server. Please wait.\033[0m" &&
cd $backend_dir/Src/Litium.Accelerator.Mvc
dotnet run
```

.NET server is now running in the current terminal window.<br>Open a new terminal window and execute code below and leave it open.
```sh
if ! nc -zv 127.0.0.1 3001 &>/dev/null; then
    ~/.dotnet/tools/litium-storefront proxy --litium https://localhost:5001 --storefront http://localhost:3000 &
fi
desktop_path="$HOME/Desktop" &&
project_name="LitiumTutorial" &&
headless_dir="${desktop_path}/${project_name}/headless" &&
cd $headless_dir &&
~/.dotnet/tools/litium-storefront definition import --file "${headless_dir}/litium-definitions/**/*.yaml" --litium https://localhost:5001 --litium-username admin --litium-password nimda
~/.dotnet/tools/litium-storefront text convert-to-excel -i './litium-definitions/texts/*.yaml' -f './litium-definitions/texts/xls/texts.xlsx' &&
nvm use "18.17.0" &&
yarn dev
```

### Create website
Visit the provided URL below in your web browser and log in using the credentials. Locate the "Import" button, marked in blue, at the top-right corner. Click on it and be patient as the process completes; it may take some time.
<pre>
URL: <a target="_blank" href="https://localhost:5001/Litium/UI/settings/extensions/AcceleratorDeployment/deployment">https://localhost:5001/Litium/UI/settings/extensions/AcceleratorDeployment/deployment</a>
Username: admin
Password: nimda
</pre>
![GIF](readme_litium_create_website.gif)

### Import Translations/Texts
- Go to link https://localhost:5001/Litium/UI/settings/websites/website?bc=website:website
- Double click on the row `localhost`.
- Click the tab `Texts`.
- Click the button `Import` and then `Select file`
- Select the file that has been created at `~/Desktop/LitiumTutorial/headless/litium-definitions/texts/xls/texts.xlsx`
- Click `OK`

![GIF](readme_litium_import_translation.gif)


### 🎉 Complete
There are two urls you can visit. The Headless React and MVC Accelerator page.

|     Headless React     |    MVC - Accelerator   |
| ---------------------- | ---------------------- |
| https://localhost:3001 | https://localhost:5001 |
| <img src="readme_litium_headless.png" alt="" style="max-width: 350px;">   | <img src="readme_litium_mvc.png" alt="" style="max-width: 350px;">  |

## To relaunch the application
Execute in the terminal:
```sh
$HOME/Desktop/LitiumTutorial/docker/docker-compose up -d &
cd $HOME/Desktop/LitiumTutorial/backend/Src/Litium.Accelerator.Mvc &&
dotnet run
```

Open new terminal
```sh
~/.dotnet/tools/litium-storefront proxy --litium https://localhost:5001 --storefront http://localhost:3000 &
cd $HOME/Desktop/LitiumTutorial/headless &&
yarn dev
```

## Useful Links
- https://docs.litium.com/accelerators/react-accelerator/get-started
- https://docs.litium.com/accelerators/react-accelerator/storefront-cli
- https://localhost:5001/storefront.graphql