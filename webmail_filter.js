
var unread = new Array();
var checked = new Array();
var from = new Array();
var subject = new Array();
var rows = new Array();

load_all = function() {
	rows = document.getElementsByClassName("lvm");
	alert(rows);
	rows = document.getElementsByClassName("lvm")[0].lastChild.childNodes;

	unread.length = rows.length;
	checked.length = rows.length;
	from.length = rows.length;
	subject.length = rows.length;

	// i == 0 is the title
	for(var i = 2; i < rows.length; i ++) {
		var td = rows[i].childNodes;
		unread[i] = td[1].firstChild.getAttribute("alt") == "Message: Unread";
		checked[i] = td[3].firstChild;
		from[i] = td[4].innerHTML;
		subject[i] = td[5].innerHTML;
	}
}

popup_frame = function() {

	load_all()

	// create a div
	var frame = document.createElement("div")
	frame.innerHTML = 
"<ul>\n" +
"<li><input type='checkbox' value='1' onchange='execute_query(this.value, \"unread\")'>unread</li>\n" +
"<li>From:<input type='text' value='' onKeypress='execute_query(this.value), \"from\"'></li>\n" +
"<li>subject:<input type='text' value='' onkeypress='execute_query(this.valule, \"subject\")'></li>\n" +
"</ul>\n";
	frame.style = "position:absolute;"
}

var unread_value = 0;
var from_value = "";
var subject_value = "";

execute_query = function(value, name) {
	if(name == "unread") {
		unread_value = value;
	} else if(name == "from") {
		value.replace(/^\s+|\s+$/g, "")
		from_value = value;
	} else if(name == "subject") {
		value.replace(/^\s+|\s+$/g, "")
		subject_value = value;
	}

	if(!unread_value && from_value === "" && subject_value === "") {
		return(null)
	}

	for(var i = 0; i < rows.length(); i ++) {
		checked[i].unchecked();

		select = false;
		if(unread_value && unread[i]) {
			select = select && true;
		}

		if(from_value !== "" && from[i].match(from_value)) {
			select = select && true;
		}

		if(subject_value !== "" && subject[i].match(subject_value)) {
			select = select && true;
		}

		if(select) {
			checked[i].setAttribute("checked", 1);
		}
	}
}

popup_frame()
