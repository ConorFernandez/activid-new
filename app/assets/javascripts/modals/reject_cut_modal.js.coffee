class @RejectCutModal extends Modal

  constructor: (@options = {}) ->
    @template = Handlebars.compile($("#reject-cut-modal-template").html())
    @$modal = $(@template(@options))

    super(@$modal, @options)

    @_bindSubmit()

  open: ->
    @$modal.find("textarea").focus()
    super()

  _bindSubmit: ->
    @$modal.find("a.confirm").click (e) =>
      comments = @$modal.find("textarea#reject_reason").val()

      if comments.length == 0
        @$modal.find("textarea#reject_reason").addClass("error")
      else
        $.ajax
          method: "PUT"
          url: "/cuts/#{@options.cutID}/reject"
          data:
            cut:
              reject_reason: comments
          success: (data) ->
            window.location = data.path
