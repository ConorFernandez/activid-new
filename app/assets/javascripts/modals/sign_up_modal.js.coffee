class @SignUpModal extends Modal

  constructor: (@options = {}) ->
    @template = Handlebars.compile($("#sign-up-modal-template").html())
    @$modal = $(@template())

    super(@$modal)
