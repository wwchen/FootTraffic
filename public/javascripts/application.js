var search_url = '/locations?q=';

function search()
{
  var data = $('#q').val();

  var url = search_url + encodeURI(data);
  
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
  $('#submit').click(function () { search(); });
});

