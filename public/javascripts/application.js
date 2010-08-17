// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function(){  
  
    $("nav ul.breadcrumb li.topnav a").click(function() { //When trigger is clicked...  
        //Following events are applied to the subnav itself (moving subnav up and down)  
        var t = $(this).data("destroyHandle");
        if (t) {
          clearTimeout(t);
        }

        $(this).parent().find("ul.state-select").show(); //Drop down the subnav on click  
        $(this).addClass("subhover"); //On hover over, add class "subhover"
        return false;
    });

    $("nav ul.breadcrumb li.topnav").hover(
      function() {
        var t = $(this).find("a").data("destroyHandle");
        if (t) {
          clearTimeout(t);
        }
      },
      function() {
        var t = setTimeout(function() {
          $("ul.state-select").hide();
          $("ul.breadcrumb li.topnav a").removeClass("subhover");
        }, 1200);

        $(this).find("a").data("destroyHandle", t)
        return false;
      })

  /* .hover(function() {},
      function() {
        $(this).parent().find("ul.state-select").delay(1000).hide(); //When the mouse hovers out of the subnav, move it back up  
        $(this).removeClass("subhover"); //On hover out, remove class "subhover"
        return false;
      });
     */ 
});
