var search_url = '/locations?q=';
var lat;
var lng;

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

      result.appendTo('#results');
    });
  });
}

$(document).ready(function () {
  getLocation();
  $('#submit').click(function () { search(); });
});

