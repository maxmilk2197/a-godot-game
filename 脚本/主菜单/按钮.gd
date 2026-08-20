extends Control
#region 声明变量
var 新游戏补间: Tween
var 退出补间: Tween
var 加载存档补间: Tween
var 雪花移动补间 : Tween
@onready var 遮罩 = $"../遮罩"
@export var 新游戏 : Button
@export var 加载存档 : Button
@export var 设置 : Button
@export var 退出 : Button
@export var 雪花 : TextureRect
@export var 按钮移动 : bool = false
@export_range(-200, 200, 1) var 雪花X偏移 : float = -30   ## 雪花离 VBox 左缘的额外偏移（负数往左、正数往右）
#endregion

func _ready():
	$"../logo".show()
	$"../动画".play("logo")
	await $"../动画".animation_finished
	$"../logo".queue_free()
	新游戏.offset_transform_enabled = true
	退出.offset_transform_enabled = true
	加载存档.offset_transform_enabled = true

	# 给所有文字按钮挂上悬停高亮（字体变 #5476d6）——必须在 _ready 里调用，否则从不生效
	初始化按钮高亮()

	if save.是否有任意存档():
		print("[存档]","发现现存档")
	else:
		print("[存档]","未发现存档")
		雪花.position = Vector2(VBox左缘X(), 按钮局部Y(新游戏))  

func _on_signal_event(argument: Variant):
	if argument == "进入客厅场景":
		进入客厅场景()
		
		
func 进入客厅场景():
	print("[保存]","开始自动保存")
	var 当前时间字典 = Time.get_datetime_dict_from_system()
	var 月 = 当前时间字典.month
	var 日 = 当前时间字典.day
	var 时 = 当前时间字典.hour
	var 分 = 当前时间字典.minute

	# 直接构造字典，代替原来的 Resource 对象
	var 数据 = {
		"游玩天数": 1,
		"最后游玩时间": "%d月%d日 %02d:%02d" % [月, 日, 时, 分],
		"最后游玩场景": "res://场景/家/家.tscn",
		"上次存档": save.当前存档,
		"角色数据": {},
	}

	var 是否保存成功 = save.自动保存(数据)
	if 是否保存成功:
		print("[存档]","自动保存成功")
	else:
		printerr("[存档]","自动保存失败,返回结果:", 是否保存成功)
	聊天数据._确保角色提示词()
	get_tree().change_scene_to_file("res://场景/家/家.tscn")

	
func 渐变动画() :
	遮罩.modulate = Color(0,0,0,0)   # 透明
	遮罩.show()
	var tween = create_tween().bind_node(遮罩)
	tween.tween_property(遮罩, "modulate", Color.BLACK, 0.2)
	await tween.finished
	
#region 按钮动画
func 当_加载_被鼠标碰到() -> void:
	移动雪花(Vector2(VBox左缘X(), 按钮局部Y(加载存档)))
	if 按钮移动:
		加载存档补间 = 播放按钮动画(加载存档, Vector2(20, 0), 加载存档补间)


func 当_加载_不再被鼠标碰到() -> void:
	if 按钮移动:
		加载存档补间 = 播放按钮动画(加载存档, Vector2(0, 0), 加载存档补间)


func 当_新游戏_被鼠标碰到() -> void:
	移动雪花(Vector2(VBox左缘X(), 按钮局部Y(新游戏)))
	if 按钮移动:
		新游戏补间 = 播放按钮动画(新游戏, Vector2(20, 0), 新游戏补间)

func 当_新游戏_不再被鼠标碰到() -> void:
	if 按钮移动:
		新游戏补间 = 播放按钮动画(新游戏, Vector2(0, 0), 新游戏补间)

func 当_退出_被鼠标碰到() -> void:
	移动雪花(Vector2(VBox左缘X(), 按钮局部Y(退出)))
	if 按钮移动:
		退出补间 = 播放按钮动画(退出, Vector2(20, 0), 退出补间)

func 当_退出_不再被鼠标碰到() -> void:
	if 按钮移动:
		退出补间 = 播放按钮动画(退出, Vector2(0, 0), 退出补间)


func 当_设置_被鼠标碰到() -> void:
	移动雪花(Vector2(VBox左缘X(), 按钮局部Y(设置)))


func 当_设置_不再被鼠标碰到() -> void:
	pass


## 给 VBoxContainer 里所有可见文字按钮挂上悬停高亮（字体变 #5476d6）
func 初始化按钮高亮() -> void:
	var vbox := $"VBoxContainer" as Control
	for 子节点 in vbox.get_children():
		# 只处理带 Label 文字（即按钮自身可见）的按钮
		if not 子节点 is Button:
			continue
		var 按钮 := 子节点 as Button
		if 按钮.get_node_or_null("Label") == null:
			continue
		按钮.mouse_entered.connect(func(): _设置按钮高亮(按钮, true))
		按钮.mouse_exited.connect(func(): _设置按钮高亮(按钮, false))


## 把按钮的全局 Y 换算回“按钮”根节点的局部 Y，
## 因为雪花是根的子节点，而按钮在带缩放的 VBoxContainer 里，直接取 position.y 会偏移/放大。
func 按钮局部Y(目标按钮: Control) -> float:
	return 目标按钮.global_position.y - global_position.y


## VBoxContainer 左边缘（根节点局部 X），雪花自动贴住 VBox 左侧、不写死数值
func VBox左缘X() -> float:
	var vbox := $"VBoxContainer" as Control
	return vbox.global_position.x - global_position.x + 雪花X偏移

func 播放按钮动画(按钮: Control, 目标位置: Vector2, 旧补间: Tween = null) -> Tween:
	if 旧补间 and 旧补间.is_valid():
		旧补间.kill()
	
	var 新补间 = create_tween()
	新补间.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	新补间.tween_property(按钮, "offset_transform_position", 目标位置, 0.2)
	return 新补间
	
#endregion

#region 按钮逻辑


func _加载存档() -> void:
	$"../背景音乐".stop()
	遮罩.modulate = Color(0,0,0,0)
	遮罩.show()
	var tween = create_tween().bind_node(遮罩)
	tween.tween_property(遮罩, "modulate", Color(0.0, 0.0, 0.0, 0.5), 0.2)
	await tween.finished
	var 场景资源 = load("res://场景/存档/存档加载界面.tscn")
	var 窗口实例 = 场景资源.instantiate()
	get_tree().current_scene.add_child(窗口实例)
	遮罩.hide()
	
func _新游戏() -> void:
	$"../背景音乐".stop()
	await 渐变动画()
	Dialogic.signal_event.connect(_on_signal_event)
	Dialogic.start("res://对话/初次见面.dtl")

func _on_退出_pressed() -> void:
	$"../背景音乐".stop()
	await 渐变动画()
	get_tree().quit()


#endregion


func 移动雪花(目标位置: Vector2) -> void:
	if 雪花移动补间 and 雪花移动补间.is_valid():
		雪花移动补间.kill()
	雪花移动补间 = create_tween()
	雪花移动补间.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	雪花移动补间.tween_property(雪花, "position", 目标位置, 0.2)


#region 设置弹窗
## 打开音量设置弹窗（音乐/音效滑块，拖动实时生效并自动保存）
var _设置弹窗: Window = null

func _打开设置() -> void:
	if _设置弹窗 and is_instance_valid(_设置弹窗):
		_设置弹窗.show()
		_设置弹窗.grab_focus()
		return

	_设置弹窗 = Window.new()
	_设置弹窗.title = "设置"
	_设置弹窗.size = Vector2i(420, 260)
	_设置弹窗.position = Vector2i(
		int(get_viewport().get_visible_rect().size.x / 2 - 210),
		int(get_viewport().get_visible_rect().size.y / 2 - 130))
	_设置弹窗.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
	_设置弹窗.close_requested.connect(func(): _设置弹窗.hide())
	get_tree().root.add_child(_设置弹窗)

	# 内容：VBoxContainer + 两行滑块 + 关闭按钮
	var 面板 := VBoxContainer.new()
	面板.add_theme_constant_override("separation", 16)
	_设置弹窗.add_child(面板)

	面板.add_child(_做滑块行("音乐音量", Audio.音乐音量,
		func(值: float): Audio.音乐音量 = 值))
	面板.add_child(_做滑块行("音效音量", Audio.音效音量,
		func(值: float): Audio.音效音量 = 值))

	var 关闭按钮 := Button.new()
	关闭按钮.text = "关闭"
	关闭按钮.pressed.connect(func(): _设置弹窗.hide())
	面板.add_child(关闭按钮)

	_设置弹窗.popup_centered()


## 生成一行“标题 + 滑块”
func _做滑块行(标题: String, 当前值: float, 回调: Callable) -> Control:
	var 行 := HBoxContainer.new()
	行.add_theme_constant_override("separation", 12)

	var 标签 := Label.new()
	标签.text = 标题
	标签.custom_minimum_size = Vector2(100, 0)
	行.add_child(标签)

	var 滑块 := HSlider.new()
	滑块.min_value = 0.0
	滑块.max_value = 1.0
	滑块.step = 0.01
	滑块.value = 当前值
	滑块.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	滑块.value_changed.connect(回调)
	行.add_child(滑块)

	return 行
#endregion


func _设置按钮高亮(按钮: Button, 是否高亮: bool) -> void:
	var label := 按钮.get_node_or_null("Label") as Label
	if label == null:
		return
	if 是否高亮:
		label.add_theme_color_override("font_color", Color("#5476d6"))
	else:
		label.remove_theme_color_override("font_color")
