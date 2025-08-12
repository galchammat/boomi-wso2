# WSO2 Demo Project

This repository contains an integration demo using WSO2 Micro Integrator, RabbitMQ, PostgreSQL, and Postman Mock APIs.


## Run Postgres and RabbitMQ 
Run `docker-compose up` to start PostgreSQL and RabbitMQ. The RabbitMQ config and definitions under `/rabbitmq` and pgSql seeds under `/seeds` are automatically mounted and applied by this operation. 

## Develop or Deploy with WSO2 Micro Integrator  

### First Time Setup:
1. Install the vs-code extension [WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl).
2. Make sure this repo is cloned in your WSL file system (not mnt/), and `cd` to its location. 
3. Run `code .` to open vs-code in the context of WSL through SSH.
4. Install the vs-code extension [WSO2 Integrator:MI](https://marketplace.visualstudio.com/items?itemName=WSO2.micro-integrator)

### Debug the WSO2 Micro Integrator Components
1. In the WSO2 Integrator:MI extension's tab, click "Open MI Project", and select Customer360. 
2. Click the play button in the top right.

### Build and Deploy the WSO2 Micro Integrator Components
1. In the WSO2 Integrator:MI extension's tab, click "Open MI Project", and select Customer360. 
2. In vs-code's file pane, next to the top-level folder, click on the file menu icon which on-hover says "Open Project Overview". 
3. In the "Deployment Options" menu to the right, click "Build CAPP". 
4. Find the deployment file at `./target/customer360_1.0.0.car`, and copy it to your WSO2 Integrator: MI installation location, usually at `~/.wso2-mi/micro-integrator/wso2mi-4.4.0/repository/deployment/server/carbonapps`. 
5. Start the WSO2 Micro Integrator *after* starting the WSO2 API Manager to allow your integration to be discovered in the API Manager's service_catalog. Also if running for the first time, *make sure* to share certificates accross the two apps as shown in[Certificate Setup](#certificate-setup).

## RUN WSO2 API Manager

## First time
1. Follow the installation guide at https://github.com/wso2/product-apim/releases
2. Export the environment variable `APIM_HOME` with value set to your installation directory which contains the subdirectory `./bin`. Write the export in `~/.bashrc` to make it permanent. 

## Run
Run `$APIM_HOME/bin/api-manager.sh`.  


## Certificate Setup
Before running the steps below, install both API Manager and WSO2 Micro Integrator by following their *first time* subsections, and set $APIM_HOME and $MI_HOME respectively in ~/.bashrc.
1. Enable publishing MI services to APIM service_catalog:
``` bash
# Export certificate from API Manager
keytool -export -alias wso2carbon -file apim.crt -keystore $APIM_HOME/repository/resources/security/wso2carbon.jks -storepass wso2carbon

# Import certificate to MI truststore
keytool -import -alias apim-cert -file apim.crt -keystore $MI_HOME/repository/resources/security/client-truststore.jks -storepass wso2carbon
```
2. Allow APIM to act as API proxy of MI.
```bash
# Export certificate from MI truststore
keytool -export -alias apim-cert -file mi.crt -keystore $MI_HOME/repository/resources/security/client-truststore.jks -storepass wso2carbon

# Import certificate to API Manager keystore
keytool -import -alias mi-cert -file mi.crt -keystore $APIM_HOME/repository/resources/security/wso2carbon.jks -storepass wso2carbon
```
