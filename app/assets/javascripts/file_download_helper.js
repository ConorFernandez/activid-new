// manages multi-file downloads on the views/project/_files partial 

var downloadAll; // takes a JQuery selector as string such as ".downloadable" or ".downloadable-image"

downloadAll = function (event) { 
  event.preventDefault(); 
  $(event.data.selector).multiDownload({ delay: 500 }); // delay prevents "multiple file downloads: allow? yes/no" warning in some browsers
  $(event.data.selector).css("background-color", "yellow");
  setTimeout(function(){ $(event.data.selector).css("background-color", "inherit");;}, 250);
}; 

$( document ).ready(function() {
  $("#download-all-button").on("click", {selector: ".downloadable"}, downloadAll);
  $("#download-images-button").on("click", {selector: ".downloadable-image"}, downloadAll);
  $("#download-video-button").on("click", {selector: ".downloadable-video"}, downloadAll);
  $("#download-audio-button").on("click", {selector: ".downloadable-audio"}, downloadAll);
});

