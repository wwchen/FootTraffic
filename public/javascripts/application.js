var search_url = '/locations?q=';
var lat;
var lng;

function getLocation()
{
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function (position) {
      lat = position.coords.latitude;
      lng = position.coords.longitude;
    });
  }
  else {
    // defaulting center of the map to SF if permission to current location isn't given
    lat = 37.762573;
    lng = -122.432327;
  }
  console.log('loaded!');
  console.log(lat);
  console.log(lng);
}

function search()
{
  var data = $('#q').val();

  var url = search_url + encodeURI(data);
  url = url + '&lat=' + lat;
  url = url + '&lng=' + lng;
  
  if($('input:radio[name=busy]:checked').val() == 'busy') {
    url = url + '&busy=true'
  }
  
  // Clear the results div
  $('#results').empty();


  $.getJSON(url, function (data) {
    $.each(data, function(key, value) {
      var result = $( document.createElement('div') );
      result.attr('class', 'result');

      var name = $( document.createElement('h3') );
      name.text(value.location.name);
      name.appendTo(result);

      var address = $( document.createElement('span') );
      address.text(value.location.address);
      address.appendTo(result);

      result.click(function () { displayDetails(value.location) });

      result.appendTo('#results');
    });

    updateMarkers(data);
  });
}

function displayDetails(loc)
{
  var latlng = loc.latitude + ',' + loc.longitude
  var url = 'http://maps.googleapis.com/maps/api/staticmap?center=' + latlng + '&zoom=16&size=550x100&markers=color:blue%7C' + latlng + '&sensor=false'
  //$('#info').empty();

  //$('#info').append('<h1>'+loc.name+'</h1>');
  //$('#info').append('<p>'+loc.address+'</p>');
  //$('#info').append('<h4>'+loc.id+'</h4>');
  //$('#info').append('<img src="'+url+'" />');

  //$('#info').append('<h3>Other info</h3>');
  //$('#info').append(loc.created_at + '<br>');
  //$('#info').append(loc.types + '<br>');
  //$('#info').append(loc.website + '<br>');
  //$('#info').append(loc.place_type + '<br>');

  $('#info').append('<h3>Other info</h3>');
  $('#info').append(loc.created_at + '<br>');
  $('#info').append(loc.types + '<br>');
  $('#info').append(loc.website + '<br>');
  $('#info').append(loc.place_type + '<br>');

  var daily_data = [];
  for(i=0; i<24; i++) { daily_data[i] = [i,loc.daily[i]] };

  // Convert shenanigans to local timezone shenanigans
  date = new Date();
  offset = date.getTimezoneOffset()/60;
  daily_data = daily_data.map(function (i) {
    return [Mod((i[0]-offset),24), i[1]];
  });
  //console.log(daily_data.map(function(i){return i[0];}));
  //console.log(daily_data.map(function(i){return i[1];}));

  var weekly_data = [];
  for(i=0; i<7; i++) { weekly_data[i] = [i,loc.weekly[i]] };
  //$('#info').append('<h3>Weekly Traffic</h3>');
  //weekly = $( document.createElement('div') );
  //weekly.attr('id', 'weekly');
  //weekly.appendTo($('#info'));
  //$.plot( $('#weekly'), [
  //  {
  //    data: weekly_data,
  //    bars: { show: true, align: 'center' }
  //  }
  //], weekly_options);
}

$(document).ready(function () {
  getLocation();
  $('#submit').click(function () { search(); });
  $('#q').bind("keydown", function(e) {
    if (e.keyCode == 13) { search(); }
  });
  $('#q').focus();
});

