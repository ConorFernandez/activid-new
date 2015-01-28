$ ->

  tabs = $('[data-tab]')
  content = $('[data-tab-content]')

  #-----------  Tabing  -----------#

  tabs.on 'click', ->
    tag = $(@).data('tab')
    oldContent = $("[data-tab-content].selected")
    newContent = $("[data-tab-content='#{tag}']")

    tabs.removeClass('selected')
    $("[data-tab='#{tag}']").addClass('selected')

    oldContent.removeClass('selected')
    newContent.addClass('selected')

  $("[data-tab].selected").click()
