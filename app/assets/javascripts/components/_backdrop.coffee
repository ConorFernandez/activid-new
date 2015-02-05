$ ->
      
  #-----------  Backdrop Carousel  -----------#
  
  setInterval( ->
    current = $('.backdrop-block.selected')
    next = if current.next('.backdrop-block').length then current.next('.backdrop-block') else $('.backdrop-block').first()
    current.removeClass('selected')
    next.addClass('selected')
  , 7000) unless !$('.backdrop-wrapper')