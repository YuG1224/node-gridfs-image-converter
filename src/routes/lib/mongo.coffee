Db = require("mongodb").Db
Server = require("mongodb").Server
GridStore = require("mongodb").GridStore
fs = require "fs"
config = require('../../config').mongo

exports.writeFile = (filename, filepath) ->
  return new Promise (resolve, reject) ->
    db = new Db config.dbname, new Server config.host, config.port
    db.open (err, db) ->
      if err then return reject err
      gs = new GridStore db, filename, "w", w:1
      gs.open (err, gs) ->
        if err then return reject err
        gs.writeFile filepath, (err, writeData) ->
          if err then return reject err
          db.close resolve writeData

exports.readFileStream = (filename) ->
  return new Promise (resolve, reject) ->
    db = new Db config.dbname, new Server config.host, config.port
    db.open (err, db) ->
      if err then return reject err
      gs = new GridStore db, filename, "r", {}
      gs.open (err, gs) ->
        if err then return reject err
        tmp = "./tmp/#{filename}#{Math.random()}".replace "0.", ''
        stream = gs.stream true
        stream.on "end", (err) ->
          if err then return reject err
          streamedData = fs.createReadStream tmp
          list = []
          streamedData.on "data", (chunk) ->
            list.push chunk
          streamedData.on "end", () ->
            if list.length is 0 then reject new Error "ENOENT"
            db.close resolve Buffer.concat(list)
            fs.unlink tmp

        fileStream = fs.createWriteStream tmp
        stream.pipe fileStream

exports.unlink = (filename) ->
  return new Promise (resolve, reject) ->
    db = new Db dbname, new Server config.host, config.port
    db.open (err, db) ->
      if err then return reject err
      gs = new GridStore db, filename, "w", w: 1
      gs.open (err, gs) ->
        if err then return reject err
        gs.unlink (err, result) ->
          if err then return reject err
          db.close resolve result
