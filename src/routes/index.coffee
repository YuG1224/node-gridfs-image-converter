exports.index = (req, res) ->
  res.render "index",
    pretty: true
    lang: "ja"
    title: "DT"
  return
