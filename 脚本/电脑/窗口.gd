extends Control

var dragging := false
var drag_offset := Vector2.ZERO

func _ready():
	# 确保标题栏能收到事件
	$"标题栏".mouse_filter = Control.MOUSE_FILTER_STOP
	$"标题栏/标题栏背景".mouse_filter = Control.MOUSE_FILTER_IGNORE
	$"标题栏/标题".mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	$"标题栏".gui_input.connect(_on_titlebar_input)
	$"标题栏/关闭".pressed.connect(_on_关闭_pressed)

func _on_titlebar_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = get_global_mouse_position() - global_position
			else:
				dragging = false

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position() - drag_offset

func _on_关闭_pressed() -> void:
	$".".queue_free()
	$".".hide()
