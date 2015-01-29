$ ->
  $("a.dropbox-upload").click (event) ->
    form = $(event.target).closest("form")

    Dropbox.choose
      multiselect: true
      success: (files) =>
        if form.find(".upload-empty:visible").length > 0
          form.find(".upload-wrapper .upload-empty").hide()
          form.find(".upload-wrapper .upload-spinner").show()

        for file in files
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
