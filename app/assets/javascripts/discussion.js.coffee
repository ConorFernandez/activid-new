$ ->
  $(".approve-reject-links a.approve").click (e) ->
    new ApproveCutModal().open()
