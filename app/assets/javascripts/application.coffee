# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https:#github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require jquery.ui.widget
#= require jquery.fileupload
#= require jquery.multidownload
#= require file_download_helper
#= require handlebars
#= require lowdash
#= require stripe
#= require_tree .

$ ->

  #-----------  Flash Notices  -----------#

  flash = $('.global-notices')

  flash.on 'click touchend', 'i', (e) ->
    e.preventDefault()
    flash.animate {height: 0, paddingTop: 0, paddingBottom: 0}, 300, ->
      flash.remove()

$(document).ready ->

  #-----------  Footer Bugfix  -----------#

  footerFloat = ->
    windowHeight = $(window).height()
    headerHeight = $('.global-header').outerHeight(true)
    footerHeight = $('.global-footer').outerHeight(true)
    minHeight = windowHeight - headerHeight - footerHeight
    $('.global-content').css({minHeight: minHeight})
    
  footerFloat()

  $(window).resize ->
    footerFloat()

  #-----------  Youtube Modal Trigger  -----------#

  $(document).on 'click touch', '.youtube-block', (event) ->
    yid = $(@).data('yid')
    new YoutubeModal({yid: yid}).open()

