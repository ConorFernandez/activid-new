$.fn.directUpload = ->
  this.addFileUpload()
  this.bindUploadActions()
  this.find("button.add-file").click (event) ->
    event.preventDefault()
    $("input[type=file]:last").click()

$.fn.addFileUpload = ->
  dU.addFileUpload(this)

$.fn.bindUploadActions = ->
  dU.bindUploadActions(this)

$.fn.makeDirectUpload = (presignedPost) ->
  dU.makeDirectUpload(this, presignedPost)

dU =
  addFileUpload: (form) ->
    fileUpload = $("<input>", type: "file")
    container = $("<div>", class: "upload-block-placeholder")

    $.get "/file_uploads/presigned_post", (data, status) ->
      container.append(fileUpload).insertBefore(form.find(".upload-wrapper footer"))
      dU.makeDirectUpload(fileUpload, data)

  makeDirectUpload: (fileInput, presignedPost) ->
    form = $(fileInput.parents("form:first"))
    uploadContainer = $(fileInput.parents(".upload-block-placeholder:first"))

    submitButton = form.find("input[type=\"submit\"]")
    progressBar = $("<span>")
    barContainer = $("<div>", class: "upload-progress").append(progressBar)
    actionsContainer = $("<div>", class: "upload-actions").append(barContainer)

    fileInput.fileupload
      fileInput: fileInput
      url: presignedPost.post_url
      type: "POST"
      autoUpload: true
      formData: presignedPost.form_data
      paramName: "file" # S3 does not like nested name fields i.e. name="user[avatar_url]"
      dataType: "XML" # S3 returns XML if success_action_status is set to 201
      replaceFileInput: false

      progressall: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        progressBar.css("width", progress + "%")

      start: (e) ->
        # add element to be used by the next file upload
        dU.addFileUpload(form)

        parts = e.target.value.split("\\")
        fileName = parts[parts.length - 1]
        uploadContainer.prepend($("<h6>", html: fileName))

        uploadContainer.addClass("upload-block")

        submitButton.prop("disabled", true)
        progressBar.css("width", "0%")
        fileInput.after(actionsContainer)
        form.trigger("upload-start")

      done: (e, data) =>
        # extract key and generate URL from response
        key = $(data.jqXHR.responseXML).find("Key").text()
        url = "//#{presignedPost.remote_host}/#{key}"

        $.ajax
          type: "POST"
          url: "/file_uploads"
          data: {file_upload: {url: url}, attachable_type: form.data("attachable-type")}
          success: (data) ->
            uploadContainer.addClass('complete').append $("<input>", type: "hidden", name: "file_upload_uuids[]", value: data.uuid)
            submitButton.prop("disabled", false)
            dU.insertUploadActions(actionsContainer, data.uuid, "done")
            form.trigger("upload-complete")

      fail: (e, data) ->
        uploadContainer.remove()

  insertUploadActions: (element, uuid, status) ->
    element.find("a").remove()

    switch status
      when "done"
        element.append $("<a>", class: "delete-upload", html: "delete", "data-upload-uuid": uuid)

    dU.bindUploadActions(element)

  bindUploadActions: (element) ->
    element.find("a.delete-upload").click (event) ->
      link = $(event.target)
      uuid = link.data("upload-uuid")

      link.parents(".upload-block:first").remove()

      $.ajax
        type: "POST"
        url: "/file_uploads/#{uuid}"
        data: {"_method": "delete"}

$ ->
  $("form.direct-upload").directUpload()

  $("form#new_cut.direct-upload").on "upload-start", ->
    $(this).find("button.add-file").prop("disabled", true)

  $("form#new_cut.direct-upload").on "upload-complete", ->
    this.submit()
