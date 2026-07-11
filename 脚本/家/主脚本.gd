extends Control

var 自动保存定时器: Timer

func _ready() -> void:
	Dialogic.signal_event.connect(_on_signal_event)
	Dialogic.start("res://对话/卧室.dtl")
	设置背景("白天")

	自动保存定时器 = Timer.new()
	自动保存定时器.wait_time = 600.0
	自动保存定时器.autostart = true
	自动保存定时器.timeout.connect(_自动保存)
	add_child(自动保存定时器)

	var 立绘节点 = get_node_or_null("角色交互")
	if 立绘节点 and 立绘节点.has_signal("interaction_requested"):
		立绘节点.interaction_requested.connect(_on_交互请求)

func _自动保存() -> void:
	var 当前时间字典 = Time.get_datetime_dict_from_system()
	var 月 = 当前时间字典.month
	var 日 = 当前时间字典.day
	var 时 = 当前时间字典.hour
	var 分 = 当前时间字典.minute

	var 数据 = {
		"游玩天数": 0,
		"最后游玩时间": "%d月%d日 %02d:%02d" % [月, 日, 时, 分],
		"最后游玩场景": "res://场景/家/家.tscn",
		"上次存档": save.当前存档,
		"ai_memory": save.当前AI记忆(),
	}
	save.自动保存(数据)
	print("[自动保存] 已保存到槽位 0")

func _on_交互请求(按钮索引: int) -> void:
	if 按钮索引 == 2:
		_打开存档界面(true)

func _打开存档界面(保存模式: bool = false) -> void:
	var 场景路径 := "res://场景/存档/存档保存界面.tscn" if 保存模式 else "res://场景/存档/存档加载界面.tscn"
	var 场景资源 = load(场景路径)
	var 窗口实例 = 场景资源.instantiate()
	get_tree().current_scene.add_child(窗口实例)

func _on_signal_event(argument: Variant):
	if argument == "进入玄关":
		get_tree().change_scene_to_file("res://场景/家/玄关.tscn")
	if argument == "等到晚上":
		设置背景("晚上")
	if argument == "睡觉":
		设置背景("白天")
	if argument == "打开AI聊天":
		var ai界面 = get_node_or_null("AI聊天界面")
		if ai界面:
			ai界面.show()
			var 角色交互 = get_node_or_null("角色交互")
			if 角色交互:
				角色交互.hide()

func 设置背景(背景: String) -> void:
	if 背景 == "白天":
		$"背景".texture = load("res://资源/纹理/家/白天.png")
	elif 背景 == "晚上":
		$"背景".texture = load("res://资源/纹理/家/晚上.png")
