filterMusicBlocks = (index) ->
  $(".music-block[data-category-index!=#{index}]").hide()
  $(".music-block[data-category-index=#{index}]").show()

$ ->
  if $("select#music_category").length > 0
    $("select#music_category").change (event) ->
      index = $(event.target).find("option:selected").data("category-index")
      filterMusicBlocks(index)

    initialIndex = $("select#music_category option:selected").data("category-index")
    filterMusicBlocks(initialIndex)

  $(".play-pause").click (e) ->
    $icon = $(e.target)
    $audio = $icon.find("audio")

    if $icon.hasClass("icon-play")
      $audio.trigger("play")
      $icon.removeClass("icon-play")
      $icon.addClass("icon-pause")
    else
      $audio.trigger("pause")
      $icon.addClass("icon-play")
      $icon.removeClass("icon-pause")

    e.preventDefault()
