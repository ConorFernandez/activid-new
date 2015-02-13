$ ->
      
  #-----------  Gallery Carousel Actions  -----------#
  
  warpper   = $('.video-gallery')
  moveLeft  = '.move-left'
  moveRight = '.move-right'

  warpper.on 'click touch', moveLeft, _.throttle( (event) ->
    target = $(event.target).parent()
    return false if target.hasClass('disabled')
    slideGallery target.siblings('.gallery-wrapper')
  , 500)

  warpper.on 'click touch', moveRight, _.throttle( (event) ->
    target = $(event.target).parent()
    return false if target.hasClass('disabled')
    slideGallery target.siblings('.gallery-wrapper'), false
  , 500)

  $(window).resize _.debounce( ->
    $('.gallery-wrapper').each -> resetGallery($(@))
  , 500)

  #-----------  Gallery Setups  -----------#

  $('.gallery-wrapper').each ->
    videos = $(@).children('.gallery-block').length
    $(@).data
      step  : 0
      count : videos

  #-----------  Gallery Carousel  -----------#

  slideGallery = (gallery, direction = true) ->
    stepWidth = parseInt(gallery.children('.gallery-block').outerWidth(true))
    nextStep  = if direction then gallery.data('step') + 1 else gallery.data('step') - 1

    moveTo = nextStep * stepWidth
    gallery.animate(left: -moveTo).data(step: nextStep)

    checkBounds(gallery, nextStep)

  checkBounds = (gallery) ->
    maxBounds  = gallery.data('count') - 3
    leftArrow  = gallery.siblings(moveLeft)
    rightArrow = gallery.siblings(moveRight)

    if gallery.data('step') <= 0 
      rightArrow.addClass('disabled')
    else
      rightArrow.removeClass('disabled')

    if gallery.data('step') >= maxBounds 
      leftArrow.addClass('disabled')
    else
      leftArrow.removeClass('disabled')

  #-----------  Gallery Resets  -----------#

  resetGallery = (gallery) ->
    stepWidth = parseInt(gallery.children('.gallery-block').outerWidth(true))
    leftReset = stepWidth * gallery.data('step')

    gallery.animate(left: -leftReset)
    checkBounds(gallery)