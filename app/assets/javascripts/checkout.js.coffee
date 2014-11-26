stripeResponseHandler = (status, response) ->
  $form = $("form.checkout")

  if response.error
    $form.find(".payment-errors").text response.error.message
    $form.find("button").prop "disabled", false
  else
    $form.append $("<input>", type: "hidden", name: "payment_method_token", value: response.id)
    $form.get(0).submit()

$ ->
  $("form.checkout").submit (event) ->
    $form = $(this)
    $form.find("button").prop("disabled", true)

    # split expiration date into year and month
    exp = $form.find("input#stripe-exp").val().split("/")
    $form.find("input#stripe-exp-month").val(exp[0])
    $form.find("input#stripe-exp-year").val(exp[1])

    Stripe.card.createToken($form, stripeResponseHandler)

    return false
