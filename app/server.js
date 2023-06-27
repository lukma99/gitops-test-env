const express = require('express')
const yaml = require('js-yaml')
const fs = require('fs')
const app = express()

// index page
app.get('/', function (req, res) {
    let configmap

    // read configmap file
    try {
        configmap = yaml.load(fs.readFileSync("./configmap/cm.yaml", "utf8"))
    } catch (e) {
        configmap = []
        console.log(e)
    }

    let result = `<h1>Hello from ${configmap['app-name'] || 'Kubernetes'}!</h1>
<h2>You are running version ${process.env.APP_VERSION || '"Undefined"'}</h2>
<h2>The following values are included in the configmap:</h2>`

    if (configmap.length === 0) {
        result += `<i>configmap is missing or empty</i>`
    } else {
        // Build a table with all key value pairs of the configmap yaml
        result += `<table><tr><th>Key</th><th>Value</th></tr>`
        for (let key of Object.keys(configmap)) {
            result += `<tr><th>${key}</th><th>${configmap[key]}</th></tr>`
        }
        result += `</table>`
    }

    res.send(result)
})

// server startup
app.listen(3000, function () {
    console.log('App is listening on port 3000!')
})
