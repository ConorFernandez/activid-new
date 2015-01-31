class @YoutubeModal extends Modal

  constructor: (@options = {}) ->
    @template = Handlebars.compile($("#youtube-modal-template").html())
    @$modal = $(@template(@options))

    super(@$modal, @options)
