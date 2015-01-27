# $ ->
      
#   #-----------  Text Carousel  -----------#
  
#   setInterval( ->
#     current = $('.carousel-block.selected')
#     next = if current.next('.carousel-block').length then current.next('.carousel-block') else $('.carousel-block').first()
#     current.removeClass('selected')
#     next.addClass('selected')
#   , 4500) unless !$('.carousel-wrapper')