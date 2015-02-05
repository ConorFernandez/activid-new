$ ->

  #-----------  FAQ Hide / Show  -----------#

  $('.static.faq p').toggle(350)

  $('.static.faq h5').click ->
    $(@).toggleClass('selected').next().toggle(150)