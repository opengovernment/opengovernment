/* Upgrade a text field to a search element, if supported. */

$(document).ready(function(){ 

    /* Breadcrumb dropdown menu */
    $("a#dropdown").click(function() { //When trigger is clicked...  
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

});
