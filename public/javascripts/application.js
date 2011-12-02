var search_url = '/locations?q=';
var lat;
var lng;


function search()
{
  var data = $('#q').val();

  var url = search_url + encodeURI(data);
  // variables updated in gmaps.js
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

      result.appendTo('#results');
    });

    updateMarkers(data);
  });
}

$(document).ready(function () {
  $('#submit').click(function () { search(); });
  $('#q').bind("keydown", function(e) {
    if (e.keyCode == 13) { search(); }
  });
  $('#q').focus();
});

