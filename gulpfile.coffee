browserify = require "browserify"
coffee = require "gulp-coffee"
concat = require "gulp-concat"
del = require "del"
gulp = require "gulp"
foreach = require "gulp-foreach"
fs = require "fs"
minifycss = require "gulp-minify-css"
nodemon = require "nodemon"
path = require "path"
rs = require "run-sequence"
stylus = require "gulp-stylus"
source = require "vinyl-source-stream"

# app
gulp.task "app", () ->
  return gulp.src "./src/*.coffee"
    .pipe coffee()
    .pipe gulp.dest "./"

# route
gulp.task "routes", () ->
  return gulp.src "./src/routes/*.coffee"
    .pipe coffee()
    .pipe gulp.dest "./routes/"

# lib
gulp.task "lib", () ->
  return gulp.src "./src/routes/lib/*.coffee"
    .pipe coffee()
    .pipe gulp.dest "./routes/lib/"

# coffee
gulp.task "coffee", () ->
  return gulp.src "./src/coffee/*.coffee"
    .pipe foreach (stream, file) ->
      filename = path.basename file.path, ".coffee"
      options =
        entries: file.path
        extensions: [".coffee"]
        debug: true

      return browserify options
        .bundle()
        .pipe source "#{filename}.js"
    .pipe gulp.dest "./dist/js"

# scripts
gulp.task "scripts", ["app", "routes", "lib", "coffee"]

# css
gulp.task "stylus", () ->
  return gulp.src "./src/stylus/*.styl"
    .pipe foreach (stream, file) ->
      return stream.pipe stylus()
    .pipe minifycss
      keepBreaks: true
    .pipe gulp.dest "./dist/css"

# js
gulp.task "js", () ->
  return gulp.src [
    "./bower_components/jquery/dist/jquery.js"
    "./bower_components/bootstrap/dist/js/bootstrap.js"
    "./bower_components/moment/moment.js"
  ]
  .pipe concat "vendor.js"
  .pipe gulp.dest "./dist/js"

# css
gulp.task "css", () ->
  return gulp.src [
    "./bower_components/bootstrap/dist/css/bootstrap.min.css"
  ]
  .pipe concat "vendor.css"
  .pipe minifycss
    keepBreaks: true
  .pipe gulp.dest "./dist/css"

# fonts
gulp.task "fonts", () ->
  return gulp.src "./bower_components/bootstrap/dist/fonts/*"
    .pipe gulp.dest "./dist/fonts/"

# vendor
gulp.task "vendor", ["js", "css", "fonts"]

# images
gulp.task "images", () ->
  return gulp.src "./src/images/*"
    .pipe gulp.dest "./dist/images/"

# watch
gulp.task "watch", () ->
  gulp.watch [
    "./src/*.coffee"
  ], ["app"]
  gulp.watch [
    "./src/routes/*.coffee"
  ], ["routes"]
  gulp.watch [
    "./src/routes/lib/*.coffee"
  ], ["lib"]
  gulp.watch [
    "./src/coffee/*.coffee"
    "./src/coffee/lib/*.coffee"
  ], ["coffee"]
  gulp.watch [
    "./src/stylus/*.styl"
    "./src/stylus/lib/*.styl"
  ], ["stylus"]
  gulp.watch [
    "./src/images/*"
  ], ["images"]
  return

# nodemon
gulp.task "nodemon", ["build", "watch"], () ->
  nodemon
    script: "./app.js"
    env:
      NODE_ENV: "development"

# del
gulp.task "del", () ->
  return del.sync [
    "./dist"
    "./routes"
    "./*.js"
  ]

# build
gulp.task "build", (done) ->
  return rs "del",
    [
      "scripts"
      "stylus"
      "vendor"
      "images"
    ],
    done

# preview
gulp.task "default", (done) ->
  return rs "nodemon", done
