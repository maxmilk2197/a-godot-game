extends NinePatchRect
#region 声明变量
var 新游戏补间: Tween
var 退出补间: Tween
var 加载存档补间: Tween
@onready var 遮罩 = $"../遮罩"
#endregion

func _ready():
	$"新游戏".offset_transform_enabled = true
	$"退出".offset_transform_enabled = true
	$"加载存档".offset_transform_enabled = true
	if save.是否有任意存档():
		print("[信息]","发现现存档")
		$"加载存档".show()
	else:
		print("[信息]","未发现存档")
		$"加载存档".hide()

func _on_signal_event(argument: Variant):
	if argument == "进入客厅场景":
		进入客厅场景()
		
		
func 进入客厅场景():
	print("[信息]","开始自动保存")
	var 当前时间字典 = Time.get_datetime_dict_from_system()
	var 月 = 当前时间字典.month
	var 日 = 当前时间字典.day
	var 时 = 当前时间字典.hour
	var 分 = 当前时间字典.minute
	var 数据 = 存档.new()
	数据.游玩天数 = 0
	数据.最后游玩时间 = "%d月%d日 %02d:%02d" % [月, 日, 时, 分]
	数据.最后游玩场景 = "res://场景/游戏/家/家.tscn"
	数据.上次存档 = save.当前存档
	var 返回信息 = save.自动保存(数据)
	if 返回信息:
		print("[信息]","自动保存成功")
	else:
		printerr("[错误]","自动保存失败,返回结果:",返回信息 )
	get_tree().change_scene_to_file("res://场景/游戏/家/家.tscn")
	
	
func 渐变动画() :
	遮罩.modulate = Color(0,0,0,0)   # 透明
	遮罩.show()
	var tween = create_tween().bind_node(遮罩)
	tween.tween_property(遮罩, "modulate", Color.BLACK, 0.2)
	await tween.finished
	
#region 按钮动画
func 当_加载_被鼠标碰到() -> void:
	加载存档补间 = 播放按钮动画($"加载存档", Vector2(20, 0), 加载存档补间)


func 当_加载_不再被鼠标碰到() -> void:
	加载存档补间 = 播放按钮动画($"加载存档", Vector2(0, 0), 加载存档补间)


func 当_新游戏_被鼠标碰到() -> void:
	新游戏补间 = 播放按钮动画($"新游戏", Vector2(20, 0), 新游戏补间)

func 当_新游戏_不再被鼠标碰到() -> void:
	新游戏补间 = 播放按钮动画($"新游戏", Vector2(0, 0), 新游戏补间)

func 当_退出_被鼠标碰到() -> void:
	退出补间 = 播放按钮动画($"退出", Vector2(20, 0), 退出补间)

func 当_退出_不再被鼠标碰到() -> void:
	退出补间 = 播放按钮动画($"退出", Vector2(0, 0), 退出补间)

func 播放按钮动画(按钮: Control, 目标位置: Vector2, 旧补间: Tween = null) -> Tween:
	if 旧补间 and 旧补间.is_valid():
		旧补间.kill()
	
	var 新补间 = create_tween()
	新补间.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	新补间.tween_property(按钮, "offset_transform_position", 目标位置, 0.2)
	return 新补间
	
#endregion

#region 按钮逻辑


func 加载存档() -> void:
	遮罩.modulate = Color(0,0,0,0)   # 透明
	遮罩.show()
	var tween = create_tween().bind_node(遮罩)
	tween.tween_property(遮罩, "modulate", Color(0.0, 0.0, 0.0, 0.5), 0.2)
	await tween.finished
	var 场景资源 = load("res://场景/功能/存档/存档界面.tscn")
	var 窗口实例 = 场景资源.instantiate()
	get_tree().current_scene.add_child(窗口实例)
	遮罩.hide()
	
func 新游戏() -> void:
	await 渐变动画()
	Dialogic.signal_event.connect(_on_signal_event)
	Dialogic.start("res://对话/初次见面.dtl")

func _on_退出_pressed() -> void:
	await 渐变动画()
	get_tree().quit()


#endregion
