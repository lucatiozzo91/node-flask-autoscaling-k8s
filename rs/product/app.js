const promBundle = require("express-prom-bundle");
const app = require("express")();
const metricsMiddleware = promBundle({includeMethod: true, includePath: true});
const moment = require('moment');


app.get("/healthz", (req, res) => res.status(200).send(moment().format("YYYY-MM-DD HH:mm:ss")));

app.use(metricsMiddleware);

app.get('/', function (req, res) {
  res.status(200).send({"message":"Hello World Product"});
});

app.listen(3000);