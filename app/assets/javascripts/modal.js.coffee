class @Modal

  constructor: (@$modal, @options = {}) ->

  open: ->
    @$modal.appendTo($("body"))

    setTimeout ( =>
      @$modal.addClass("show-modal")
    ), 0

    @_bindCloseEvents(@close) unless @options.inescapable

  close: ->
    @$modal.removeClass("show-modal").delay(330).queue (next) ->
      $(@).remove()
      next()

  _bindCloseEvents: (callback) ->
    @_bindEscape(callback)
    @_bindCloseButton(callback)
    @_bindClickOutsideTarget(callback)

  _bindEscape: (callback) ->
    $(document).on 'keyup', (event) =>
      callback.call(this) if event.keyCode == 27

  _bindCloseButton: (callback) ->
    @$modal.on 'click', '.close-modal', (event) =>
      callback.call(this)

  _bindClickOutsideTarget: (callback) ->
    @$modal.on 'click', (event) =>
      callback.call(this) if $(event.target).hasClass('modal-wrapper')
