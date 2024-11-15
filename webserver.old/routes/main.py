routes = {
  "/deploy": "bash /home/ubuntu/webserver/routes/deploy.sh",
  "/healthcheck" : "bash /home/ubuntu/webserver/routes/healthcheck.sh",
  "/status" : "bash /home/ubuntu/webserver/routes/status.sh",
  "/information" : "bash /home/ubuntu/webserver/routes/information.sh",
  "/transaction" : "bash /home/ubuntu/webserver/routes/transaction.sh",
  "/check" : "bash /home/ubuntu/webserver/routes/balance.sh",
  "/download" : "cat /home/ubuntu/validator-wallet.json"
}

