mongo = require "./lib/mongo"
fs = require "fs"
crypto = require "crypto"
im = require "imagemagick-native"

hashify = (str) ->
  md5sum = crypto.createHash 'md5'
  md5sum.update str
  return md5sum.digest 'hex'

convertFile = (query) ->
  return new Promise (resolve, reject) ->
    im.convert query, (err, buffer) ->
      if err then return reject err
      data =
        format: query.format
        buffer: buffer
      resolve data

identify = (query) ->
  return new Promise (resolve, reject) ->
    im.identify query, (err, result) ->
      if err then reject err else resolve result

exports.upsert = (req, res) ->
  file = req.files.file
  path = "./#{file.path}"
  filename = hashify path

  filename = req.params.id
  unless filename then filename = hashify path

  promises = []
  promises.push mongo.writeFile filename, path
  query =
    srcData: fs.readFileSync path
  promises.push identify query

  Promise.all promises
    .then (data) ->
      res.status(200).send
        id: data[0].filename
        identify: data[1]
      fs.unlink path
    .catch (err) ->
      console.log err.stack
      res.sendStatus 500
      fs.unlink path

exports.show = (req, res) ->
  filename = req.params.id
  query = req.query

  mongo.readFileStream filename
    .then (data) ->
      if query.width or query.height
        resize = {}
        resize.srcData = data
        resize.width = query.width ? null
        resize.height = query.height ? null
        return convertFile resize
      else return data
    .then (data) ->
      convert = query
      convert.srcData = data.buffer
      return convertFile convert
    .then (data) ->
      if data.format
        res.type data.format
      res.end data.buffer, "binary"
      return
    .catch (err) ->
      console.log err.stack
      if err.message is "ENOENT"
        res.sendStatus 404
      else
        res.sendStatus 500

exports.destroy = (req, res) ->
  filename = req.params.id

  mongo.unlink filename
    .then (data) ->
      res.sendStatus 200
    .catch (err) ->
      console.log err.stack
      res.sendStatus 500
