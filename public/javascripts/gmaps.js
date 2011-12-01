/*
 * gmap.js - functions for Google Maps API (and also with Flot stuff now)
 * This script is loaded last
 */

/**
 * Global variables for Google Maps
 **/
var loc_data = null;
var map = null;
var infoWindow = new google.maps.InfoWindow();
var markers = [];
var infoWindowContents = [];

var current = -1;

/**
 * Global variables for Flot
 **/
var daily_options = {
  xaxis: {
    ticks: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23],
    tickLength: 0
  },
  yaxis: { ticks: [0.0, 0.2, 0.4, 0.6, 0.8, 1] }
};

var weekly_options = {
  xaxis: {
    ticks: [[1, "Mon"], [2, "Tues"], [3, "Wed"], [4, "Thurs"], [5, "Fri"], [6, "Sat"], [0, "Sun"]],
    tickLength: 0
  },
  yaxis: { ticks: [0.0, 0.2, 0.4, 0.6, 0.8, 1] }
};

/**
 * Functions for Flot
 **/

/*
 * Does modulous the right way
 */
function Mod(X, Y) { return X - Math.floor(X/Y)*Y }

/*
 * Makes the flot daily and weekly graphs, given the location JSON
 */
function plot_stuff(loc) {
  var daily_data = [];
  var weekly_data = [];
  for(i=0; i<24; i++) { daily_data[i] = [i,loc.daily[i]] };

  // Convert shenanigans to local timezone shenanigans
  date = new Date();
  offset = date.getTimezoneOffset()/60;
  daily_data = daily_data.map(function (i) {
    return [Mod((i[0]-offset),24), i[1]];
  });

  for(i=0; i<7; i++) { weekly_data[i] = [i,loc.weekly[i]] };

  $.plot( $('#daily'), [{
    data: daily_data,
    bars: { show: true, align: 'center' }
  }], daily_options);

  $.plot( $('#weekly'), [{
    data: weekly_data,
    bars: { show: true, align: 'center' }
  }], weekly_options);
}


/**
 * Functions for Google Maps
 **/

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
  var traffic_block = '<h3>Daily</h3><div id="daily"></div>';
  traffic_block += '<h3>Weekly</h3><div id="weekly"></div>';
  var info_block = '<h3>' + loc.name + '</h3><br>' + loc.address + '<br>';
  info_block += loc.phone ? '<br>' + loc.phone : '';
  info_block += loc.website ? '<br><a href="' + loc.website + '">' + loc.website + '</a>' : '';
  info_block += '<br>rating:<a href="' + loc.url + '">' + loc.rating + '</a>';
  info_block += loc.types ? '<br>' + loc.types : '';
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
  loc_data = locations;
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

      current = i;
    });
    google.maps.event.addListener(infoWindow, 'domready', function() {
      locid = $(infoWindowContents[i]).attr('id');
      $('#'+locid).idTabs();

      if(i == current) {
        plot_stuff(locations[i].location);
      }
    });

  });

  // when the user hovers over the results on the left side, the infowindow pops up
  $("#results div").each(function(i) {
    $(this).click(function() {
      infoWindow.setContent(infoWindowContents[i]);
      infoWindow.open(map,markers[i]);
      map.setCenter(markers[i].getPosition());

      current = i;
    });
  });
}

/*
 * Calculates the height of the main div (#searchResults), so it fits the whole page
 */
function resizeMain() {
  height = $(window).height();
  other = $("header").height() + $("#searchBox").height() + $("footer").height() + 50; /* 50 is arbitrary, to account for paddings (which are in ems) */
  $("#searchResults").css('height', height-other);
}

/*
 * Get the user's location and center the map
 */
function updateLocation() {
  if(navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      lat = position.coords.latitude;
      lng = position.coords.longitude;
      setMyMarker(lat,lng);
      map.setCenter(myLocation);
    }); 
  }
  lat = 37.762573;
  lng = -122.432327;
  setMyMarker(lat,lng);
  map.setCenter(myLocation);
}

/*
 * Initialization function that gets called at load time
 */
function initialize() {
  var latlng = new google.maps.LatLng(lat,lng);
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
  updateLocation();

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
