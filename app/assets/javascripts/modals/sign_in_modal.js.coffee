class @SignInModal extends Modal

  constructor: (@options = {}) ->
    @template = Handlebars.compile($("#sign-in-modal-template").html())
    @$modal = $(@template())

    super(@$modal, @options)
