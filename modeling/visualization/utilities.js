//Create a string with at least the given entropy (measured in bits).
kBase64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";	//encoding according to RFC 4648, section 5
function makeId(entropy) {
	var result = "";
	for(var i = 0; i < entropy; i += 6) {
		result += kBase64Chars.charAt(Math.floor(Math.random()*kBase64Chars.length));
	}
	return result;
}

function pushIfTruthy(array, value) {
	if(value) array.push(value);
}

function isDenseArrayOfStrings(object) {
	if(!$.isArray(object)) return false;
	for(var i = object.length; i--; ) {
		if("string" != typeof object[i]) return false;
	}
	return true;
}
