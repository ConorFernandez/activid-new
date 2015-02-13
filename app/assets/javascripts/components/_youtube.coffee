#-----------  Init  -----------#

template  = ''
userId    = 'actividfilms'
urlPrefix = 'https://gdata.youtube.com/feeds/api'

$ ->

  return false unless $('section.video-gallery').length

  template = Handlebars.compile $("#gallery-template").html()
  fetchPlaylists()

#-----------  Grab Playlists  -----------#

fetchPlaylists = ->
  $.ajax
    url: "#{urlPrefix}/users/#{userId}/playlists?&v=2&alt=jsonc"
    success: (data) =>
      for playlist in data.data.items
        if playlist.size >= 3
          fetchVideos
            id     : playlist.id
            size   : playlist.size
            title  : playlist.title
            slug   : slugify(playlist.title)

#-----------  Assemble Videos  -----------#

fetchVideos = (playlist) ->
  videos = []
  $.ajax
    url: "#{urlPrefix}/playlists/#{playlist.id}?&v=2&alt=jsonc"
    success: (data) =>
      for video in data.data.items
        videos.push { 
          id    : video.video.id
          title : video.video.title
          img   : video.video.thumbnail.hqDefault
        }
      renderPlaylist playlist, videos

#-----------  Render Playlists  -----------#

renderPlaylist = (playlist, videos) ->
  gallery = template({playlist: playlist, videos: videos})
  $(gallery).appendTo($('section.video-gallery'))
    .find('.gallery-wrapper').data
      step       : 0
      count      : videos.length
      leftArrow  : $(gallery).find('.move-left')
      rightArrow : $(gallery).find('.move-right')

#-----------  Helper Functions  -----------#

slugify = (text) ->
  text.toString().toLowerCase()
    .replace(/\s+/g, '-')
    .replace(/[^\w\-]+/g, '')
    .replace(/\-\-+/g, '-')
    .replace(/^-+/, '')
    .replace(/-+$/, '')
