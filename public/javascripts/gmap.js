/*
 * gmap.js - functions for Google Maps API
 * This script is loaded last
 */

var map = null;
var infoWindow = new google.maps.InfoWindow();
var markers = [];
var infoWindowOptions = [];
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
function createMarker(options) {
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
  content += '<li><a href="#tab2" class="selected">Information</a></li>'
  content += '<li><a href="#tab3" class="selected">Other</a></li></ul>'
  content += '<div id="tab1" style="display: block; ">'+ traffic_block + '</div>'
  content += '<div id="tab2" style="display: none; ">' + info_block + '</div>'
  content += '<div id="tab3" style="display: none; ">' + other_block + '</div></div>'
  return content
}

/*
 * Clears out existing markers and make new ones, with the locations json
 */
function updateMarkers(locations) {
  // deleting all the existing markers and infowindows
  $.each(markers, function(i,v) { v.setMap(null); });
  infoWindowOptions = [];
  markers = []

  // populating markers onto the map
  for(var i in locations) {
    loc = locations[i].location;
    markers.push(createMarker(loc));
    infoWindowOptions.push(createContent(loc));
  }
  $.each(markers, function(i, marker) {
    google.maps.event.addListener(marker, 'click', function() {
      infoWindow.setContent(infoWindowOptions[i]);
      infoWindow.open(map, this);
      //$(infoWindowOptions[i].locid).idTabs();
    });
  });

  // when the user hovers over the results on the left side, the infowindow pops up
  $("#results div").each(function(index) {
    $(this).click(function() {
      console.log(index);
      infoWindow.setContent(infoWindowOptions[index]);
      infoWindow.open(map,markers[index]);
      $(markers[index].locid).idTabs();
    });
  });
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

  google.maps.event.addListener(map, 'click', function() {
    infoWindow.close();
  });
}

google.maps.event.addDomListener(window, 'load', initialize);
