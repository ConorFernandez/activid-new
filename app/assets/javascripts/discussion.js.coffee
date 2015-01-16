$ ->
  $(".approve-reject-links a.approve").click (e) ->
    $link = $(e.target)

    options =
      previewURL: $link.data("preview-url")
      cutID: $link.data("cut-id")
      cost: $link.data("cost")
      numRevisions: $link.data("num-revisions")

    new ApproveCutModal(options).open()

  $(".approve-reject-links a.reject").click (e) ->
    $link = $(e.target)

    options =
      previewURL: $link.data("preview-url")
      cutID: $link.data("cut-id")
      chargeForRevision: $link.data("charge-for-revision")

    new RejectCutModal(options).open()
