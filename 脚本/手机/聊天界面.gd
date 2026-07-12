extends Control

var 当前联系人: String = ""
var ai等待中: bool = false
var 等待回复的联系人: String = ""

@onready var 顶栏标题 = $"顶栏/标题"
@onready var 顶栏返回 = $"顶栏/返回按钮"
@onready var 内容容器 = $"内容容器"
@onready var 联系人滚动 = $"内容容器/联系人滚动"
@onready var 聊天滚动 = $"内容容器/聊天滚动"
@onready var 消息列表 = $"内容容器/聊天滚动/消息列表"
@onready var 底栏 = $"底栏"
@onready var 输入区 = $"输入区"
@onready var 输入框 = $"输入区/输入框"
@onready var 发送按钮 = $"输入区/发送按钮"

@onready var 联系人_妹妹 = $"内容容器/联系人滚动/联系人列表/联系人_妹妹"
@onready var 联系人_阿云 = $"内容容器/联系人滚动/联系人列表/联系人_阿云"


func _ready() -> void:
	聊天数据.初始化()
	_显示联系人列表()
	_刷新联系人信息()
	消息列表.add_theme_constant_override("separation", 4)
	AIChat.收到AI回复.connect(_on_AI回复)
	AIChat.AI出错.connect(_on_AI出错)


func _刷新联系人信息() -> void:
	for contact in 聊天数据.获取联系人列表():
		var btn: Button
		if contact["名称"] == "妹妹":
			btn = 联系人_妹妹
		elif contact["名称"] == "阿云":
			btn = 联系人_阿云
		else:
			continue
		btn.get_node("最后消息").text = contact["最后消息"]
		btn.get_node("时间").text = contact["最后时间"]


func _显示联系人列表() -> void:
	当前联系人 = ""
	顶栏标题.text = "巨信"
	顶栏返回.hide()
	联系人滚动.show()
	聊天滚动.hide()
	输入区.hide()
	底栏.show()
	内容容器.anchor_bottom = 0.91


func _显示聊天窗口(联系人名: String) -> void:
	当前联系人 = 联系人名
	顶栏标题.text = 联系人名
	顶栏返回.show()
	联系人滚动.hide()
	聊天滚动.show()
	输入区.show()
	底栏.hide()
	内容容器.anchor_bottom = 0.858
	_更新输入状态()
	_刷新消息列表()


func _更新输入状态() -> void:
	if ai等待中:
		输入框.editable = false
		输入框.placeholder_text = "对方正在输入..."
		发送按钮.disabled = true
	else:
		输入框.editable = true
		输入框.placeholder_text = "输入消息..."
		发送按钮.disabled = false


func _刷新消息列表() -> void:
	for child in 消息列表.get_children():
		child.queue_free()

	var contact = 聊天数据.获取联系人(当前联系人)
	if contact.is_empty():
		return

	for msg in contact["消息"]:
		消息列表.add_child(_创建气泡(msg))

	if ai等待中:
		var hint = Label.new()
		hint.text = "对方正在输入..."
		hint.add_theme_font_size_override("font_size", 11)
		hint.add_theme_color_override("font_color", Color(0.502, 0.502, 0.502, 1))
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint.custom_minimum_size = Vector2(0, 24)
		消息列表.add_child(hint)

	await get_tree().process_frame
	聊天滚动.scroll_vertical = int(聊天滚动.get_v_scroll_bar().max_value)


func _创建气泡(msg: Dictionary) -> Control:
	var is_me = msg["发送者"] == "我"
	var row = Control.new()
	row.custom_minimum_size = Vector2(0, 28)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var bg = Panel.new()
	bg.layout_mode = 0
	var label = Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = msg["内容"]
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.102, 0.102, 0.102, 1))
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var max_text_width = min(200, _估算文字宽度(msg["内容"]))
	var text_height = _估算文字高度(msg["内容"], max_text_width) + 20
	var bg_width = max_text_width + 24
	var bubble_height = text_height

	var sb = StyleBoxFlat.new()
	if is_me:
		sb.bg_color = Color(0.584, 0.925, 0.412, 1)
	else:
		sb.bg_color = Color(1, 1, 1, 1)
	sb.set_corner_radius_all(6)
	bg.add_theme_stylebox_override("panel", sb)

	bg.size = Vector2(bg_width, bubble_height)

	if is_me:
		bg.layout_mode = 1
		bg.anchor_left = 1.0
		bg.anchor_right = 1.0
		bg.offset_left = -(bg_width + 12)
		bg.offset_right = -12
		bg.offset_top = 4
		label.layout_mode = 1
		label.anchor_left = 1.0
		label.anchor_right = 1.0
		label.offset_left = -bg_width
		label.offset_right = -24
		label.offset_top = 14
		label.offset_bottom = bubble_height - 6
	else:
		bg.position = Vector2(52, 4)
		label.position = Vector2(64, 10)
		label.size = Vector2(max_text_width, bubble_height - 14)

	var time_label = Label.new()
	time_label.text = msg.get("时间", "")
	time_label.add_theme_font_size_override("font_size", 10)
	time_label.add_theme_color_override("font_color", Color(0.502, 0.502, 0.502, 1))
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.layout_mode = 1
	time_label.anchor_left = 0.5
	time_label.anchor_right = 0.5
	time_label.offset_left = -60
	time_label.offset_right = 60
	time_label.offset_top = bubble_height + 6
	time_label.offset_bottom = bubble_height + 22

	row.custom_minimum_size = Vector2(0, bubble_height + 28)

	row.add_child(bg)
	row.add_child(label)
	row.add_child(time_label)

	return row


func _估算文字宽度(text: String) -> int:
	return min(text.length() * 15 + 20, 200)


func _估算文字高度(text: String, width: int) -> int:
	var chars_per_line = max(1.0, width / 14.0)
	var lines = max(1.0, ceil(text.length() / chars_per_line))
	return int(lines * 22)


func _on_联系人_妹妹_pressed() -> void:
	_显示聊天窗口("妹妹")


func _on_联系人_阿云_pressed() -> void:
	_显示聊天窗口("阿云")


func _on_返回按钮_pressed() -> void:
	_显示联系人列表()


func _on_发送消息(_dummy = null) -> void:
	if ai等待中:
		return
	var text = 输入框.text.strip_edges()
	if text.is_empty() or 当前联系人.is_empty():
		return

	聊天数据.添加消息(当前联系人, "我", text)
	输入框.text = ""
	_刷新消息列表()
	_刷新联系人信息()

	if not AIChat.已配置:
		return

	ai等待中 = true
	等待回复的联系人 = 当前联系人
	_更新输入状态()
	聊天数据.切换AI联系人(当前联系人)
	AIChat.发送消息(text)


func _on_AI回复(回复内容: String) -> void:
	if 等待回复的联系人.is_empty():
		return
	聊天数据.添加消息(等待回复的联系人, 等待回复的联系人, 回复内容)
	聊天数据.保存当前AI记忆()
	ai等待中 = false
	if 等待回复的联系人 == 当前联系人:
		_更新输入状态()
		_刷新消息列表()
		_刷新联系人信息()
		await get_tree().process_frame
		聊天滚动.scroll_vertical = int(聊天滚动.get_v_scroll_bar().max_value)
	else:
		_刷新联系人信息()
	等待回复的联系人 = ""


func _on_AI出错(错误信息: String) -> void:
	if 等待回复的联系人.is_empty():
		return
	var msg = "（" + 错误信息 + "）"
	聊天数据.添加消息(等待回复的联系人, 等待回复的联系人, msg)
	聊天数据.保存当前AI记忆()
	ai等待中 = false
	if 等待回复的联系人 == 当前联系人:
		_更新输入状态()
		_刷新消息列表()
	else:
		_刷新联系人信息()
	等待回复的联系人 = ""


func _on_关闭按钮_pressed() -> void:
	var phone = get_parent()
	while phone and not phone.has_method("关闭当前应用"):
		phone = phone.get_parent()
	if phone and phone.has_method("关闭当前应用"):
		phone.关闭当前应用()
