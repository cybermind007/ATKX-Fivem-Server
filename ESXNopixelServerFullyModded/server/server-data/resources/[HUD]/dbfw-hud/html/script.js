var DBHUD = {}

var moneyTimeout = null;
var CurrentProx = 0;



function Open (data) {
      $(".money-cash").css("display", "block");
      $(".money-bank").css("display", "block");
      $("#cash").html(data.cash);
      $("#bank").html(data.bank);
}

function Show(data) {
    if(data.type == "cash") {
        $(".money-cash").fadeIn(150);
        //$(".money-cash").css("display", "block");
        $("#cash").html(data.cash);
        setTimeout(function() {
            $(".money-cash").fadeOut(750);
        }, 3500)
    } else if(data.type == "bank") {
          $(".money-bank").fadeIn(150);
          $(".money-bank").css("display", "block");
          $("#bank").html(data.bank);
          setTimeout(function() {
              $(".money-bank").fadeOut(750);
          }, 3500)
    }
}
function Update(data) {
    if(data.type == "cash") {
        $(".money-cash").css("display", "block");
        $("#cash").html(data.cash);
        if (data.minus) {
            $(".money-cash").append('<p class="moneyupdate minus">-<span id="cash-symbol">&dollar;&nbsp;</span><span><span id="minus-changeamount">' + data.amount + '</span></span></p>')
            $(".minus").css("display", "block");
            setTimeout(function() {
                $(".minus").fadeOut(750, function() {
                    $(".minus").remove();
                    $(".money-cash").fadeOut(750);
                });
            }, 3500)
        } else {
            $(".money-cash").append('<p class="moneyupdate plus">+<span id="cash-symbol">&dollar;&nbsp;</span><span><span id="plus-changeamount">' + data.amount + '</span></span></p>')
            $(".plus").css("display", "block");
            setTimeout(function() {
                $(".plus").fadeOut(750, function() {
                    $(".plus").remove();
                    $(".money-cash").fadeOut(750);
                });
            }, 3500)
        }
    }
    if(data.type == "bank") {
        $(".money-bank").css("display", "block");
        $("#bank").html(data.bank);
        if (data.minus) {
            $(".money-bank").append('<p class="moneyupdate minus">-<span id="cash-symbol">&dollar;&nbsp;</span><span><span id="minus-changeamount">' + data.amount + '</span></span></p>')
            $(".minus").css("display", "block");
            setTimeout(function() {
                $(".minus").fadeOut(750, function() {
                    $(".minus").remove();
                    $(".money-bank").fadeOut(750);
                });
            }, 3500)
        } else {
            $(".money-bank").append('<p class="moneyupdate plus">+<span id="cash-symbol">&dollar;&nbsp;</span><span><span id="plus-changeamount">' + data.amount + '</span></span></p>')
            $(".plus").css("display", "block");
            setTimeout(function() {
                $(".plus").fadeOut(750, function() {
                    $(".plus").remove();
                    $(".money-bank").fadeOut(750);
                });
            }, 3500)
        }
    }
}

function Close() {
  var elems = document.querySelectorAll('#statusHud .bar');
  for (var i = 0; i < elems.length; i++) 
  {
      elem = elems[i];
      elem.style.position = "relative";
      elem.style.display = "inline-block";
      elem.style.left = 0 + 'px';
      elem.style.top = 0 + 'px';

  }
  $(".bar-speed").hide();
  $(".bar-fuel").hide();
  $(".bar-engine").hide();
  $(".bar-belt").hide();
  $(".bar-microphone").hide();
  $(".bar-nos").hide();
  $(".bar.dummy").hide();
}


$(document).on('keydown', function() {
  switch(event.keyCode) {
      case 27: // ESC
      // Showhide()
       ;
        break;
    }
});


$(function () {
  let height = 25.5;
  window.addEventListener("message", function (event) {

    if(event.data.action == "UpdateCompass") {
      UpdateCompass(event.data);
    }
    if(event.data.action == "hudtick") {
      Showhide(event.data);
    }

    if (event.data.action == "open") {
      Open(event.data);
    }
    if (event.data.action == "update") {
      Update(event.data);
    } 
    if (event.data.action == "show") {
      Show(event.data);
    }
    SetProgress("oxygen", event.data.varSetOxy, "#495A74");
    if (event.data.type == "updateStatusHud") {
      SetProgress("health", event.data.varSetHealth, "#338b4c");
      SetProgress("armour", event.data.varSetArmor, "#235ea0");
      SetProgress("hunger", event.data.varSetHunger, "#f97305");
      SetProgress("water", event.data.varSetThirst, "#0e93da");
      SetProgress("oxygen", event.data.varSetOxy, "#495A74");
      SetProgress("stress", event.data.varSetStress, "#d31204");
      SetProgress("fuel", event.data.varSetFuel, "red");
      SetProgress("speed", event.data.varSetSpeedProg, "blue");
      SetProgress("voice", event.data.varTalking, event.data.varSetVoip);
      if (event.data.vardirection) {
        $(".direction").find(".image").attr('style', 'transform: translate3d(' + event.data.vardirection + 'px, 0px, 0px)');
      }
      $(".bar-speed p.speed-num").text(event.data.varSetSpeedProg);
      if(event.data.varSetEngine < 200) {
        $(".bar-engine img").attr('src', 'img/engine-red.png');
      } else if(event.data.varSetEngine < 500) {
        $(".bar-engine img").attr('src', 'img/engine.png');
      } else {
        $(".bar-engine img").attr('src', 'img/engine-green.png');
      }
      if(event.data.varSeatBelt) {
        $(".bar-belt img").attr('src', 'img/seatbelt.png');
      } else {
        $(".bar-belt img").attr('src', 'img/seatbelt-on.png');
      }
      if (event.data.notveh == true) {
        resetHudToLinear();
      } else {
        arrangeHUDCircularly()
      }
    }
    
  });

  function widthHeightSplit(value, ele) {
    let eleHeight = (value / 100) * height;
    let leftOverHeight = height - eleHeight;

    ele.attr(
      "style",
      "height: " + eleHeight + "px; top: " + leftOverHeight + "px;"
    );
  }
  arrangeHUDCircularly();
});



function SetProgress(element, progress, color) {
  let eleObj = $(`.fill-bar.${element}`);

  if(element == "speed") {
   if(progress > 100) {
     progress -= 100;
     color = "red";
   }
  }

  if(element == "voice") {
    if(color == 1) {
      color = "yellow";
    }
    if(color == 2) {
      color = "green";
    }
    if(color == 3) {
      color = "red";
    }
   }

  if(element == "fuel") {
    if(progress < 50) {
      color = "red"; 
    }
  }

  eleObj.css("background-color", color);

  eleObj.animate({
    top: `${100-progress}%`
  }, 200);
}

function arrangeHUDCircularly() {
  var elems = document.querySelectorAll('#statusHud .bar');
  var increase = Math.PI * 2 / elems.length;
  var x = 0, y = 0, angle = 0.09, elem;
  
  for (var i = 0; i < elems.length; i++) {
  
    var radius = 160;
    if (i % 2)
      radius = 160 
      elem = elems[i];
      x = radius * Math.cos(angle) + 170;
      y = radius * Math.sin(angle) + 890;
      elem.style.position = "absolute";
      elem.style.left = (x) + 'px';
      elem.style.top = (y) + 'px';
      angle += increase;
  }

  $(".bar-speed").show();
  $(".bar-fuel").show();
  $(".bar-nos").show();
  $(".bar-engine").show();
  $(".bar-belt").show();
  $(".bar-microphone").show();
  $("#statusHud").css("top","0%");
  $(".compass-container").show();
  $(".ui-car-street").show();
}

function resetHudToLinear() {
  var elems = document.querySelectorAll('#statusHud .bar');
  for (var i = 0; i < elems.length; i++) 
  {
      elem = elems[i];
      elem.style.position = "relative";
      elem.style.display = "inline-block";
      elem.style.left = 0 + 'px';
      elem.style.top = 0 + 'px';

  }
  $("#statusHud").css("top","94%")
  $(".bar-speed").hide();
  $(".bar-fuel").hide();
  $(".bar-engine").hide();
  $(".bar-belt").hide();
  $(".bar-microphone").show();
  $(".bar-nos").hide();
  $(".bar.dummy").hide();
  $(".compass-container").hide();
  $(".ui-car-street").hide();
}

UpdateCompass = function(data) {
  var amt = (data.heading * 0.1133333333333333);
  if (data.lookside == "left") {
      $(".compass-ui").css({
          "right": (-30.6 - amt) + "vh"
      });
  } else {
      $(".compass-ui").css({
          "right": (-30.6 + -amt) + "vh"
      });
  }


  



  if (data.street2 != "" && data.street2 != undefined) {
    $(".ui-car-street").html(data.street1 + ' | ' + data.street2 + ' | ' + data.area_zone);
  } else {
      $(".ui-car-street").html(data.street1 + ' | ' + data.area_zone);
  }
}

Showhide = function(data) {
  if (data.show) {
    $("body").show()
    return;
 }
 $("body").hide()
  }