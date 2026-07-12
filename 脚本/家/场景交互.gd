extends Control


func _on_电脑_pressed() -> void:
	get_tree().change_scene_to_file("res://场景/电脑/电脑主界面.tscn")


func _on_手机_pressed() -> void:
	get_tree().current_scene._打开手机()
