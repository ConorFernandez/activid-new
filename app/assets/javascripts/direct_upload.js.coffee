$.fn.directUpload = ->
  formats = this.data("formats").split(",")

  this.addMultipleFileUpload(formats)
  this.bindUploadActions()
  this.find("button.add-file").click (event) ->
    event.preventDefault()
    $("input#direct-upload").click()

$.fn.addMultipleFileUpload = (formats) ->
  dU.addMultipleFileUpload(this, formats)

$.fn.bindUploadActions = ->
  dU.bindUploadActions(this)

$.fn.makeDirectUpload = (presignedPost) ->
  dU.makeDirectUpload(this, presignedPost)

window.dU =
  # @deprecated, please use addMultipleFileUpload()
  addFileUpload: (form, formats) ->
    fileUpload = $("<input>", type: "file")
    container = $("<div>", class: "upload-block-placeholder")

    $.get "/file_uploads/presigned_post", (data, status) ->
      container.append(fileUpload).insertBefore(form.find(".upload-wrapper footer"))
      dU.makeDirectUpload(fileUpload, data, formats)

  addMultipleFileUpload: (form, formats) ->
    container = $("<div>", class: "upload-block-placeholder")
    fileUpload = $("<input>", id: "direct-upload", type: "file", multiple: true)
    fileUpload.on('change', this.filesAdded.bind({formats: formats}))
    container.append(fileUpload).insertBefore(form.find(".upload-wrapper footer"))

  filesAdded: (event) ->
    formats = this.formats
    files = event.originalEvent.target.files
    $.get "/file_uploads/presigned_posts/#{files.length}", (data, status) ->
      presignedPosts = data["presigned_posts"]
      for post, index in presignedPosts
        dU.makeFileInput(files[index], post, formats)

  makeFileInput: (file, presignedPost, formats) ->
    $fileInput = $("<input>", type: "file", id: "file-upload-#{new Date().getTime()}")
    $fileInput.attr('data-name', file.name)
    $('.upload-wrapper').append($fileInput)
    dU.makeDirectUpload($fileInput, presignedPost, formats)
    $fileInput.fileupload('add', files: [ file ])

  makeDirectUpload: ($fileInput, presignedPost, formats) ->
    form = $($fileInput.parents("form:first"))

    uploadContainer = $(form.find(".upload-block-placeholder:first"))
    if uploadContainer.hasClass('upload-block')
      uploadContainer = $("<div>", class: "upload-block-placeholder")
      uploadContainer.insertBefore(form.find(".upload-wrapper footer"))

    progressBar = $("<span>")
    barContainer = $("<div>", class: "upload-progress").append(progressBar)
    actionsContainer = $("<div>", class: "upload-actions").append(barContainer)

    $fileInput.fileupload
      fileInput: $fileInput
      url: presignedPost.post_url
      type: "POST"
      autoUpload: true
      formData: presignedPost.form_data
      paramName: "file" # S3 does not like nested name fields i.e. name="user[avatar_url]"
      dataType: "XML" # S3 returns XML if success_action_status is set to 201
      replaceFileInput: false

      add: (e, data) ->
        jqXHR = data.submit()
        dU.insertUploadActions(actionsContainer, "uploading", false, jqXHR)

      progressall: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        progressBar.css("width", progress + "%")

      submit: (e) ->
        form.find(".upload-wrapper .upload-errors").remove()
        form.find(".upload-wrapper .upload-empty").hide()

        parts = $fileInput.data('name').split(/\/|\\/)
        fileName = parts[parts.length - 1]

        parts = fileName.split(".")
        extension = parts[parts.length - 1].toLowerCase()

        if formats.length > 0 && formats.indexOf(extension) < 0
          errorsContainer = $("<div>", class: "upload-errors", html: "Must be one of the following formats: #{formats.join(", ")}.")
          form.find(".upload-wrapper").prepend(errorsContainer)

          # cancel upload if file is invalid format
          return false

      start: (e) ->
        parts = $fileInput.data('name').split(/\/|\\/)
        fileName = parts[parts.length - 1]

        uploadContainer.prepend($("<h6>", html: fileName))

        uploadContainer.addClass("upload-block")
        uploadContainer.removeClass("")

        progressBar.css("width", "0%")
        uploadContainer.append(actionsContainer)
        form.trigger("upload-start")

      done: (e, data) =>
        # extract key and generate URL from response
        key = $(data.jqXHR.responseXML).find("Key").text()
        url = "//#{presignedPost.remote_host}/#{key}"
        
        $.ajax
          type: "POST"
          url: "/file_uploads"
          data: {file_upload: {url: url}, attachable_type: form.data("attachable-type"), project_uuid: form.data("project-uuid")}
          success: (data) ->
            uploadContainer.addClass('complete').append $("<input>", type: "hidden", name: "file_upload_uuids[]", value: data.uuid)
            dU.insertUploadActions(actionsContainer, "done", data.uuid, false)
            form.trigger("upload-complete")

      fail: (e, data) ->
        uploadContainer.remove()

  insertUploadActions: (element, status, uuid, jqXHR) ->
    element.find("a").remove()

    switch status
      when "done"
        element.append $("<span>", class: "delete-upload", html: "done", "data-upload-uuid": uuid) if uuid
        element.append $("<a>", class: "delete-upload", html: "delete?", "data-upload-uuid": uuid) if uuid
      when "uploading"
        element.append $("<a>", class: "cancel-upload", html: "cancel")

    dU.bindUploadActions(element, jqXHR)

  bindUploadActions: (element, jqXHR) ->
    element.find("a.delete-upload").click (event) ->
      link = $(event.target)
      uploadWrapper = link.parents(".upload-wrapper:first")
      uuid = link.data("upload-uuid")

      link.parents(".upload-block:first").remove()

      if uploadWrapper.find(".upload-block").length == 0
        uploadWrapper.find(".upload-empty").show()

      $.ajax
        type: "POST"
        url: "/file_uploads/#{uuid}"
        data: {"_method": "delete"}

    if jqXHR
      element.find("a.cancel-upload").click (event) ->
        link = $(event.target)
        uploadWrapper = link.parents(".upload-wrapper:first")
        form = link.parents("form:first")

        form.trigger("upload-cancel")
        jqXHR.abort()

        if uploadWrapper.find(".upload-block").length == 0
          uploadWrapper.find(".upload-empty").show()

$ ->
  if $("form.direct-upload").length > 0
    $("form.direct-upload").directUpload()

  $("form#new_cut.direct-upload").on "upload-start", ->
    $(this).find("button.add-file").prop("disabled", true)

  $("form#new_cut.direct-upload").on "upload-complete", ->
    this.submit()

  $("form#new_cut.direct-upload").on "upload-cancel", ->
    $(this).find("button.add-file").prop("disabled", false)

  $("form.project-step-2").on "upload-start", ->
    submitButton = $(this).find("input[type=\"submit\"]")
    submitButton.prop("disabled", true)

  $("form.project-step-2").on "upload-complete", ->
    if $(this).find("a.cancel-upload").length == 0
      submitButton = $(this).find("input[type=\"submit\"]")
      submitButton.prop("disabled", false)

  $("form.project-step-2").on "upload-cancel", ->
    submitButton = $(this).find("input[type=\"submit\"]")
    submitButton.prop("disabled", false)

  $("form.project-step-3").on "upload-start", ->
    submitButton = $(this).find("input[type=\"submit\"]")
    submitButton.prop("disabled", true)

  $("form.project-step-3").on "upload-complete", ->
    if $(this).find("a.cancel-upload").length == 0
      submitButton = $(this).find("input[type=\"submit\"]")
      submitButton.prop("disabled", false)

  $("form.project-step-3").on "upload-cancel", ->
    submitButton = $(this).find("input[type=\"submit\"]")
    submitButton.prop("disabled", false)
