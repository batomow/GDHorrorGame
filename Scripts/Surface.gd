extends Node

class_name Surface

var sound_value: int
var sound_land_value: int
var walk_stream_wav: AudioStream 
var jump_land_stream_wav : AudioStream 
var sneak_stream_wav: AudioStream

func _init(sv:int, slv:int, ws:AudioStream, js:AudioStream, ss:AudioStream):
	sound_value = sv
	sound_land_value = slv
	walk_stream_wav = ws
	jump_land_stream_wav = js
	sneak_stream_wav = ss
	
