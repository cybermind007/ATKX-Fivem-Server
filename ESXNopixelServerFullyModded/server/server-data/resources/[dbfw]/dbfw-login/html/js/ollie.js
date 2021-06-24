$('.card-with-player').click(function() {

    var chosenCharacterId = $(this).data('character-id');

    $('.card').removeClass('chosen-character');
    if (chosenCharacterId > 0) {
        $(this).addClass('chosen-character');

    }
});

$('.create-button').click(function() {

    var chosenCharacterId = $(this).data('character-id');
    var isCharacter = 'false';

    $.post("http://dbfw-login/CharacterChosen", JSON.stringify({
        charid: chosenCharacterId,
        ischar: 'false'
    }));
    Kashacter.CloseUI();
    setTimeout(function() {
        $('#load-char').css({ "display": "none" });
        $('.blackbar').css({ "display": "none" });
        $('#disconnect').css({ "display": "none" });
    }, 5000);
});

$('.disconnect').click(function() {


    $.post("http://dbfw-login/disconnect", JSON.stringify({

    }));
    Kashacter.CloseUI();
    setTimeout(function() {
        closeMenu();
        sendNuiMessage({ disconnect: true });
    }, 50);
});

$('.play-button').click(function() {
    $('#load-char').css({ "display": "block" });

    var chosenCharacterId = $(this).data('character-id');

    $.post("http://dbfw-login/CharacterChosen", JSON.stringify({
        charid: chosenCharacterId,
        ischar: 'true'

    }));
    Kashacter.CloseUI();
    setTimeout(function() {
        $('#load-char').css({ "display": "none" });
        $('.blackbar').css({ "display": "none" });
        $('#disconnect').css({ "display": "none" });
    }, 5000);
});


$('.delete-button').click(function() {

    var chosenCharacterId = $(this).data('character-id');

    if (chosenCharacterId > 0) {
        $('#deleteCharacterk').data('character-id', chosenCharacterId);
        $('#deleteCharacter').css({ "display": "block" });
    } else {
        Kashacter.CloseUI();
    }

});



$("#deleteCharacterk").click(function() {

    var chosenCharacterId = $(this).data('character-id');

    if (chosenCharacterId > 0) {
        $.post("http://dbfw-login/DeleteCharacter", JSON.stringify({
            charid: chosenCharacterId,

        }));
        $('#deleteCharacter').css({ "display": "none" });
        $('main').css({ "display": "none" });

    }
});

$("#deleteCharacteri").click(function() {

    var chosenCharacterId = $(this).data('character-id');

    if (chosenCharacterId > 0) {
        $.post("http://dbfw-login/DeleteCharacterIptal", JSON.stringify({

        }));

    }
    $('#deleteCharacter').css({ "display": "none" });
});



(() => {
    Kashacter = {};

    Kashacter.ShowUI = function(data) {
        $('.character-container').css('display', 'block');
        if (data.characters !== null) {
            $('.card-with-player').css('display', 'none');
            $('.card-without-player').css('display', 'block');
            $.each(data.characters, function(index, char) {
                if (char.charid !== 0) {
                    var charid = char.identifier.charAt(4);
                    $('#c-name-' + charid).html(char.firstname);

                    $('#c-fullname-' + charid).html(char.firstname + ' ' + char.lastname);
                    var dateString = new Date(char.dateofbirth).toLocaleString('en-US');
                    $('#c-dob-' + charid).html(dateString.substring(0, dateString.length - 12));
                    $('#c-gender-' + charid).html((char.sex === 'm') ? 'Male' : (char.sex === 'f') ? 'Female' : 'Unknown');
                    var jobGrade = (char.job !== 'Unemployed' && char.job !== 'unemployed') ? +char.job_grade + '' : '';
                    $('#c-job-' + charid).html(char.job);
                    $('#c-jobrank-' + charid).html(jobGrade);
                    $('#c-height-' + charid).html(char.height + ' cm');
                    $('#c-phone-' + charid).html(char.phone_number);
                    $('#c-bank-' + charid).html('$' + char.bank.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ','));
                    $('#c-cash-' + charid).html('$' + char.money.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ','));
                    // $('#c-group-' + charid).html(char.group);

                    $('#character-without-' + charid).css('display', 'none');
                    $('#character-with-' + charid).css('display', 'block');
                    $('#character-with-' + charid).attr('is-character', 'true');
                    ShowLoading(false)
                }
            });
        }
    };

    Kashacter.CloseUI = function() {
        $('body').css({ "display": "none" });
    };
    Kashacter.ShowWelcome = function() {
        $('#main').css({ "display": "block" });
        $('#changelog').css({ "display": "block" });
        $('#init').css({ "display": "block" });
        IsInMainMenu = true
    };
    Kashacter.HideWelcome = function() {
        $('#changelog').css({ "display": "none" });
        $('#init').css({ "display": "none" });
        IsInMainMenu = false
    };

    window.onload = function(e) {
        window.addEventListener('message', function(event) {
            switch (event.data.action) {
                case 'openui':
                    Kashacter.ShowUI(event.data);
                    ShowLoading(false)
                    break;
                case 'openwelcome':
                    Kashacter.ShowWelcome();
                    break;
                case 'displayback':
                    $('.blackbar').css({ "display": "block" });
                    $('.bottom-bar2').css({ "display": "block" });
                    $('#disconnect').css({ "display": "block" });
                    $('.BG').css({ "display": "block" });
                    break;
            }
        })
        document.onkeydown = function(data) {
            if (data.which == 13 && IsInMainMenu) {
                Kashacter.HideWelcome();
                $.post("http://dbfw-login/ShowSelection", JSON.stringify({}));
                ShowLoading(true)
            }
        }
    }

})();


function ShowLoading(display) {
    if (display) {
        $("#load-allchar").css("display", "block")
    } else {
        $("#load-allchar").css("display", "none")
    }
}

$('#disconnect').click(function() {


    $.post("http://dbfw-login/disconnect", JSON.stringify({}));
    setTimeout(function() {}, 5000);
});