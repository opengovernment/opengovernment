var isNumeric = function(input) {
   return (input - 0) == input && input.length > 0;
};

var getEmbed = function(widget) {
  return '<script src="http://opengovernment.org/assets/widget.js" type="text/javascript"></scr' + 'ipt>\n' +
'<script>\n' +
'new OG.Widget(' + JSON.stringify(widget.getOptions(), null, '\t') + ').render();\n' +
'</scr' + 'ipt>\n';
};

var refreshEmbed = function(widget) {
  $('#embed-code').val(getEmbed(widget));
};

var refreshTheme = function(widget) {
  widget.setTheme({
    background: '#' + $('#widgetBG').val(),
    color: '#' + $('#widgetColor').val(),
    header: '#' + $('#widgetHeader').val(),
    links: '#' + $('#widgetLinks').val()
  }).setWidth($('#widgetWidth').val());

  // Set additional parameters relevant to specific widgets
  if (widget.type == 'bill_status') {
    var widgetBill = $('#widgetBillData').data('bill');
    var widgetSession = $('#widgetBillData').data('session');
    widget.setBill({
      session: widgetSession,
      number: widgetBill
    });
  }

  widget.reformat();

  refreshEmbed(widget);
}

$(function() {
  jscolor.init();

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

  // Select all text when clicking on embed code box
  $('#embed-code').click(function() {
    this.select();
  });

  $('#embed-code').select(function() {
    this.select();
  });

});
