module HomeHelper
  DEFAULT_STATE_COLOR = "FFFFFF"
  SUPPORTED_STATE_COLOR = "FF0000"
  PENDING_STATE_COLOR = "00FF00"
  MAP_BG_COLOR = "EAF7FE"

  def us_map_image_tag
    # See http://code.google.com/apis/chart/docs/gallery/map_charts.html#statecodes
    # This should return something like <img src="http://chart.apis.google.com/chart?cht=t&chs=440x220&chd=t:0,100,50,32,60,40,43,12,14,54,98,17,70,76,18,29&chco=FFFFFF,FF0000,FFFF00,00FF00&chld=ALCACOSCUTNMARILNMWIAKIAMDTNNDOH&chtm=usa&chf=bg,s,EAF7FE">
    states = State.supported | State.pending
    chld = states.collect { |s| s.abbrev }.join
    chd = states.collect { |s| s.supported? ? "A" : "9" }
    %Q{<img src="http://chart.apis.google.com/chart?cht=t&chs=440x220&chd=s:#{chd}&chco=#{DEFAULT_STATE_COLOR},#{SUPPORTED_STATE_COLOR},#{PENDING_STATE_COLOR}&chld=#{chld}&chtm=usa&chf=bg,s,#{MAP_BG_COLOR}">}.html_safe!
  end

  def interactive_us_map_image_tag
    states = State.all
    states = states.collect {|s| [s.region_code, s.supported? , s.name]}

    data = states.to_json

    x = <<-STR
      <div id='map_canvas'></div>
      <script type='text/javascript' src='http://www.google.com/jsapi'></script>
        <script type='text/javascript'>
         google.load('visualization', '1', {'packages': ['geomap']});
         google.setOnLoadCallback(drawMap);

          function drawMap() {
            var data = new google.visualization.DataTable();
            data.addRows(2);
            data.addColumn('string', 'State');
            data.addColumn('number', 'Abbreviation');
            data.addColumn('string', 'Hover');

            data.setValue(0, 0, 'US-CA');
            data.setValue(0, 1, 300);
            data.setValue(0, 2, 'California');

            data.setValue(1, 0, 'US-FL');
            data.setValue(0, 1, 500);
            data.setValue(1, 2, 'Florida');

            var options = {};
            options['dataMode'] = 'regions';
            options['region'] = 'US';
            options['width'] = jQuery(document).width()/1.3;
            options['height'] = jQuery(document).height()/1.8;

            var container = document.getElementById('map_canvas');
            var geomap = new google.visualization.GeoMap(container);

            geomap.draw(data, options);

            google.visualization.events.addListener(geomap, 'regionClick', myHandler);
          };

          function myHandler(e){
            console.debug('event raised');
            jQuery(window.location.href = 'states/' + e['region']);
            console.debug('where is the selection');
            console.debug(selection);
          };


      </script>
    STR

    x.html_safe!
  end
end
