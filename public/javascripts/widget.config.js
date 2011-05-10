var isNumeric = function(input) {
   return (input - 0) == input && input.length > 0;
};

var getEmbed = function(widget) {
  return '<script src="http://opengovernment.org/assets/widget.js" type="text/javascript"></scr' + 'ipt>\n' +
'<script>\n' +
'new OG.Widget({\n' +
'  version: 1,\n' + 
'  type: \'' + widget.type + '\',\n' +
'  state: \'' + widget.state + '\',\n' +
'  width: \'' + $('#widgetWidth').val() + '\',\n' +
'  theme: {\n' +
'    background: \'' + widget.theme.background + '\',\n' +
'    color: \'' + widget.theme.color + '\',\n' +
'    links: \'' + widget.theme.links + '\'\n' + 
'  }\n' +
'}).render();\n' +
'</scr' + 'ipt>\n';
};

var refreshEmbed = function(widget) {
  $('#embed-code').val(getEmbed(widget));
};

// Select all text when clicking on embed code box
$('#embed-code').click(function() {
  this.select();
});


var refreshTheme = function(widget) {
  widget.setTheme({
    background: '#' + $('#widgetBG').val(),
    color: '#' + $('#widgetColor').val(),
    links: '#' + $('#widgetLinks').val()
  }).reformat();

  refreshEmbed(widget);
}

$(function() {
  jscolor.init();
  
  $('#widget_tabs').tabs();

  // Fill in the basic embed code.
  refreshEmbed(testWidget);

  $('#widgetWidth').change(function() {
    if (isNumeric($(this).val())) {
      refreshTheme(testWidget);
    } else {  
      alert("Width must be a number");
      return false;
    }
  });

  // Turn on the color pickers
  $('.widgetVar').change(function() {
    refreshTheme(testWidget);
  });

});
