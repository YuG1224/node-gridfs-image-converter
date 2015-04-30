Vue = require "vue"
qs = require "qs"

vm = new Vue
  el: ".main"
  data:
    id: ""
    file: ""
    image: "/images/noimage.png"
    url: "/dt/v0/images"
    params:
      width: 300
      height: 300
      quality: 75
      rotate: 0
      blur: 0
      format: "JPEG"
    maxWidth: 1000
    maxHeight: 1000
  methods:
    create: (val) ->
      @file = val.target.files[0]
      data = new FormData
      data.append "file", @file

      $.ajax
        type: "post"
        url: @url
        data: data
        processData: false
        contentType: false
      .done (data, textStatus, jqXHR) =>
        @id = data.id
        @maxWidth = data.identify.width ? 1000
        @maxHeight = data.identify.height ? 1000
        query = qs.stringify @params
        @image = "#{@url}/#{@id}?#{query}"
        return
      .fail (jqXHR, textStatus, errorThrown) ->
        console.log jqXHR, textStatus, errorThrown
        return
      return

    update: () ->
      if @file
        query = qs.stringify @params
        @image = "#{@url}/#{@id}?#{query}"
      return

    open: () ->
      window.open @image, "_blank"
      return
