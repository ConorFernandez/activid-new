class @SignUpModal extends Modal

  constructor: (@options = {}) ->
    @template = Handlebars.compile($("#sign-up-modal-template").html())
    @$modal = $(@template(inescapable: @options.inescapable))

    @_bindLinks()
    @_bindSubmit()

    super(@$modal, @options)

  _bindSubmit: ->
    @$modal.find("form").submit (e) =>
      @_disableSubmit()
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
          @_enableSubmit()

  _renderErrors: (errors) ->
    errorStrings = Object.keys(errors).map (key) ->
      " #{key} #{errors[key][0]}"

    @$modal.find(".errors").html("error: " + errorStrings.toString())

  _disableSubmit: ->
    @$modal.find("button.submit").prop("disabled", true)

  _enableSubmit: ->
    @$modal.find("button.submit").prop("disabled", false)

  _bindLinks: ->
    @$modal.find("a.sign-in").click (e) =>
      @close()
      new SignInModal(@options).open()
