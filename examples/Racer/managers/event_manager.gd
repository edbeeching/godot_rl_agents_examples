extends Node


signal event_lap_started(body)
signal event_lap_finished(body)

func lap_started(body):
	emit_signal("event_lap_started", body)

func lap_finished(body):
	emit_signal("event_lap_finished", body)
	
