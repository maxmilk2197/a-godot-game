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
@onready var 关闭按钮 = $"顶栏/关闭按钮"


func _ready() -> void:
	聊天数据.初始化()
	_套用M3外观()
	_显示联系人列表()
	_刷新联系人信息()
	消息列表.add_theme_constant_override("separation", 8)
	AIChat.收到AI回复.connect(_on_AI回复)
	AIChat.AI出错.connect(_on_AI出错)


## 把聊天界面的颜色和图标统一到 MD3 令牌上。
## 场景里那些 Color(0,0,0,1) 之类的写死颜色不会跟着换主题变，
## 所以运行时统一盖一遍；顶栏两个图标按钮也换成 Material Design Icons 的字形。
func _套用M3外观() -> void:
	# 顶栏：图标按钮用字形（"<" / "X" 这种字符太糙了）
	if M3Icons.可用():
		var 字模 := M3Icons.字体()
		_设图标按钮(顶栏返回, "chevron-left", 字模)
		_设图标按钮(关闭按钮, "close", 字模)

	# 标题
	顶栏标题.add_theme_color_override("font_color", M3Theme.on_surface)

	# 输入框
	输入框.add_theme_color_override("font_color", M3Theme.on_surface)
	输入框.add_theme_color_override("font_placeholder_color", M3Theme.on_surface_variant)
	输入框.add_theme_color_override("caret_color", M3Theme.primary)
	输入框.add_theme_color_override("selection_color",
		Color(M3Theme.primary.r, M3Theme.primary.g, M3Theme.primary.b, 0.3))

	# 联系人行：文字颜色 + 分割线
	for 行 in [联系人_妹妹, 联系人_阿云]:
		_染色(行.get_node_or_null("名称"), M3Theme.on_surface)
		_染色(行.get_node_or_null("最后消息"), M3Theme.on_surface_variant)
		_染色(行.get_node_or_null("时间"), M3Theme.on_surface_variant)
		var 线: Node = 行.get_node_or_null("分割线")
		if 线 is ColorRect:
			(线 as ColorRect).color = M3Theme.outline_variant
	# 加一个「我」那侧没有联系人行，分割线只有两条，够用


func _设图标按钮(按钮: Button, 图标名: String, 字模: Font) -> void:
	if 按钮 == null or 字模 == null:
		return
	var 单 := M3Icons.取字符(图标名)
	if 单.is_empty():
		return
	按钮.text = 单
	按钮.add_theme_font_override("font", 字模)
	按钮.add_theme_font_size_override("font_size", M3Theme.fs(26))


func _染色(节点: Node, 色: Color) -> void:
	if 节点 is Label:
		(节点 as Label).add_theme_color_override("font_color", 色)


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
	顶栏标题.text = "消息"
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
		hint.add_theme_font_size_override("font_size", 20)
		hint.add_theme_color_override("font_color", M3Theme.on_surface_variant)
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint.custom_minimum_size = Vector2(0, 44)
		消息列表.add_child(hint)

	await get_tree().process_frame
	聊天滚动.scroll_vertical = int(聊天滚动.get_v_scroll_bar().max_value)


func _创建气泡(msg: Dictionary) -> Control:
	var is_me: bool = msg["发送者"] == "我"

	# 一条消息 = 上面一行气泡（左/右对齐）+ 下面居中的时间
	var row := VBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 4)

	var line := HBoxContainer.new()
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_theme_constant_override("separation", 14)
	line.alignment = BoxContainer.ALIGNMENT_END if is_me else BoxContainer.ALIGNMENT_BEGIN

	# 对方消息左侧的头像（由设置里的“显示对方头像”开关控制）
	if not is_me and Settings.显示对方头像:
		line.add_child(_创建对方头像())

	line.add_child(_创建气泡本体(msg["内容"], is_me))
	row.add_child(line)

	var 时间 := str(msg.get("时间", ""))
	if not 时间.is_empty():
		var time_label := Label.new()
		time_label.text = 时间
		time_label.add_theme_font_size_override("font_size", 18)
		time_label.add_theme_color_override("font_color", M3Theme.on_surface_variant)
		time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		time_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(time_label)

	return row


## 气泡本体：圆角背景 + 自动换行文字。短消息贴合内容，长消息最多 200px 后换行。
func _创建气泡本体(内容: String, is_me: bool) -> Control:
	var 气泡 := PanelContainer.new()
	气泡.add_theme_stylebox_override("panel", _气泡样式(is_me))
	气泡.size_flags_horizontal = Control.SIZE_SHRINK_END if is_me else Control.SIZE_SHRINK_BEGIN

	var 边距 := MarginContainer.new()
	边距.add_theme_constant_override("margin_left", 24)
	边距.add_theme_constant_override("margin_right", 24)
	边距.add_theme_constant_override("margin_top", 16)
	边距.add_theme_constant_override("margin_bottom", 16)
	气泡.add_child(边距)

	var 文本 := Label.new()
	文本.text = 内容
	文本.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	文本.add_theme_font_size_override("font_size", 26)
	# MD3：自己气泡上是 on_primary_container，对方气泡上是 on_surface
	文本.add_theme_color_override("font_color",
		M3Theme.on_primary_container if is_me else M3Theme.on_surface)
	文本.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	文本.custom_minimum_size = Vector2(min(380, _估算文字宽度(内容)), 0)
	边距.add_child(文本)

	return 气泡


## MD3 消息气泡：
##   自己的  primary_container + 右下角收小
##   对方的  surface_container_high + 左下角收小
func _气泡样式(is_me: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = M3Theme.primary_container if is_me else M3Theme.surface_container_high
	var 大 := int(round(M3Shape.大 * M3Theme.scale))
	var 小 := int(round(M3Shape.特小 * M3Theme.scale))
	sb.corner_radius_top_left = 大
	sb.corner_radius_top_right = 大
	sb.corner_radius_bottom_left = 大 if is_me else 小
	sb.corner_radius_bottom_right = 小 if is_me else 大
	return sb


## 创建对方头像：圆形（用联系人的 头像颜色 + 头像文字），放在气泡左侧
func _创建对方头像() -> Control:
	var 联系人 := 聊天数据.获取联系人(当前联系人)
	var 头像 := Panel.new()
	头像.custom_minimum_size = Vector2(66, 66)
	头像.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var sb := StyleBoxFlat.new()
	sb.bg_color = 联系人.get("头像颜色", Color(0.6, 0.6, 0.6, 1))
	sb.set_corner_radius_all(33)   # 圆形
	sb.set_content_margin_all(0)
	头像.add_theme_stylebox_override("panel", sb)

	var 文字 := Label.new()
	文字.text = str(联系人.get("头像文字", "?"))
	文字.add_theme_color_override("font_color", Color.WHITE)
	文字.add_theme_font_size_override("font_size", 30)
	文字.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	文字.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	文字.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	头像.add_child(文字)

	return 头像


## 估算文字自然宽度（不换行），用于让气泡按内容自适应宽度
func _估算文字宽度(text: String) -> int:
	return int(ThemeDB.fallback_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 26).x)


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
