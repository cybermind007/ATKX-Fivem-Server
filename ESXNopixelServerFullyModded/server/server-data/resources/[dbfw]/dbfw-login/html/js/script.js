var IsInMainMenu

var create = 0

function CreateCharacter(val) {

	document.getElementById("characters").style.display = "none"
	document.getElementById("creation").style.display = "block"

	create = val
}

function CompleteCreation() {

	var firstname = document.getElementById("firstname").value
	var lastname = document.getElementById("lastname").value
	var gender = "M"

	if (document.getElementById('genderMale').checked) {
		gender = "M"
	} else if (document.getElementById('genderFemale').checked) {
		gender = "F"
	}

	var dob = document.getElementById("dob").value
	var story = document.getElementById("story").value

	if (!firstname || !lastname || !dob) {
		return false
	}

	$.post("http://dbfw-login/CharacterChosen", JSON.stringify({
        charid: create,
        ischar: false,
		firstname: firstname,
		lastname: lastname,
		gender: gender,
		dob: dob
    }));

	document.getElementById("creation").style.display = "none"
	document.getElementById("nochar" + create).style.display = "none"

	document.getElementById("char" + create).style.display = "block"
	document.getElementById("charinfo" + create).style.display = "block"
	document.getElementById("charbox" + create).style.display = "block"
}

function CancelCreation() {

	document.getElementById("characters").style.display = "flex"
	document.getElementById("creation").style.display = "none"
}
