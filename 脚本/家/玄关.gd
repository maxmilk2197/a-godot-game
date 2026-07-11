extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(_on_signal_event)
	Dialogic.start("res://对话/玄关对话.dtl")

func _on_signal_event(argument: Variant):
	Dialogic.end_timeline()
	if argument == "回到房间":
		get_tree().change_scene_to_file("res://场景/家/家.tscn")
