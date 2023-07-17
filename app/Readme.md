# Example app for all deployment/promotion strategies

In this `app` folder you can find a simple NodeJS application.
It shows the following information on the website:
* `app-name`-value from the file `./configmap/cm.yaml`
* All key-value-pairs from the file `./configmap/cm.yaml`
* Current version of the app (specified through ARG in `Dockerfile`)
  
When using a kubernetes deployment, mount the configmap to `/usr/src/app/configmap/cm.yaml`.


## Run locally with `node`
For development on local maschine:
```shell
npm install
node server.js
# access under http://localhost:3000
```
