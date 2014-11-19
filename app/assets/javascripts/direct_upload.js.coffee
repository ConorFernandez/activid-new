$ ->
  $("input:file.direct-upload").each (i, elem) ->
    fileInput = $(elem)
    window.foo = fileInput
    form = $(fileInput.parents("form:first"))
    submitButton = form.find("input[type=\"submit\"]")
    progressBar = $("<div class='bar'></div>")
    barContainer = $("<div class='progress'></div>").append(progressBar)
    fileInput.after barContainer
    fileInput.fileupload
      fileInput: fileInput
      url: fileInput.data("post-url")
      type: "POST"
      autoUpload: true
      formData: fileInput.data("form-data")
      paramName: "file" # S3 does not like nested name fields i.e. name="user[avatar_url]"
      dataType: "XML" # S3 returns XML if success_action_status is set to 201
      replaceFileInput: false
