$ ->

  #-----------  Mobile Sidebar  -----------#

  menu = $('.global-mobile-menu')
  wrapper = $('.global-wrapper')
  trigger = $('.mobile-menu-trigger')

  trigger.on 'click touchend', (e) ->
    if menu.hasClass('mobile-menu-active')
      menu.removeClass('mobile-menu-active')
      wrapper.removeClass('mobile-menu-active')
    else
      menu.addClass('mobile-menu-active')
      wrapper.addClass('mobile-menu-active')

    e.preventDefault()

  #-----------  Dropdown  -----------#

  $('.dropdown-wrapper').on 'touchend', (e) ->
    $(@).toggleClass('activated')
    e.preventDefault()
