class @ApproveCutModal extends Modal

  constructor: (@options = {}) ->
    @template = Handlebars.compile($("#approve-cut-modal-template").html())
    @$modal = $(@template(@options))

    super(@$modal, @options)

    @_bindSubmit()

  _bindSubmit: ->
    @$modal.find("a.confirm").click (e) =>
      $.ajax
        method: "PUT"
        url: "/cuts/#{@options.cutID}/approve"
        success: (data) ->
          window.location = data.path
