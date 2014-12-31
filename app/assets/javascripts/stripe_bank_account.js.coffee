stripeBankAccountResponseHandler = (status, response) ->
  $form = $("form.stripe-bank-account")

  if response.error
    $form.find(".stripe-errors").text response.error.message
    $form.find("button").prop "disabled", false
  else
    $form.append $("<input>", type: "hidden", name: "bank_account_token", value: response.id)
    $form.get(0).submit()

$ ->
  $("form.stripe-bank-account").submit (event) ->
    $form = $(this)

    routingNumber = $form.find(".routing-number").val()
    accountNumber = $form.find(".account-number").val()

    if !!routingNumber || !!accountNumber
      $form.find("button").prop("disabled", true)

      Stripe.bankAccount.createToken({
        country: "US",
        routingNumber: routingNumber,
        accountNumber: accountNumber
      }, stripeBankAccountResponseHandler)

      return false
