$(document).ready ->

  text = $('.special-instructions')
      
  #-----------  Initializer  -----------#

  for block in text
    $(block).addClass('longtext') unless $(block).height() < 300

  $(window).resize (e) ->
    for block in $('.longtext.revealed')
      height = $(block)[0].scrollHeight + 20
      $(block).css({maxHeight: height})

  #-----------  Longtext Revealer  -----------#

  $('.longtext').on 'click', (e) ->
    $(@).toggleClass('revealed')

    height = $(@)[0].scrollHeight + 20

    if $(@).hasClass('revealed')
      $(@).css({maxHeight: height})
    else 
      $(@).css({maxHeight: '11.25em'})
