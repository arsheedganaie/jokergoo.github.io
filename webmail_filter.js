
var unread = new Array();
var checked = new Array();
var from = new Array();
var subject = new Array();
var rows = new Array();

load_all = function() {
	var all_table = document.getElementsByTagName("table");
	for(var i = 0; i < all_table.length; i ++) {
		if(all_table[i].className === "lvw") {
			table = all_table[i];
			break;
		}
	}

	rows = table.lastChild.childNodes;

	unread.length = rows.length;
	checked.length = rows.length;
	from.length = rows.length;
	subject.length = rows.length;

	// i == 0 is the title
	for(var i = 2; i < rows.length; i ++) {
		var td = rows[i].childNodes;
		unread[i] = td[1].firstChild.getAttribute("alt") == "Message: Unread";
		checked[i] = td[3].firstChild;
		from[i] = td[4].innerHTML.replace(/&nbsp;/g, "");
		subject[i] = td[5].getElementsByTagName("a")[0].innerHTML.replace(/&nbsp;/g, "");
	}
}

popup_frame = function() {

	load_all();

	// create a div
	var frame = document.createElement("div");
	frame.innerHTML = 
"<ul>\n" +
"<li><input type='checkbox' value='1' onchange='execute_query(this.checked, \"unread\")'>unread</li>\n" +
"<li>From:<input type='text' value='' onchange='execute_query(this.value, \"from\")'></li>\n" +
"<li>subject:<input type='text' value='' onchange='execute_query(this.value, \"subject\")'></li>\n" +
"<li><a href='#' onclick='document.body.removeChild(document.getElementById(\"webmail_filter_frame\"));return(false);'>close</a></li>\n" +
"</ul>\n";
	frame.setAttribute("id", "webmail_filter_frame");
	frame.style.position = "fixed";
	frame.style.border = "1px solid grey";
	frame.style.left = "0px";
	frame.style.top = "0px";
	frame.style.padding = "4px";
	frame.style.backgroundColor = "white";
	document.body.appendChild(frame);
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

	for(var i = 2; i < rows.length; i ++) {
		checked[i].removeAttribute("checked");

		if(!unread_value && from_value === "" && subject_value == "") {
			continue;
		}

		select = true;
		if(unread_value) {
			select = select && unread[i]
		}

		if(from_value !== "") {
			select = select && from[i].match(from_value);
		}

		if(subject_value !== "") {
			select = select && subject[i].match(subject_value);
		}

		if(select) {
			checked[i].setAttribute("checked", "checked");
		}
	}
}

popup_frame()
