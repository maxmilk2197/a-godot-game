extends Node
## ============================================================
## AI 对话管理器（全局唯一，autoload 注册名：AIChat）
## 通过 HTTP 调用兼容 OpenAI 格式的 API（/v1/chat/completions），
## 维护对话记录（裁剪到最近 N 条）并把回复用信号发回界面。
## 配置持久化在 user://aisettings.cfg（url / key / model）。
## 用法：
##   AIChat.发送消息("你好")
##   AIChat.收到AI回复.connect(func(回复): ...)
## ============================================================

const 配置路径 := "user://aisettings.cfg"
const 最大记忆条数 := 30   ## 保留最近 N 条消息（含系统提示），防止超 API 上下文上限

var 接口地址: String = "https://api.openai.com"
var 密钥: String = ""
var 模型: String = "gpt-3.5-turbo"

var 对话记录: Array = []
var 等待中: bool = false
var 已配置: bool = false

var _网络请求: HTTPRequest

signal 收到AI回复(回复内容: String)
signal AI出错(错误信息: String)

func _ready() -> void:
	加载配置()

func _聊天接口() -> String:
	# 兼容三种填法：完整端点 / 带 v1 的基地址 / 纯基地址
	if 接口地址.ends_with("/chat/completions"):
		return 接口地址
	if 接口地址.ends_with("/v1"):
		return 接口地址 + "/chat/completions"
	return 接口地址 + "/v1/chat/completions"

func 加载配置() -> void:
	var 配置 := ConfigFile.new()
	if 配置.load(配置路径) == OK:
		接口地址 = 配置.get_value("api", "url", 接口地址)
		密钥 = 配置.get_value("api", "key", 密钥)
		模型 = 配置.get_value("api", "model", 模型)
		if not 密钥.is_empty():
			已配置 = true
		print("[AI对话] 配置已加载")

func 保存配置(地址: String, 新密钥: String, 模型名: String) -> void:
	接口地址 = 地址
	密钥 = 新密钥
	模型 = 模型名
	已配置 = not 新密钥.is_empty()
	var 配置 := ConfigFile.new()
	配置.set_value("api", "url", 地址)
	配置.set_value("api", "key", 新密钥)
	配置.set_value("api", "model", 模型名)
	配置.save(配置路径)
	print("[AI对话] 配置已保存")

func 设置系统提示(提示: String) -> void:
	对话记录 = [{"role": "system", "content": 提示}]

func 清除历史() -> void:
	var 系统消息 = null
	if 对话记录.size() > 0 and 对话记录[0]["role"] == "system":
		系统消息 = 对话记录[0]
	对话记录 = []
	if 系统消息:
		对话记录.append(系统消息)


## 对话记录超长时只保留系统提示 + 最近 N 条，防止超 API 上下文上限
func _裁剪对话记录() -> void:
	if 对话记录.size() <= 最大记忆条数:
		return
	var 系统消息: Array = []
	if not 对话记录.is_empty() and 对话记录[0].get("role", "") == "system":
		系统消息 = [对话记录[0]]
	var 保留条数 := 最大记忆条数 - 系统消息.size()
	var 起始 := 对话记录.size() - 保留条数
	对话记录 = 系统消息 + 对话记录.slice(起始)

func 发送消息(用户消息: String) -> void:
	if not 已配置 or 密钥.is_empty():
		AI出错.emit("请先配置 AI API")
		return
	if 等待中:
		return

	对话记录.append({"role": "user", "content": 用户消息})
	_裁剪对话记录()
	等待中 = true

	if _网络请求:
		_网络请求.queue_free()
	_网络请求 = HTTPRequest.new()
	_网络请求.timeout = 30   # 不设的话默认无限等待，界面会一直卡在"等待中"
	add_child(_网络请求)

	var 请求体 := JSON.stringify({
		"model": 模型,
		"messages": 对话记录,
		"stream": false,
		"temperature": 0.8,
		"max_tokens": 500
	})

	var 请求头 := [
		"Content-Type: application/json",
		"Authorization: Bearer " + 密钥
	]

	var 错误 := _网络请求.request(_聊天接口(), 请求头, HTTPClient.METHOD_POST, 请求体)
	if 错误 != OK:
		等待中 = false
		_网络请求.queue_free()
		_网络请求 = null
		对话记录.pop_back()
		AI出错.emit("请求失败: " + str(错误))
		return

	_网络请求.request_completed.connect(收到回应)

func 收到回应(结果: int, 状态码: int, _响应头: PackedStringArray, 响应体: PackedByteArray) -> void:
	if _网络请求:
		_网络请求.queue_free()
		_网络请求 = null
	等待中 = false

	if 结果 != HTTPRequest.RESULT_SUCCESS:
		对话记录.pop_back()
		AI出错.emit("网络请求失败")
		return

	if 状态码 != 200:
		对话记录.pop_back()
		var 错误内容 := 响应体.get_string_from_utf8()
		print("[AI对话] HTTP错误 ", 状态码, ": ", 错误内容)
		AI出错.emit("API 返回错误 (HTTP " + str(状态码) + ")")
		return

	var 解析结果: Variant = JSON.parse_string(响应体.get_string_from_utf8())
	if 解析结果 == null or not 解析结果.has("choices") or 解析结果["choices"].size() == 0:
		对话记录.pop_back()
		AI出错.emit("API 返回数据异常")
		return

	var 回复: String = 解析结果["choices"][0]["message"]["content"]
	对话记录.append({"role": "assistant", "content": 回复})
	_裁剪对话记录()
	收到AI回复.emit(回复)
