class @ApproveCutModal extends Modal

  constructor: (@options = {}) ->
    @template = Handlebars.compile($("#approve-cut-modal-template").html())
    @$modal = $(@template())

    super(@$modal, @options)
