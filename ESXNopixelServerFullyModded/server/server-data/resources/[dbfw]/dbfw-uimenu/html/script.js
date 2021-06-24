const closeKey = [113, 27];
let menuType = false
$(document).ready(function() {

    $("body").on("keyup", function (key) {
        if (closeKey.includes(key.which)) {
            $(".navigation").fadeOut();
            $.post(`http://dbfw-uimenu/closeUI`, JSON.stringify({value: false}));
        }
    });

    $("#closebtn").on("click", function(event) {
        $(".navigation").fadeOut();
        $.post(`http://dbfw-uimenu/closeUI`, JSON.stringify({value: false}));
    })

    $("#backbtn").on("click", function(event) {
        $(".navigation").fadeOut();
        $(".mainmenu").empty();
        $.post(`http://dbfw-uimenu/selectedValue`, JSON.stringify({value: "back"}));
    })

    $(".mainmenu").on("click", ".item", function(event) {
        event.preventDefault();
        if (!$(this).data("value")) return;

        if (menuType == "list" || menuType == "hover") {
            $(".navigation").fadeOut();
            $(".mainmenu").empty()
            let thisval = (typeof $(this).data("value") == "number") ? $(this).data("value"): window.atob($(this).data("value"))
            $.post(`http://dbfw-uimenu/selectedValue`, JSON.stringify({value: (typeof thisval == "object") ? JSON.parse(thisval) : thisval}));
        }

        if (menuType == "multi") {

            if ($(this).find("i").hasClass("fa-times")) {

                $("i", this).toggleClass(["green", "fa-check"]);
                $("i", this).toggleClass(["red", "fa-times"]);

            } else if ($(this).find("i").hasClass("fa-check")) {

                $("i", this).toggleClass(["red", "fa-times"]);
                $("i", this).toggleClass(["green", "fa-check"]);
                
            }
            let thisval = (typeof $(this).data("value") == "number") ? $(this).data("value"): window.atob($(this).data("value"))
            $.post(`http://dbfw-uimenu/hoveredValue`, JSON.stringify({value: (typeof thisval == "object") ? JSON.parse(thisval) : thisval, event: $(this).data("event")}));
        }

    })



    $(".submenu").on("click", ".item", function(event) {
        event.preventDefault();
        if (!$(this).data("value")) return;

        if (menuType == "list" || menuType == "hover") {
            $(".navigation").fadeOut();
            $(".mainmenu").empty();
            let thisval = (typeof $(this).data("value") == "number") ? $(this).data("value"): window.atob($(this).data("value"))
            $.post(`http://dbfw-uimenu/selectedValue`, JSON.stringify({value: (typeof thisval == "object") ? JSON.parse(thisval) : thisval}));
        }

        if (menuType == "multi") {
            
            if ($(this).find("i").hasClass("fa-times")) {
                $(this).find("i").remove();
                $(this).prepend('<i class="fas fa-check green"></i>');
            }

            if ($(this).find("i").hasClass("fa-check")) {
                $(this).find("i").remove();
                $(this).prepend('<i class="fas fa-times red"></i>');
            }
            
            let thisval = (typeof $(this).data("value") == "number") ? $(this).data("value"): window.atob($(this).data("value"))
            $.post(`http://dbfw-uimenu/hoveredValue`, JSON.stringify({value: (typeof thisval == "object") ? JSON.parse(thisval) : thisval, event: $(this).data("event")}));
        }
    });

});


window.addEventListener("message", function(event) {
    var action = event.data.action;

    switch (action) {
        case "show":
            switch(event.data.menu["menutype"]) {
                case "list":
                    menuType = "list"
                    buildListMenu(event.data.menu);
                    break;
                case "multiselect":
                    menuType = "multi"
                    buildMultiMenu(event.data.menu);
                    break;
                case "hover":
                    menuType = "hover"
                    buildHoverMenu(event.data.menu);
                    break;  
            }
            $("#backbtn").show();
            $(".navigation").fadeIn();

            if (!(event.data.menu.showBack)) {
                $("#backbtn").hide();
            }

            break;

        case "close":
            $(".navigation").fadeOut();
            break;
    }
});


function buildListMenu(data) {
    $(".item").off("mouseenter mouseleave");
    let myMenu = data.menu
    $("#header").text(data.menulabel)
    $(".mainmenu").empty();
    for (let result of myMenu) {
        if (result.submenu) {
            let submenu = `<li><a href="" class="item">${result.submenuLabel}</a><ul class="submenu">`
            for (let subitem of result.submenu) {
                submenu = submenu + `<li><a href="" class="item" data-value="${(typeof subitem.value == "object") ? window.btoa(JSON.stringify(subitem.value)) : window.btoa(subitem.value)}">${subitem.icon ? "<i class=\"" + subitem.icon + "\"></i>&nbsp;" : ""}${subitem.label}</a></li>`
            }
            submenu = submenu + `</ul></li>`
            $(".mainmenu").append(submenu)
        } else {
            $(".mainmenu").append(`<li><a href="" class="item" data-value="${(typeof result.value == "object") ? window.btoa(JSON.stringify(result.value)) : window.btoa(result.value)}">${result.icon ? "<i class=\"" + result.icon + "\"></i>&nbsp;" : ""}&nbsp;${result.label}</a></li>`)
        }
    }
}

function buildMultiMenu(data) {
    $(".item").off("mouseenter mouseleave");
    let myMenu = data.menu
    $("#header").text(data.menulabel)
    $(".mainmenu").empty();
    for (let result of myMenu) {
        if (result.submenu) {
            let submenu = `<li><a href="" class="item">${result.submenuLabel}</a><ul class="submenu">`
            for (let subitem of result.submenu) {
                submenu = submenu + `<li><a href="" class="item" data-event="${result.event}" data-value="${(typeof subitem.value == "object") ? JSON.stringify(subitem.value) : subitem.value}">${subitem.hasitem ? '<i class="fas fa-check green"></i>&nbsp;' : '<i class="fas fa-times red"></i> '}${subitem.label}</a></li>`
            }
            submenu = submenu + `</ul></li>`
            $(".mainmenu").append(submenu)
        } else {
            $(".mainmenu").append(`<li><a href="" class="item" data-event="${data.event}" data-value="${(typeof result.value == "object") ? JSON.stringify(result.value) : result.value}">${result.hasitem ? '<i class="fas fa-check green"></i>&nbsp;' : '<i class="fas fa-times red"></i> '}${result.label}</a></li>`)
        }
    }
}

function buildHoverMenu(data) {
    let myMenu = data.menu
    $("#header").text(data.menulabel)
    $(".mainmenu").empty();
    for (let result of myMenu) {
        if (result.submenu) {
            let submenu = `<li><a href="" class="item">${result.submenuLabel}</a><ul class="submenu">`
            for (let subitem of result.submenu) {
                submenu = submenu + `<li><a href="" class="item" data-event="${data.event}" data-value='${(typeof subitem.value == "object") ? window.btoa(JSON.stringify(subitem.value)) : window.btoa(subitem.value)}'>${subitem.icon ? "<i class=\"" + subitem.icon + "\"></i>&nbsp;" : ""}${subitem.label}</a></li>`
            }
            submenu = submenu + `</ul></li>`
            $(".mainmenu").append(submenu)
        } else {
            $(".mainmenu").append(`<li><a href="" class="item" data-event="${data.event}" data-value='${(typeof result.value == "object") ? window.btoa(JSON.stringify(result.value)) : window.btoa(result.value)}'>${result.icon ? "<i class=\"" + result.icon + "\"></i>&nbsp;" : ""}${result.label}</a></li>`)
        }
    }

    $(".item").hover(function(event) {
        event.preventDefault();
        if (menuType == "hover") {
            if (!$(this).data("value")) return;
            let thisval = (typeof $(this).data("value") == "number") ? $(this).data("value"): window.atob($(this).data("value"))
            $.post(`http://dbfw-uimenu/hoveredValue`, JSON.stringify({value: (typeof thisval == "object") ? JSON.parse(thisval) : thisval, event: $(this).data("event")}));
        }
    }, function() {

    });
}