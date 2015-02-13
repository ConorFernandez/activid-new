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
      for jsonObj in data.data.items
        fetchVideos parsePlaylistJSON(jsonObj) unless jsonObj.size < 3

#-----------  Assemble Videos  -----------#

fetchVideos = (playlist) ->
  videos = []
  $.ajax
    url: "#{urlPrefix}/playlists/#{playlist.id}?&v=2&alt=jsonc"
    success: (data) =>
      for jsonObj in data.data.items
        videos.push parseVideoJSON(jsonObj.video)
      renderPlaylist playlist, videos.reverse()

#-----------  Grab Featured Video  -----------#

# fetchFeatured = ->
#   videos = []
#   $.ajax
#     url: "#{urlPrefix}/users/#{userId}?&v=2&alt=json"
#     success: (data) =>
#       console.log data
#       # for jsonObj in data.data.items
#       #   renderFeatured parseVideoJSON(jsonObj)

#-----------  Render Playlists  -----------#

renderPlaylist = (playlist, videos) ->
  gallery = galleryTemplate({playlist: playlist, videos: videos})
  $(gallery).appendTo($('section.video-gallery'))
    .find('.gallery-wrapper').data
      step  : 0
      count : videos.length

#-----------  Render Featured  -----------#

# renderFeatured = (video) ->
#   featured = featuredTemplate({video: video})
#   $(featured).prependTo($('section.video-gallery'))

#-----------  Helper Functions  -----------#

parsePlaylistJSON = (jsonObj) ->
  return {
    id      : jsonObj.id
    size    : jsonObj.size
    title   : jsonObj.title
    slug    : slugify(jsonObj.title)
    hasMore : (jsonObj.size > 3)
  }

parseVideoJSON = (jsonObj) ->
  return {
    id    : jsonObj.id
    title : jsonObj.title
    img   : jsonObj.thumbnail.hqDefault
  }

slugify = (text) ->
  return text.toString().toLowerCase()
    .replace(/\s+/g, '-')
    .replace(/[^\w\-]+/g, '')
    .replace(/\-\-+/g, '-')
    .replace(/^-+/, '')
    .replace(/-+$/, '')
