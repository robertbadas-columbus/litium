# Litium 8 dependency installation for Mac - MVC Accelerator & React Headless

This repository provides step-by-step instructions for installing Litium 8 on a Mac with ARM architecture, utilizing the Sonoma OS. Follow the guidelines in this documentation for a seamless installation process.

<pre>
<b>Litium versions used for this tutorial</b>
- Litium.Storefront.Cli 1.0.0-rc-03
- Litium.Accelerator.React.Templates 1.0.0-rc-02
- Litium.Accelerator.Templates 8.13.1
</pre>

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
curl -L https://raw.githubusercontent.com/robertbadas-columbus/litium/main/install/mac/localhost.config -o ~/.litium-config/localhost.config &&
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

## Useful Links
- https://docs.litium.com/accelerators/react-accelerator/get-started
- https://docs.litium.com/accelerators/react-accelerator/storefront-cli
- https://docs.litium.com/platform/guides/how-to-create-pages-in-react-accelerator
- https://docs.litium.com/platform/guides/how-to-create-custom-blocks-in-mvc-accelerator
- https://docs.litium.com/platform/guides/how-to-create-blocks-in-react-accelerator
- https://localhost:5001/storefront.graphql

# We are Columbus
Columbus is a global digital advisory and IT services company with more than 1,600 digital advisors serving our customers worldwide. We bring digital transformation into your business, help maximize your value chain and position you to thrive far into the future.

Columbus’ offers end-to-end digital solutions within Strategy & Change, Cloud ERP, Digital Commerce, Data & Analytics, Customer Experience and Application Management that address the lifecycle and sustainability demands of the Manufacturing, Retail & Distribution, Food & Process industries.

We offer a comprehensive solution portfolio with deep industry knowledge, extensive technology expertise and profound customer insight. We have proven this through 30 years of experience serving more than 2,500 customers worldwide.<br>
[www.columbusglobal.com](https://www.columbusglobal.com)

<a href="https://www.columbusglobal.com"><img src="media/columbus.png" alt="" width="250px"></a>