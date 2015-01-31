class @ApproveCutModal extends Modal

  constructor: (@options = {}) ->
    @template = Handlebars.compile($("#approve-cut-modal-template").html())

    @options.showLineItems = @options.numRevisions > 1
    @options.priceOfRevisions = (@options.numRevisions - 1) * 25
    @options.initialPrice = @options.cost - @options.priceOfRevisions

    @$modal = $(@template(@options))

    super(@$modal, @options)

    @_bindSubmit()

  _bindSubmit: ->
    @$modal.find("button.confirm").click (e) =>
      $(e.target).prop("disabled", true)

      $.ajax
        method: "PUT"
        url: "/cuts/#{@options.cutID}/approve"
        success: (data) ->
          window.location = data.path
        error: (data) =>
          @close()
          new FixCardModal(@options).open()
