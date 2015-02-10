$ ->
      
  #-----------  Gallery Carousel Actions  -----------#
  
  moveLeft = $('.move-left')
  moveRight = $('.move-right')

  moveLeft.click _.throttle( ->
    return false if $(@).hasClass('disabled')
    slideGallery $(@).siblings('.gallery-wrapper')
  , 500)

  moveRight.click _.throttle( ->
    return false if $(@).hasClass('disabled')
    slideGallery $(@).siblings('.gallery-wrapper'), false
  , 500)

  $(window).resize _.debounce( ->
    $('.gallery-wrapper').each -> resetGallery($(@))
  , 500)

  #-----------  Gallery Setups  -----------#

  $('.gallery-wrapper').each ->
    videos = $(@).children('.gallery-block').length

    $(@).data
      step       : 0
      count      : videos
      leftArrow  : $(@).siblings('.move-left')
      rightArrow : $(@).siblings('.move-right')

  #-----------  Gallery Carousel  -----------#

  slideGallery = (gallery, direction = true) ->
    stepWidth = parseInt(gallery.children('.gallery-block').outerWidth(true))
    nextStep  = if direction then gallery.data('step') + 1 else gallery.data('step') - 1

    moveTo = nextStep * stepWidth
    gallery.animate(left: -moveTo).data(step: nextStep)

    checkBounds(gallery, nextStep)

  checkBounds = (gallery) ->
    maxBounds = gallery.data('count') - 3

    if gallery.data('step') <= 0 
      gallery.data('rightArrow').addClass('disabled')
    else
      gallery.data('rightArrow').removeClass('disabled')

    if gallery.data('step') >= maxBounds 
      gallery.data('leftArrow').addClass('disabled')
    else
      gallery.data('leftArrow').removeClass('disabled')

  #-----------  Gallery Resets  -----------#

  resetGallery = (gallery) ->
    stepWidth = parseInt(gallery.children('.gallery-block').outerWidth(true))
    leftReset = stepWidth * gallery.data('step')

    gallery.animate(left: -leftReset)
    checkBounds(gallery)