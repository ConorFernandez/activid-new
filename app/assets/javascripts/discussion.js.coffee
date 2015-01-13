$ ->
  $(".approve-reject-links a.approve").click (e) ->
    $link = $(e.target)

    options =
      previewURL: $link.data("preview-url")
      cutID: $link.data("cut-id")
      cost: $link.data("cost")

    new ApproveCutModal(options).open()
