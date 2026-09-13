extends Control
## ============================================================
## M3 组件测试页：把 material_ui 插件里的组件都摆出来看效果。
## 直接用 F6 运行本场景即可。
## ============================================================

var _列: VBoxContainer


func _ready() -> void:
	var 背景 := M3Surface.new()
	背景.角色 = M3Surface.表面角色.SURFACE
	背景.圆角 = 0
	背景.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(背景)

	var 滚动 := ScrollContainer.new()
	滚动.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	滚动.offset_left = 48
	滚动.offset_top = 48
	滚动.offset_right = -48
	滚动.offset_bottom = -48
	add_child(滚动)

	_列 = VBoxContainer.new()
	_列.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_列.add_theme_constant_override("separation", 20)
	滚动.add_child(_列)

	var 拉伸 := M3ScrollStretch.new()
	拉伸.name = "拉伸"
	滚动.add_child(拉伸)

	_大标题("Material 3 组件测试")
	_按钮区()
	_选择区()
	_输入区()
	_进度区()
	_加载区()
	_标签页区()
	_导航区()
	_侧边导航区()
	_其它区()
	_调色区()

	# 当「弹层」被打开时（从更多设置页进来）给一个返回按钮；
	# 直接用 F6 跑本场景时 current_scene 就是自己，不需要返回。
	var 树 := get_tree()
	if 树 != null and 树.current_scene != self:
		_加返回按钮()


func _加返回按钮() -> void:
	var 钮 := M3Button.new()
	钮.样式类型 = M3Button.按钮样式.TEXT
	钮.text = "← 返回"
	钮.字号 = 28
	钮.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	钮.offset_left = -220.0
	钮.offset_top = 32.0
	钮.offset_right = -48.0
	钮.offset_bottom = 100.0
	钮.pressed.connect(queue_free)
	add_child(钮)


# ---------------- 各分区 ----------------
func _按钮区() -> void:
	_小标题("M3Button：Filled / Tonal / Outlined / Text / Elevated")
	var 行 := _行()
	var 名称: Array[String] = ["Filled", "Tonal", "Outlined", "Text", "Elevated"]
	var 样式: Array[M3Button.按钮样式] = [
		M3Button.按钮样式.FILLED,
		M3Button.按钮样式.TONAL,
		M3Button.按钮样式.OUTLINED,
		M3Button.按钮样式.TEXT,
		M3Button.按钮样式.ELEVATED,
	]
	for i in range(名称.size()):
		var 按钮 := M3Button.new()
		按钮.text = 名称[i]
		按钮.样式类型 = 样式[i]
		按钮.pressed.connect(_按钮按下.bind(名称[i]))
		行.add_child(按钮)


func _选择区() -> void:
	_小标题("M3Switch / M3Checkbox / M3RadioButton")
	var 行 := _行()
	var 开关 := M3Switch.new()
	行.add_child(开关)
	行.add_child(_标签("开关"))
	var 复选 := M3Checkbox.new()
	复选.button_pressed = true
	行.add_child(复选)
	行.add_child(_标签("复选框"))
	var 单选 := M3RadioButton.new()
	单选.button_pressed = true
	行.add_child(单选)
	行.add_child(_标签("单选框"))


func _输入区() -> void:
	_小标题("M3TextField：Filled / Outlined")
	var 行 := _行()
	var 填充 := M3TextField.new()
	填充.placeholder_text = "填充样式输入框"
	填充.custom_minimum_size.x = 260
	行.add_child(填充)
	var 描边 := M3TextField.new()
	描边.样式类型 = M3TextField.输入样式.OUTLINED
	描边.placeholder_text = "描边样式输入框"
	描边.custom_minimum_size.x = 260
	行.add_child(描边)


func _进度区() -> void:
	_小标题("M3ProgressIndicator / M3Slider")
	var 线性 := M3ProgressIndicator.new()
	线性.类型 = M3ProgressIndicator.样式类型.LINEAR
	线性.值 = 0.6
	线性.custom_minimum_size.x = 320
	_列.add_child(线性)
	var 线性不定 := M3ProgressIndicator.new()
	线性不定.类型 = M3ProgressIndicator.样式类型.LINEAR
	线性不定.不定 = true
	线性不定.custom_minimum_size.x = 320
	_列.add_child(线性不定)

	var 行 := _行()
	var 圆 := M3ProgressIndicator.new()
	圆.类型 = M3ProgressIndicator.样式类型.CIRCULAR
	圆.值 = 0.35
	行.add_child(圆)
	var 圆不定 := M3ProgressIndicator.new()
	圆不定.类型 = M3ProgressIndicator.样式类型.CIRCULAR
	圆不定.不定 = true
	行.add_child(圆不定)
	var 滑块 := M3Slider.new()
	滑块.custom_minimum_size.x = 260
	滑块.value = 0.4
	行.add_child(滑块)


func _加载区() -> void:
	_小标题("M3LoadingIndicator：Loading Morph（7 个形状弹簧变形 + 匀速自转）")
	var 行 := _行()
	行.add_child(_标签("独立"))
	for 边 in [36, 48, 64]:
		var 器 := M3LoadingIndicator.new()
		器.尺寸 = 边
		行.add_child(器)
	行.add_child(_标签("容器"))
	var 容器 := M3LoadingIndicator.new()
	容器.尺寸 = 48
	容器.变体 = M3LoadingIndicator.显示变体.容器
	行.add_child(容器)

	# 定量模式：形状从「圆」补间到「软爆」
	var 行2 := _行()
	var 定量 := M3LoadingIndicator.new()
	定量.尺寸 = 64
	定量.进度 = 0.0
	行2.add_child(定量)
	var 滑 := M3Slider.new()
	滑.min_value = 0.0
	滑.max_value = 1.0
	滑.step = 0.01
	滑.value = 0.0
	滑.custom_minimum_size.x = 320
	滑.value_changed.connect(func(值: float) -> void: 定量.进度 = 值)
	行2.add_child(滑)
	行2.add_child(_标签("定量进度"))


func _标签页区() -> void:
	_小标题("M3TabBar / M3Tab")
	var 栏 := M3TabBar.new()
	var 名称: Array[String] = ["首页", "动态", "消息", "我的"]
	for 名 in 名称:
		var 页 := M3Tab.new()
		页.text = 名
		栏.add_child(页)
	_列.add_child(栏)


func _导航区() -> void:
	_小标题("M3NavigationBar")
	var 导航 := M3NavigationBar.new()
	导航.项目 = PackedStringArray(["消息", "通讯录", "发现", "我"])
	导航.字号 = 22
	_列.add_child(导航)


func _侧边导航区() -> void:
	_小标题("M3NavigationRail / M3NavigationDrawer")
	var 行 := _行()
	var 轨 := M3NavigationRail.new()
	轨.项目 = PackedStringArray(["消息", "通讯录", "发现", "我"])
	轨.图标名 = PackedStringArray(["message", "account-multiple", "compass", "account"])
	轨.字号 = 18
	轨.custom_minimum_size = Vector2(150, 320)
	行.add_child(轨)

	# 也可以不填 项目、改成自己往里放子节点（手动项目 = true）
	var 手轨 := M3NavigationRail.new()
	手轨.手动项目 = true
	手轨.字号 = 18
	手轨.custom_minimum_size = Vector2(150, 320)
	行.add_child(手轨)
	var 手列 := VBoxContainer.new()
	手列.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	手列.size_flags_vertical = Control.SIZE_EXPAND_FILL
	手列.alignment = BoxContainer.ALIGNMENT_CENTER
	手列.add_theme_constant_override("separation", 12)
	手轨.add_child(手列)
	for i in range(3):
		var 项 := M3NavigationRailItem.new()
		项.文字 = ["首页", "收藏", "设置"][i]
		项.图标名 = ["home", "star", "cog"][i]
		项.字号 = 18
		手列.add_child(项)

	var 开抽屉 := M3Button.new()
	开抽屉.text = "打开抽屉"
	开抽屉.样式类型 = M3Button.按钮样式.TONAL
	行.add_child(开抽屉)

	# 抽屉要挂在非容器父节点下，position 才能做滑出动画
	var 抽屉 := M3NavigationDrawer.new()
	抽屉.项目 = PackedStringArray(["首页", "消息", "设置", "关于"])
	抽屉.标题 = "M3 抽屉"
	抽屉.字号 = 20
	抽屉.展开 = false
	add_child(抽屉)
	开抽屉.pressed.connect(抽屉.开关)


func _调色区() -> void:
	_小标题("主题调色（点了重新载入页面）")
	var 行 := _行()
	_调色按钮(行, "蓝", Color(0, 0.349, 0.78))
	_调色按钮(行, "绿", Color(0.1, 0.5, 0.25))
	_调色按钮(行, "紫", Color(0.42, 0.28, 0.6))
	_调色按钮(行, "橙", Color(0.7, 0.35, 0.1))


func _调色按钮(行: HBoxContainer, 名: String, 色: Color) -> void:
	var 按钮 := M3Button.new()
	按钮.text = 名
	按钮.样式类型 = M3Button.按钮样式.TONAL
	按钮.pressed.connect(_换种子.bind(色))
	行.add_child(按钮)


func _换种子(色: Color) -> void:
	M3Theme.应用种子(色)
	get_tree().reload_current_scene()


func _其它区() -> void:
	_小标题("M3Badge / M3Card / M3Tooltip")
	var 行 := _行()
	行.add_child(M3Badge.new())
	var 徽标 := M3Badge.new()
	徽标.text = "9"
	行.add_child(徽标)

	var 提示 := M3Tooltip.new()
	提示.文本 = "这是一个 M3 提示气泡"
	_列.add_child(提示)

	var 触发 := M3Button.new()
	触发.text = "鼠标悬停看提示"
	触发.mouse_entered.connect(_显示提示.bind(提示, 触发))
	触发.mouse_exited.connect(提示.收起)
	行.add_child(触发)

	var 卡片 := M3Card.new()
	卡片.类型 = M3Card.卡片类型.FILLED
	var 卡内 := Label.new()
	卡内.text = "M3Card —— 把内容塞进卡片里就行"
	卡内.add_theme_color_override("font_color", M3Theme.on_surface)
	卡内.add_theme_font_size_override("font_size", M3Theme.fs(20))
	卡片.add_child(卡内)
	_列.add_child(卡片)


# ---------------- 小工具 ----------------
func _大标题(文字: String) -> void:
	var l := Label.new()
	l.text = 文字
	l.add_theme_font_size_override("font_size", M3Theme.fs(36))
	l.add_theme_color_override("font_color", M3Theme.on_surface)
	_列.add_child(l)


func _小标题(文字: String) -> void:
	_列.add_child(M3Divider.new())
	var l := Label.new()
	l.text = 文字
	l.add_theme_font_size_override("font_size", M3Theme.fs(24))
	l.add_theme_color_override("font_color", M3Theme.on_surface_variant)
	_列.add_child(l)


func _行() -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	_列.add_child(h)
	return h


func _标签(文字: String) -> Label:
	var l := Label.new()
	l.text = 文字
	l.add_theme_font_size_override("font_size", M3Theme.fs(20))
	l.add_theme_color_override("font_color", M3Theme.on_surface)
	return l


func _按钮按下(名: String) -> void:
	print("[M3测试] 按下: ", 名)


func _显示提示(提示: M3Tooltip, 目标: Control) -> void:
	提示.弹出(目标.global_position + Vector2(0, 目标.size.y + 8))
