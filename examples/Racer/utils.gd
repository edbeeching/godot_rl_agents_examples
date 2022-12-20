extends Node
class_name Utils

static func time_convert(time_in_sec):
	time_in_sec = int(time_in_sec)
	var seconds = time_in_sec%60
	var minutes = (time_in_sec/60)%60
	var hours = (time_in_sec/60)/60

	#returns a string with the format "HH:MM:SS"
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

static func time_convert_ms(time_in_sec):
	
	var hundreds = (int(time_in_sec*100)) % 100
	time_in_sec = int(time_in_sec)
	var seconds = time_in_sec%60
	var minutes = (time_in_sec/60)%60

	#returns a string with the format "HH:MM:SS"
	return "%02d:%02d:%02d" % [minutes, seconds, hundreds]
