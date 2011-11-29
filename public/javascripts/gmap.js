/*
 * This script is loaded last
 */

var map = null;
var infoWindow = new google.maps.InfoWindow();
var markerArray = [];
// defaulting center of the map to SF
if(!lat && !lng) {
  lat = 37.762573;
  lng = -122.432327;
}
var latlng = new google.maps.LatLng(lat,lng);

function makeMarker(options) {
  var pushPin = new google.maps.Marker({map:map});
  pushPin.setOptions(options);
  google.maps.event.addListener(pushPin, 'click', function() {
    infoWindow.setOptions(options);
    infoWindow.open(map, pushPin);
    $(options.locid).idTabs();
  });
  markerArray.push(pushPin);
  return pushPin;
}

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

function createContent(loc) {
  var traffic_block = 'traffic pattern goes here';
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

function updateMarkers(locations) {
  // deleting all the existing markers
  for(var i=0; i<markerArray.length; i++) {
    markerArray[i].setMap(null);
  }

  // populating markers onto the map
  for(var i in locations) {
    loc = locations[i].location;
    makeMarker({
      icon: new google.maps.MarkerImage('http://maps.google.com/mapfiles/ms/icons/red-dot.png'),
      position: new google.maps.LatLng(loc.latitude, loc.longitude),
      title: loc.name,
      content: createContent(loc),
      locid: '#iw' + loc.id + ' ul'
    });
  }

  // when the user hovers over the results on the left side, the infowindow pops up
  $("#results div").each(function(index) {
    $(this).hover(function() {
      console.log(index);
      infoWindow.open(map,markerArray[index]);
    });
  });
}

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
