// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function() {
  var hidden_field = $('input#tag');
  $('#tags a').click(function(event) {
    hidden_field.val($(this).html());
    $('#tagging_form').submit();
    event.preventDefault();
  });
});
