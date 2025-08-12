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

## Demo

### Preparation

1. Start pgSql and RabbitMQ `docker-compose up -d`
2. Start WSO2 APIM in new terminal `$APIM_HOME/bin/api-manager.sh`
3. Start WSO2 MI in new terminal `$MI_HOME/bin/micro-integrator.sh`

### GET /customer360 Integration (Aggregate Three Sources)

1. Show results of separate components connected by WSO2-MI
    1. GET support tickets API
    2. GET CRM API
    3. SELECT orders_db customer_transactions
2. GET integration (fetches from the three sources asynchronously and aggregates result)

### POST /orders Integration (RabbitMQ)
1. Show RabbitMQ management UI > Orders Queue
2. Show pub/sub proxies in WSO2 MI
3. Start WSO2 MI dev runtime
4. Post a successful order
```
curl -v -X POST http://localhost:8290/services/RabbitMQPublisherProxy   -H "Content-Type: application/json"   -d '{
    "customer_id": 2,
    "product": "Mouse Pad",
    "amount": 13.00
  }'
```
4. **Exceed Max Retries**: Deactivate pgSql to force error and post a new order. `docker-compose down postgres`. 
	1. Wait 25 seconds to error out 5 times and hit DLQ while watching WSO2 logs.
	2. Show RabbitMQ management UI
		1. DLQ > Get Message
		2. Orders > Graphs
5. **Retry and Succeed**: Deactivate pgSql to force error and post new order. `docker-compose down postgres`. 
	1. Wait 10 seconds then reactivate pgSql `docker-compose up -d postgres`
	2. Show success (new record in TablePlus)
	3. Show RabbitMQ management UI > Orders > Message Rates
### API Manager

1. [Generate](https://localhost:9443/devportal/apis/925a4917-e130-435d-b526-f9db01ebae40/credentials) (ensure signed into dev portal) new Gold and Bronze tokens and store them in [Postman Demo collection](https://ghazi2.postman.co/workspace/Pizza~32de9abf-cc7e-431f-8ce2-62b835950bb7/request/3533915-b539508d-6aa3-46bc-bdef-e1da987ac27d) (ensure postman is running locally).
2. [Run DemoTieredQPS](https://ghazi2.postman.co/workspace/Pizza~32de9abf-cc7e-431f-8ce2-62b835950bb7/run/create?collection=3533915-ddcb5e38-e822-4e92-85df-493e5d407c34&type=manual-run&tab=functional) after setting Iterations to 20.
    1. Show 429 appear on bronze requests after 10th request.
    2. Show a sample valid return, and explain 3 sources (show integrator).
3. Add a new subscription in the dev portal and query using its token

