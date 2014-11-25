class @SignUpModal extends Modal

  constructor: (@options = {}) ->
    @template = Handlebars.compile($("#sign-up-modal-template").html())
    @$modal = $(@template())

    @_bindSubmit()

    super(@$modal, @options)

  _bindSubmit: ->
    @$modal.find("form").submit (e) =>
      e.preventDefault()
      $form = $(e.target)

      $.ajax
        type: "POST"
        url: $form.attr("action")
        data: $form.serialize()
        success: (data) =>
          window.location = $form.data("post-sign-in-path")
        error: (e) =>
          errors = $.parseJSON(e.responseText)["errors"]
          @_renderErrors(errors)
