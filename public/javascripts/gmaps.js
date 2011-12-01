/*
 * gmap.js - functions for Google Maps API
 * This script is loaded last
 */

var map = null;
var infoWindow = new google.maps.InfoWindow();
var markers = [];
var infoWindowContents = [];
// defaulting center of the map to SF if permission to current location isn't given
if(!lat && !lng) {
  lat = 37.762573;
  lng = -122.432327;
}
var latlng = new google.maps.LatLng(lat,lng);

/*
 * Makes a blue marker for the user's current location
 */
function setMyMarker(lat,lng) {
  myLocation = new google.maps.LatLng(lat,lng);
  myMarker = new google.maps.Marker({
    map: map,
    icon: new google.maps.MarkerImage('http://maps.google.com/mapfiles/ms/icons/blue-dot.png'),
    title: 'Your current location',
  });
  myMarker.setPosition(myLocation);
  map.setCenter(myLocation);
}

/*
 * Creates a Google Maps marker
 * http://code.google.com/apis/maps/documentation/javascript/reference.html#Marker
 */
function createMarker(loc) {
  markerOptions = ({
    map: map,
    icon: new google.maps.MarkerImage('http://maps.google.com/mapfiles/ms/icons/red-dot.png'),
    position: new google.maps.LatLng(loc.latitude, loc.longitude),
    title: loc.name,
  });
  return new google.maps.Marker(markerOptions);
}

/*
 * The HTML for each marker's infowindow
 */
function createContent(loc) {
  var traffic_block = loc.name + '\' straffic pattern goes here';
  var info_block = '<h3>' + loc.name + '</h3><br>' + loc.address;
  var other_block = 'None so far';

  var content = '<div id="iw' + loc.id + '" class="infowindow"><ul>'
  content += '<li><a href="#tab1" class="selected">Traffic</a></li>'
  content += '<li><a href="#tab2">Information</a></li>'
  content += '<li><a href="#tab3">Other</a></li></ul>'
  content += '<div id="tab1" style="display: block; ">'+ traffic_block + '</div>'
  content += '<div id="tab2" style="display: none; ">' + info_block + '</div>'
  content += '<div id="tab3" style="display: none; ">' + other_block + '</div></div>'
  //content += '<script type="text/javascript">$("#iw' + loc.id + '").idTabs();</script>'
  return content
}

/*
 * Clears out existing markers and make new ones, with the locations json
 */
function updateMarkers(locations) {
  // deleting all the existing markers and infowindows
  $.each(markers, function(i,v) { v.setMap(null); });
  infoWindowContents = [];
  markers = []

  // populating markers onto the map
  $.each(locations, function(i, location) {
    loc = location.location;
    markers.push(createMarker(loc));
    infoWindowContents.push(createContent(loc));
  });

  // Linking markers with one info window
  $.each(markers, function(i, marker) {
    google.maps.event.addListener(marker, 'click', function() {
      infoWindow.setContent(infoWindowContents[i]);
      infoWindow.open(map, this);
      map.setCenter(marker.getPosition());
    });
    google.maps.event.addListener(infoWindow, 'domready', function() {
      locid = $(infoWindowContents[i]).attr('id');
      $('#'+locid).idTabs();
    });

  });

  // when the user hovers over the results on the left side, the infowindow pops up
  $("#results div").each(function(i) {
    $(this).click(function() {
      infoWindow.setContent(infoWindowContents[i]);
      infoWindow.open(map,markers[i]);
      map.setCenter(markers[i].getPosition());
    });
  });
}

/*
 * Calculates the height of the main div (#searchResults), so it fits the whole page
 *
 */
function resizeMain() {
  height = $(window).height();
  other = $("header").height() + $("#searchBox").height() + $("footer").height() + 50; /* 50 is arbitrary, to account for paddings (which are in ems) */
  $("#searchResults").css('height', height-other);
}

/*
 * Initialization function that gets called at load time
 */
function initialize() {
  map = new google.maps.Map(document.getElementById("map_canvas"), {
    streetViewControl: false,
    panControl: false,
    disableDoubleClickZoom: false,
    mapTypeControl: false,
    zoom: 13,
    center: latlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    zoomControlOptions: { style: google.maps.ZoomControlStyle.LARGE }
  });

  // close the info window when the user clicks on the map
  google.maps.event.addListener(map, 'click', function() {
    infoWindow.close();
  });
}

google.maps.event.addDomListener(window, 'load', initialize);

// fit the searchResults div
$(function() {
  resizeMain();
  $(window).resize(function() {
    resizeMain();
  });
});
