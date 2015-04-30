express = require "express"
http = require "http"
favicon = require "serve-favicon"
fs = require "fs"
bodyParser = require "body-parser"
cookieParser = require "cookie-parser"
compression = require "compression"
session = require "express-session"
RedisStore = require("connect-redis")(session)
multer = require "multer"

app = express()
server = http.createServer app
config = require("./config")

app.set "port", config.port
app.set "views", "./src/views"
app.set "view engine", "jade"
app.use compression
  level: 1
app.use favicon "./src/favicon.png"
app.use bodyParser.json()
app.use bodyParser.urlencoded
  extended: true
app.use multer
  dest: "./tmp/"
app.use cookieParser()
app.use session
  name: config.session.name
  store: new RedisStore config.redis
  cookie: config.cookie
  secret: config.session.name
  resave: true
  saveUninitialized: true

# URLマッピング
route = require "./routes"
app.get "/", route.index

# API ルーティング
v0 = require "./routes/v0"
app.post "/dt/v0/images", v0.upsert
app.get "/dt/v0/images/:id", v0.show
app.put "/dt/v0/images/:id", v0.upsert
app.delete "/dt/v0/images/:id", v0.destroy

app.use express.static "./dist"

server.listen app.get("port"), ->
  console.log "Server listen on port #{app.get('port')}"
  return
