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
          window.location = $form.data("post-sign-up-path")
        error: (e) =>
          errors = $.parseJSON(e.responseText)["errors"]
          @_renderErrors(errors)

  _renderErrors: (errors) ->
    errorStrings = Object.keys(errors).map (key) ->
      " #{key} #{errors[key][0]}"

    @$modal.find(".errors").html(errorStrings.toString())
