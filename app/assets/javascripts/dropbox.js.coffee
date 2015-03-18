$ ->
  $("a.dropbox-upload").click (event) ->
    form = $(event.target).closest("form")
    formats = form.data("formats").split(",")

    Dropbox.choose
      multiselect: true
      success: (files) =>
        invalid_files = false

        for file in files
          parts = file.link.split("/")
          fileName = parts[parts.length - 1]
          extension = fileName.match(/\.(\w+)(\?.*)?$/)[1].toLowerCase()

          if formats.length > 0 && formats.indexOf(extension) < 0
            invalid_files = true

        if invalid_files && form.find(".upload-errors:visible").length == 0
          errorsContainer = $("<div>", class: "upload-errors", html: "Must be one of the following formats: #{formats.join(", ")}.")
          form.find(".upload-wrapper .upload-empty").hide()
          form.find(".upload-wrapper").prepend(errorsContainer)
        else if !invalid_files
          form.find(".upload-wrapper .upload-errors").hide()

          if form.find(".upload-block:visible").length == 0
            form.find(".upload-wrapper .upload-empty").hide()
            form.find(".upload-wrapper .upload-spinner").show()

          for file in files
            console.log "POSTing to /file_uploads with source_url", file.link
            $.ajax
              type: "POST"
              url: "/file_uploads"
              data: {file_upload: {source_url: file.link}, attachable_type: "project", project_uuid: form.data("project-uuid")}
              success: (data) =>
                uploadBlock = $("<div>", class: "upload-block").addClass("complete")
                uploadBlock.append $("<input>", type: "hidden", name: "file_upload_uuids[]", value: data.uuid)
                barContainer = $("<div>", class: "upload-progress").append($("<span>", style: "width: 100%"))
                actionsContainer = $("<div>", class: "upload-actions").append(barContainer)
                uploadBlock.prepend($("<h6>", html: data.file_name)).append(actionsContainer)
                dU.insertUploadActions(actionsContainer, "done", data.uuid, null)

                form.find(".upload-wrapper").prepend(uploadBlock)
                form.find(".upload-wrapper .upload-spinner").hide()
