class @SignInModal extends Modal

  constructor: (@options = {}) ->
    @template = Handlebars.compile($("#sign-in-modal-template").html())
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
          @$modal.find(".errors").html("Invalid email address or password. Please try again.")
