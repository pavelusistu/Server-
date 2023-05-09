const { Client } = require("pg");

const client = new Client({
  user: "pavell",
  password: "parola",
  host: "localhost",
  port: 5432,
  database: "lucrareLicenta",
});
protocol = "http://";
domainName = "localhost:5000";
client.connect();

module.exports = client;
