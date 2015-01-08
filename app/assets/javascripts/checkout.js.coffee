stripeResponseHandler = (status, response) ->
  $form = $("form.checkout")

  if response.error
    $form.find(".payment-errors").text response.error.message
    $form.find("button").prop "disabled", false
  else
    $form.append $("<input>", type: "hidden", name: "stripe_token", value: response.id)
    $form.get(0).submit()

updateTotalPrice = ($totalPrice) ->
  total = $totalPrice.data("base-price")

  $("select.price-select").each (i, select) ->
    price = $(select).find("option:selected").data("price")
    priceContainer = $(select).closest("td").siblings()[0]
    $(priceContainer).html("$#{price / 100}")
    total += price

  $totalPrice.html("$#{total / 100}")

$ ->
  totalPrice = $("#total-price")

  if totalPrice.length > 0
    updateTotalPrice(totalPrice)
    $("select.price-select").change ->
      updateTotalPrice(totalPrice)

  $("form.checkout").submit (event) ->
    $form = $(this)

    unless $form.find(".cc-card input").prop("disabled")
      $form.find("button").prop("disabled", true)

      # split expiration date into year and month
      exp = $form.find("input#stripe-exp").val().split("/")
      $form.find("input#stripe-exp-month").val(exp[0])
      $form.find("input#stripe-exp-year").val(exp[1])

      Stripe.card.createToken($form, stripeResponseHandler)

      return false

  $("form.checkout input[name=stripe_card_id]:radio").change (e) ->
    $input = $(e.target)
    $form = $input.parents("form:first")

    if $(e.target).val().length == 0
      # user select "new card"
      $form.find(".cc-card input, .cc-exp input, .cc-ccv input").prop("disabled", false)
    else
      $form.find(".cc-card input, .cc-exp input, .cc-ccv input").prop("disabled", true)
