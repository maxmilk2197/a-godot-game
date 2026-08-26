extends Node
## ============================================================
## 设置数据（全局唯一，autoload 注册名：Settings）
## 存放各可微调开关/选项，持久化到 user://game_settings.cfg。
## 用法（脚本里读/写都会自动保存）：
##   Settings.显示对方头像 = false
##   Settings.文字速度 = 1   # 0 慢 / 1 中 / 2 快
##   Settings.自动继续 = true
##   Settings.窗口缩放 = 0.666667  # 0.5 / 0.667 / 0.833 / 1.0（窗口相对 1920×1080 渲染的分辨率比例）
##   Settings.全屏 = false
## ============================================================

const 设置路径 := "user://game_settings.cfg"

## 文字速度分档（0=慢 1=中 2=快）对应的 letter_speed（逐字间隔秒）
const 文字速度档位 := {
	0: 0.045,
	1: 0.02,
	2: 0.008,
}

## 聊天界面里是否显示「对方」消息旁的头像
var 显示对方头像: bool = true:
	set(值):
		显示对方头像 = 值
		if not _读取中:
			保存()

## 对话文字速度分档（0=慢 1=中 2=快）
var 文字速度: int = 1:
	set(值):
		文字速度 = clampi(值, 0, 2)
		if not _读取中:
			保存()

## 是否自动继续对话（逐句前进，不用每次点击）
var 自动继续: bool = false:
	set(值):
		自动继续 = 值
		if not _读取中:
			保存()

## 手机状态栏在「白天」时段显示的时间（HH:MM，可编辑）
var 白天时间: String = "12:00":
	set(值):
		白天时间 = 值
		if not _读取中:
			保存()

## 手机状态栏在「晚上」时段显示的时间（HH:MM，可编辑）
var 晚上时间: String = "21:00":
	set(值):
		晚上时间 = 值
		if not _读取中:
			保存()

## 屏幕大小分档（0=小 1=中 2=大 3=超大）对应的窗口缩放倍率
## （相对 1920×1080 渲染分辨率；中档 1280×720 为默认窗口大小）
const 窗口缩放档位 := {
	0: 0.5,
	1: 1280.0 / 1920.0,
	2: 1600.0 / 1920.0,
	3: 1.0,
}
## 渲染分辨率（画布/设计基准；窗口大小 = 设计分辨率 × 窗口缩放）
const 设计分辨率 := Vector2i(1920, 1080)
## 默认窗口缩放（对应「中」档：窗口 1280×720）
const 默认窗口缩放 := 1280.0 / 1920.0

## 窗口缩放倍率（相对设计分辨率 1920×1080；约 0.5 / 0.667 / 0.833 / 1.0）。
## 默认 0.667，即以窗口 1280×720 打开。
var 窗口缩放: float = 默认窗口缩放:
	set(值):
		窗口缩放 = clampf(值, 0.5, 2.5)
		if not _读取中:
			保存()

## 是否全屏
var 全屏: bool = false:
	set(值):
		全屏 = 值
		if not _读取中:
			保存()

## 临时导航标志：从“设置/关于”返回主菜单时，跳过一次性的主菜单 logo 动画（不持久化）
var 跳过主菜单logo: bool = false

## 读取配置期间置真，避免 setter 逐个触发重复写文件
var _读取中: bool = false


func _ready() -> void:
	读取()
	应用显示设置()


## 从配置文件恢复所有设置项
func 读取() -> void:
	_读取中 = true
	var cfg := ConfigFile.new()
	if cfg.load(设置路径) != OK:
		窗口缩放 = 默认窗口缩放
		_读取中 = false
		return
	显示对方头像 = cfg.get_value("聊天", "显示对方头像", true)
	文字速度 = cfg.get_value("对话", "文字速度", 1)
	自动继续 = cfg.get_value("对话", "自动继续", false)
	白天时间 = cfg.get_value("手机", "白天时间", "12:00")
	晚上时间 = cfg.get_value("手机", "晚上时间", "21:00")
	# 屏幕设置：默认按渲染分辨率比例打开窗口 1280×720（缩放 0.667），保存过就用保存值
	if cfg.has_section("显示"):
		窗口缩放 = cfg.get_value("显示", "窗口缩放", 默认窗口缩放)
		全屏 = cfg.get_value("显示", "全屏", false)
	else:
		窗口缩放 = 默认窗口缩放
	_读取中 = false


## 把当前所有设置项写入配置文件
func 保存() -> void:
	var cfg := ConfigFile.new()
	cfg.load(设置路径)
	cfg.set_value("聊天", "显示对方头像", 显示对方头像)
	cfg.set_value("对话", "文字速度", 文字速度)
	cfg.set_value("对话", "自动继续", 自动继续)
	cfg.set_value("手机", "白天时间", 白天时间)
	cfg.set_value("手机", "晚上时间", 晚上时间)
	cfg.set_value("显示", "窗口缩放", 窗口缩放)
	cfg.set_value("显示", "全屏", 全屏)
	cfg.save(设置路径)


## 把当前文字速度/自动继续应用到 Dialogic（运行时即时生效）。
func 应用对话设置() -> void:
	# 文字逐字速度：立即刷新所有文本节点
	Dialogic.Text.update_text_speed(文字速度档位[文字速度])
	# 自动继续：直接控制 autoadvance（改 ProjectSettings 不生效，必须改 flag）
	Dialogic.Inputs.auto_advance.enabled_forced = 自动继续


## 把当前屏幕设置（窗口缩放 / 全屏）应用到运行时窗口（仅桌面端生效）。
func 应用显示设置() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var 窗口 := get_window()
	if 窗口 == null:
		return
	if 全屏:
		窗口.mode = Window.MODE_FULLSCREEN
		return
	窗口.mode = Window.MODE_WINDOWED
	# 以设计分辨率为基准缩放，并夹在屏幕尺寸内，避免窗口超出屏幕
	var 屏幕尺寸 := DisplayServer.screen_get_size()
	var 目标尺寸 := Vector2i(roundi(设计分辨率.x * 窗口缩放), roundi(设计分辨率.y * 窗口缩放))
	窗口.size = Vector2i(mini(目标尺寸.x, 屏幕尺寸.x), mini(目标尺寸.y, 屏幕尺寸.y))
