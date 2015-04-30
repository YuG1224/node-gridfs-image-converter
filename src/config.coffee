module.exports =
  session:
    name: "DT"
  redis:
    host: "127.0.0.1"
    port: 6379
    ttl: 7 * 24 * 60 * 60
  cookie:
    maxAge: 7 * 24 * 60 * 60 * 1000
  port: 7000
  mongo:
    host: "127.0.0.1"
    port: 27017
    options:
      poolSize: 10
      auto_reconnect: true
    dbname: "image"
