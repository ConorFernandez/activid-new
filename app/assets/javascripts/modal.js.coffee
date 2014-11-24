class @Modal

  constructor: (@$modal) ->

  open: ->
    @$modal.appendTo($("body"))
    @_bindCloseEvents(@close)

  close: ->
    @$modal.remove()

  _bindCloseEvents: (callback) ->
    @_bindEscape(callback)
    @_bindClickOutsideTarget(callback)

  _bindEscape: (callback) ->
    $(document).on 'keyup', (event) =>
      callback.call(this) if event.keyCode == 27

  _bindClickOutsideTarget: (callback) ->
    @$modal.on 'click', (event) =>
      callback.call(this) if $(event.target).hasClass('modal-wrapper')
