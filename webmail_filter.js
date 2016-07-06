
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
"<ul style='padding:0px;margin:auto;width:500px;'>\n" +
"<li style='float:left;padding-right:10px;'>Unread:<input type='checkbox' onchange='execute_query(this.checked, \"unread\")'></li>\n" +
"<li style='float:left;padding-right:10px;width:'>From:<input type='text' value='' style='width:100px' onchange='execute_query(this.value, \"from\")'></li>\n" +
"<li style='float:left;padding-right:10px;'>subject:<input type='text' value='' style='width:100px' onchange='execute_query(this.value, \"subject\")'></li>\n" +
"<li style='float:left;padding-right:10px;'>use regexp:<input type='checkbox' onchange='execute_query(this.checked, \"regexp\")'></li>\n" +
"<li style='float:left'><a href='#' onclick='reset_all();return(false);'>[x]</a></li>\n" +
"</ul>\n";
	frame.setAttribute("id", "webmail_filter_frame");
	frame.style.position = "fixed";
	frame.style.border = "1px solid grey";
	frame.style.left = "0px";
	frame.style.top = "0px";
	frame.style.width = "100%";
	frame.style.padding = "5px";
	frame.style.backgroundColor = "white";
	document.body.appendChild(frame);
}

var unread_value = 0;
var from_value = "";
var subject_value = "";
var regexp = false;

execute_query = function(value, name) {
	if(name == "unread") {
		unread_value = value;
	} else if(name == "from") {
		value.replace(/^\s+|\s+$/g, "")
		from_value = value;
	} else if(name == "subject") {
		value.replace(/^\s+|\s+$/g, "")
		subject_value = value;
	} else if(name == "regexp") {
		regexp = value;
	}

	if(regexp) {
		if(name == "from") {
			from_regexp = new RegExp(from_value, "i");
		} else if(name == "subject") {
			subject_regexp = new RegExp(subject_value, "i");
		}
	}

	for(var i = 2; i < rows.length; i ++) {
		checked[i].removeAttribute("checked");
		rows[i].style.backgroundColor = "white";

		if(!unread_value && from_value === "" && subject_value == "") {
			continue;
		}

		select = true;
		if(unread_value) {
			select = select && unread[i]
		}

		if(from_value !== "") {
			if(regexp) {
				select = select && from_regexp.test(from[i]);
			} else {
				select = select && from[i].toLowerCase().indexOf(from_value.toLowerCase()) >= 0;
			}
		}

		if(subject_value !== "") {
			if(regexp) {
				select = select && subject_regexp.test(subject[i]);
			} else {
				select = select && subject[i].toLowerCase().indexOf(subject_value.toLowerCase()) >= 0;
			}
		}

		if(select) {
			checked[i].setAttribute("checked", "checked");
			rows[i].style.backgroundColor = "lightgreen";
		}
	}
}

popup_frame()

reset_all = function() {
	for(var i = 2; i < rows.length; i ++) {
		checked[i].removeAttribute("checked");
		rows[i].style.backgroundColor = "white";
	}
	document.body.removeChild(document.getElementById("webmail_filter_frame"))
	return(false);
}

