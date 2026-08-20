extends Control

# =========================
# 系统信息
# =========================

var 用户名: String = "maxmilk"
var 当前目录: String = "/"

var 输入起始行: int = 0
var 输入起始列: int = 0

var SSH可用: bool = false
var _ssh线程: Thread = null

@onready var 显示区: TextEdit = $"终端"

# =========================
# 初始化
# =========================

func _ready() -> void:
	# 获取宿主系统用户名
	if OS.has_environment("USERNAME"):
		用户名 = OS.get_environment("USERNAME")
	elif OS.has_environment("USER"):
		用户名 = OS.get_environment("USER")

	# 检测 ssh
	检测SSH()

	# 信号
	显示区.gui_input.connect(_输入事件)
	显示区.caret_changed.connect(_光标改变)

	显示区.editable = true

	输出("Welcome to MMOS!\n")

	显示提示符()

# =========================
# SSH 支持
# =========================

func 检测SSH() -> void:
	var result: Array = []
	var exit_code: int

	if OS.get_name() == "Windows":
		exit_code = OS.execute("where", ["ssh"], result, true)
	else:
		exit_code = OS.execute("which", ["ssh"], result, true)

	SSH可用 = exit_code == 0

func 执行SSH(args: Array) -> void:
	if not SSH可用:
		输出("ssh: OpenSSH not installed.\n")
		return

	if args.size() < 2:
		输出("usage: ssh user@host command\n")
		return

	if _ssh线程 and _ssh线程.is_started():
		输出("ssh is already running...\n")
		return

	var target: String = str(args[0])

	var command := " ".join(args.slice(1))

	var ssh_args := PackedStringArray([
		"-o",
		"BatchMode=yes",
		"-o",
		"StrictHostKeyChecking=no",
		target,
		command
	])

	# 放后台线程执行，避免网络无响应时阻塞主线程把游戏卡死
	_ssh线程 = Thread.new()
	_ssh线程.start(_跑SSH.bind(ssh_args))


func _跑SSH(ssh_args: PackedStringArray) -> void:
	var output: Array = []
	var exit_code := OS.execute("ssh", ssh_args, output, true)

	var 结果文本 := ""
	if output.size() > 0:
		结果文本 = str(output[0]) + "\n"
	else:
		结果文本 = "ssh exited with code %d\n" % exit_code

	call_deferred("_收尾SSH", 结果文本)


func _收尾SSH(结果文本: String) -> void:
	if _ssh线程 and _ssh线程.is_started():
		_ssh线程.wait_to_finish()
		_ssh线程 = null
	输出(结果文本)

# =========================
# 输出
# =========================

func 输出(text: String) -> void:
	显示区.text += text
	移动光标到末尾()

func 移动光标到末尾() -> void:
	var line := 显示区.get_line_count() - 1

	if line < 0:
		line = 0

	显示区.set_caret_line(line)
	显示区.set_caret_column(
		显示区.get_line(line).length()
	)

# =========================
# 提示符
# =========================

func 显示提示符() -> void:
	var prompt := "%s@localhost:%s$ " % [
		用户名,
		当前目录
	]

	显示区.text += prompt

	输入起始行 = 显示区.get_line_count() - 1
	输入起始列 = prompt.length()

	移动光标到末尾()

# =========================
# 输入处理
# =========================

func 获取当前输入() -> String:
	var line := 显示区.get_line(输入起始行)

	if line.length() <= 输入起始列:
		return ""

	return line.substr(输入起始列)

func _光标改变() -> void:
	var line := 显示区.get_caret_line()
	var column := 显示区.get_caret_column()

	if line < 输入起始行:
		移动光标到末尾()
		return

	if line == 输入起始行 and column < 输入起始列:
		显示区.set_caret_column(
			输入起始列
		)

func _输入事件(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return

	if not event.pressed:
		return

	if event.echo:
		return

	match event.keycode:

		KEY_ENTER, KEY_KP_ENTER:
			var cmd := 获取当前输入()

			显示区.text += "\n"

			执行指令(cmd)

			get_viewport().set_input_as_handled()

		KEY_BACKSPACE:
			if (
				显示区.get_caret_line() == 输入起始行
				and
				显示区.get_caret_column() <= 输入起始列
			):
				get_viewport().set_input_as_handled()

		KEY_LEFT:
			if (
				显示区.get_caret_line() == 输入起始行
				and
				显示区.get_caret_column() <= 输入起始列
			):
				get_viewport().set_input_as_handled()

		KEY_HOME:
			显示区.set_caret_line(
				输入起始行
			)

			显示区.set_caret_column(
				输入起始列
			)

			get_viewport().set_input_as_handled()

# =========================
# 命令执行
# =========================

func 执行指令(text: String) -> void:
	text = text.strip_edges()

	if text.is_empty():
		显示提示符()
		return

	var args: Array = text.split(
		" ",
		false
	)

	var command := str(
		args[0]
	).to_lower()

	args.remove_at(0)

	match command:

		"help":
			命令帮助()

		"echo":
			输出(
				" ".join(args)
				+ "\n"
			)

		"whoami":
			输出(
				用户名 + "\n"
			)

		"pwd":
			输出(
				当前目录 + "\n"
			)

		"ssh":
			执行SSH(args)

		"clear":
			显示区.clear()
			显示提示符()
			return

		"exit":
			输出(
                "[Terminal Closed]\n"
			)

			显示区.editable = false
			return

		_:
			输出(
                "command not found: %s\n"
				% command
			)

	显示提示符()

# =========================
# help
# =========================

func 命令帮助() -> void:
	输出("""
Available commands:
help
echo
whoami
pwd
clear
exit
ssh user@host command
""")
