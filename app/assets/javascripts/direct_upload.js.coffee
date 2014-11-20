addFileUpload = ->
  form = $("form.direct-upload")
  fileUpload = $("<input>").attr({type: "file"})

  $.get "/projects/presigned_post", (data, status) ->
    $("<p>").append(fileUpload).appendTo(form.find(".file-upload-area"))
    attachFileUpload(fileUpload, data)

attachFileUpload = (fileInput, presignedPost) ->
  form = $(fileInput.parents("form:first"))
  submitButton = form.find("input[type=\"submit\"]")
  progressBar = $("<div class='bar'></div>")
  barContainer = $("<div class='progress'></div>").append(progressBar)
  fileInput.after barContainer
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
      progressBar.css "width", progress + "%"

    start: (e) ->
      addFileUpload()
      submitButton.prop "disabled", true
      progressBar.css("background", "green").css("display", "block").css("width", "0%").text "Uploading..."

    done: (e, data) =>
      submitButton.prop "disabled", false
      progressBar.text "Uploading done"

      # extract key and generate URL from response
      key = $(data.jqXHR.responseXML).find("Key").text()
      url = "//#{presignedPost.remote_host}/#{key}"

      # create hidden field
      input = $("<input />",
        type: "hidden"
        name: "file_upload_urls[]"
        value: url
      )
      form.append input

    fail: (e, data) ->
      submitButton.prop "disabled", false
      progressBar.css("background", "red").text "Failed"

$ ->
  if $("form.direct-upload").length > 0
    addFileUpload()

    $("button.add-file").click (event) ->
      event.preventDefault()
      $("input[type=file]:last").click()
