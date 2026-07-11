extends Control

signal interaction_requested(button_index: int)

func _ready() -> void:
	var portrait_btn := get_node_or_null("立绘/图") as TextureButton
	if portrait_btn and not portrait_btn.pressed.is_connected(立绘被按下):
		portrait_btn.pressed.connect(立绘被按下)

	var talk_btn := get_node_or_null("交互/交流") as Button
	if talk_btn:
		talk_btn.pressed.connect(func() -> void: interaction_requested.emit(1))
		_style_button(talk_btn)

	var btn2 := get_node_or_null("交互/Button2") as Button
	if btn2:
		btn2.text = "保存"
		btn2.pressed.connect(func() -> void: interaction_requested.emit(2))
		_style_button(btn2)

	var btn3 := get_node_or_null("交互/Button3") as Button
	if btn3:
		btn3.pressed.connect(func() -> void: interaction_requested.emit(3))
		_style_button(btn3)

	$"交互".hide()

func 立绘被按下() -> void:
	var interaction := $"交互"
	interaction.visible = not interaction.visible

func show_portrait() -> void:
	$"立绘".show()

func show_interaction() -> void:
	$"交互".show()

func hide_interaction() -> void:
	$"交互".hide()

func _style_button(btn: Button) -> void:
	btn.add_theme_font_size_override("font_size", 16)


func _on_交流_pressed() -> void:
	self.hide()
	$"../AI聊天界面".show()
