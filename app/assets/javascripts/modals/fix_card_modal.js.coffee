class @FixCardModal extends Modal

  constructor: (@options = {}) ->
    @template = Handlebars.compile($("#fix-card-modal-template").html())
    @$modal = $(@template(@options))

    super(@$modal, @options)

    @_bindSubmit()


  _bindSubmit: ->
    modal = this

    @$modal.find("form").submit (event) ->
      $form = $(this)

      unless $form.find(".cc-card input").prop("disabled")
        $form.find("button").prop("disabled", true)

        # split expiration date into year and month
        exp = $form.find("input#stripe-exp").val().split("/")
        $form.find("input#stripe-exp-month").val(exp[0])
        $form.find("input#stripe-exp-year").val(exp[1])

        Stripe.card.createToken($form, modal.stripeResponseHandler)

        return false

  stripeResponseHandler: (status, response) ->
    $form = $(".fix-card-modal form")

    if response.error
      $form.find(".payment-errors").text response.error.message
      $form.find("button").prop "disabled", false
    else
      $form.append $("<input>", type: "hidden", name: "stripe_token", value: response.id)
      $form.get(0).submit()
