var search_url = '/locations?q=';
var lat;
var lng;

var daily_options = {
xaxis: {
  ticks: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23],
  tickLength: 0
},
  yaxis: { ticks: [0.0, 0.2, 0.4, 0.6, 0.8, 1] }
};

var weekly_options = {
xaxis: {
  ticks: [[0, "Mon"], [1, "Tues"], [2, "Wed"], [3, "Thurs"], [4, "Fri"], [5, "Sat"], [6, "Sun"]],
  tickLength: 0
},
  yaxis: { ticks: [0.0, 0.2, 0.4, 0.6, 0.8, 1] }
};

function getLocation()
{
  if (navigator.geolocation)
  {
    navigator.geolocation.getCurrentPosition(function (position) {
      lat = position.coords.latitude;
      lng = position.coords.longitude;
    });
  }
}

function search()
{
  var data = $('#q').val();

  var url = search_url + encodeURI(data);
  url = url + '&lat=' + lat;
  url = url + '&lng=' + lng;
  
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
  });
}

function displayDetails(loc)
{
  $('#info').empty();

  $('#info').append('<h1>'+loc.name+'</h1>');
  $('#info').append('<p>'+loc.address+'</p>');

  var daily_data = [];
  for(i=0; i<24; i++) { daily_data[i] = [i,loc.daily[i]] };

  $('#info').append('<h3>Daily Traffic</h3>');
  daily = $( document.createElement('div') );
  daily.attr('id', 'daily');
  daily.appendTo($('#info'));
  $.plot( $('#daily'), [
    {
      data: daily_data,
      bars: { show: true, align: 'center' }
    }
  ], daily_options);

  var weekly_data = [];
  for(i=0; i<7; i++) { weekly_data[i] = [i,loc.weekly[i]] };
  $('#info').append('<h3>Weekly Traffic</h3>');
  weekly = $( document.createElement('div') );
  weekly.attr('id', 'weekly');
  weekly.appendTo($('#info'));
  $.plot( $('#weekly'), [
    {
      data: weekly_data,
      bars: { show: true, align: 'center' }
    }
  ], weekly_options);
}

$(document).ready(function () {
  getLocation();
  $('#submit').click(function () { search(); });
});

