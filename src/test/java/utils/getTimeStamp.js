 function currentDateTimestamp(format) {
	var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
	var sdf = new SimpleDateFormat(format);
	var date = new java.util.Date();
	return sdf.format(date);
}