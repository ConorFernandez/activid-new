#-----------  Init  -----------#

userId    = 'actividfilms'
urlPrefix = 'https://gdata.youtube.com/feeds/api'

galleryTemplate  = ''
featuredTemplate = ''

$ ->

  return false unless $('section.video-gallery').length

  galleryTemplate = Handlebars.compile $("#gallery-template").html()
  fetchPlaylists()

  # featuredTemplate = Handlebars.compile $("#featured-template").html()
  # fetchFeatured()

#-----------  Grab Playlists  -----------#

fetchPlaylists = ->
  $.ajax
    url: "#{urlPrefix}/users/#{userId}/playlists?&v=2&alt=jsonc"
    success: (data) =>
      for playlist in data.data.items
        if playlist.size >= 3
          fetchVideos
            id      : playlist.id
            size    : playlist.size
            title   : playlist.title
            slug    : slugify(playlist.title)
            hasMore : (playlist.size > 3)

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
      renderPlaylist playlist, videos.reverse()

#-----------  Grab Featured Video  -----------#

fetchFeatured = ->
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
      renderFeatured playlist, videos.reverse()

#-----------  Render Playlists  -----------#

renderPlaylist = (playlist, videos) ->
  gallery = galleryTemplate({playlist: playlist, videos: videos})
  $(gallery).appendTo($('section.video-gallery'))
    .find('.gallery-wrapper').data
      step  : 0
      count : videos.length
      
#-----------  Render Featured  -----------#

renderFeatured = (video) ->
  featured = featuredTemplate({video: video})
  $(featured).prependTo($('section.video-gallery'))

#-----------  Helper Functions  -----------#

slugify = (text) ->
  text.toString().toLowerCase()
    .replace(/\s+/g, '-')
    .replace(/[^\w\-]+/g, '')
    .replace(/\-\-+/g, '-')
    .replace(/^-+/, '')
    .replace(/-+$/, '')
