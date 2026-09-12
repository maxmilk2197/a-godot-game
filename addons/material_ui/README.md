# Material 3 UI Kit（GDScript 版）

Godot 4 的 Material Design 3 组件库，**纯 GDScript**，不需要 .NET / Mono。
是 [`rnewquist/godot_material3`](https://github.com/rnewquist/godot_material3)（C# 版）的 GDScript 移植版。

- 目录：`addons/material_ui/`
- 启用插件后会自动注册 `M3ThemeManager` 单例（可选，不用也行）

## 组件一览

| 类名 | 继承 | 说明 |
|---|---|---|
| `M3Button` | Button | Filled / Tonal / Outlined / Text / Elevated，自带涟漪 |
| `M3Card` | PanelContainer | Elevated / Filled / Outlined 卡片容器 |
| `M3Switch` | BaseButton | 开关（`button_pressed`） |
| `M3Checkbox` | BaseButton | 复选框（`button_pressed`） |
| `M3RadioButton` | BaseButton | 单选按钮（`button_pressed`） |
| `M3Slider` | HSlider | 滑块（M3 Expressive：竖条手柄 + 胶囊轨道 + 可选离散刻度） |
| `M3TextField` | LineEdit | 输入框（Filled / Outlined） |
| `M3ProgressIndicator` | Control | 线性 / 圆形进度，支持不确定动画 |
| `M3LoadingIndicator` | Control | M3 Expressive 的 **Loading Morph**：7 个形状弹簧变形 + 匀速自转 |
| `M3Divider` | Control | 分隔线（水平 / 垂直） |
| `M3Badge` | Label | 徽标 / 小红点 |
| `M3Tab` | Button | 单个标签页 |
| `M3TabBar` | HBoxContainer | 标签栏（互斥选中，`切换(索引)`） |
| `M3NavigationBar` | PanelContainer | 底部导航栏（自动生成按钮，`切换(索引)`） |
| `M3NavigationRail` | PanelContainer | 侧边导航栏（竖向，`切换(索引)`） |
| `M3NavigationDrawer` | PanelContainer | 抽屉导航（左滑出，`打开()`/`关闭()`/`开关()`） |
| `M3Tooltip` | PanelContainer | 提示气泡（`弹出()` / `收起()`） |
| `M3Ripple` | Control | 涟漪效果（按钮内部用） |
| `M3Surface` | Panel | 主题驱动的背景条（选「角色」，跟随 M3Theme） |
| `M3ScrollStretch` | Node | 拖动滚动 + MD3 过度滚动拉长回弹 |

## 用法

组件通过 `class_name` 注册，**在编辑器里就能像普通节点一样添加**（节点类型里搜 M3）。
也可以用代码：

```gdscript
var 按钮 := M3Button.new()
按钮.text = "开始"
按钮.样式类型 = M3Button.按钮样式.TONAL
按钮.pressed.connect(_on_pressed)
add_child(按钮)
```

### 编辑器里的样子

每个组件都带 `@tool` 和 `@icon()`，所以**不用运行游戏就能看到效果**：

- 场景 → 右键 → 添加节点 → 搜 `M3`，列表里每个组件都有自己的图标（和原生节点一样）；
- 因为继承自原生控件（`Button` / `PanelContainer` / `LineEdit` …），搜 `Button` 之类的原生名字也能搜到对应组件；
- 拖进场景立刻按 M3 主题渲染，改导出属性（样式类型 / 圆角 / 字号…）即时刷新；
- 图标在 `addons/material_ui/icons/`，用的是 **Godot 节点图标的那个绿 `#6aff7c`**
  （从编辑器里量出来的：场景树里所有节点图标都是这个色；蓝色那批是下面「文件系统」面板的文件夹）；
  导入参数开了 `editor/scale_with_editor_scale`，会跟着编辑器缩放。
- ⚠️ `editor/convert_colors_with_editor_theme` 是**关掉**的。实测它确实会按编辑器主题改色
  （源文件写 `#6aff7c`，导入后变成 `#32ff56`），而原来源文件里的 `#e0e0e0` 又不在它的映射表里，
  所以一直保持灰色 —— 这正是「图标跟原生节点颜色不一致」的原因。关掉它颜色才精确可控。
- 🔴 **带 `static var` 的类必须加 `@tool`，否则编辑器里静态初始化不执行。**
  Godot 在编辑器里只会跑 `@tool` 脚本的 `static var` 初始化；不加的话那些变量全是零值 ——
  `M3Theme.primary` 变黑、`M3Theme.scale` 变 `0`，结果是**所有 M3 组件在编辑器里渲染成黑块或干脆不渲染**
  （运行时又是好的，所以很容易漏掉）。
  目前带 `static var` 的是 `M3Theme` 和 `M3MaterialShapes`，两个都加了 `@tool`。
  以后新增这类类时记得跟上。

`M3LoadingIndicator` 默认在编辑器里也播放动画（`编辑器预览 = true`），节点多了可以关掉。

## Loading Morph（`M3LoadingIndicator`）

一个形状在 7 个 MaterialShapes 之间弹簧式变形，同时整体匀速自转，每变一次形状额外转 90°。
参数对齐 AndroidX `LoadingIndicator.kt`：

| 项 | 值 |
|---|---|
| 容器 | 48dp，全圆角 |
| 活动形状 | 容器的 0.66 倍 |
| 整体自转 | 4666ms 一圈（匀速） |
| 变形间隔 | 650ms |
| 变形弹簧 | dampingRatio 0.6 / stiffness 200（欠阻尼，过冲约 9.5%） |

```gdscript
var 转圈 := M3LoadingIndicator.new()
转圈.尺寸 = 48
转圈.变体 = M3LoadingIndicator.显示变体.容器   # 独立（透明底）/ 容器（primary_container 圆底）

# 定量模式：把 进度 设成 0~1，形状从「圆」补间到「软爆」
var 定量 := M3LoadingIndicator.new()
定量.进度 = 0.4
```

形状数据在 `M3MaterialShapes`（7 个不定量形状 + 定量用的「圆」）。
每个形状都绕中心星形凸，所以按 **128 等分角存半径**就够了 —— 点 = r(θ)·(cosθ, sinθ)，
比存 x/y 省一半空间，还原误差 &lt; 7e-5。

### 尺寸：跟着控件走

图形按**控件的实际大小**画，取短边（保持正方形），再乘 `活动比例`：

| 控件尺寸 | 图形边长 |
|---|---|
| 48×48（默认） | 48 × 0.66 = 31.7 |
| 200×200 | 200 × 0.66 = 132 |
| 777×428 | **428** × 0.66 = 282 |

`尺寸` 只是**默认 / 最小尺寸**（写进 `custom_minimum_size`）——在编辑器里把节点拉大，
图形会跟着放大；想让形状占满短边就把 `活动比例` 调到 `1.0`。

## 环形加载（`M3ProgressIndicator` 的圆形不定量）

照 mdui / MDC 的 `circular-progress` 做的，是**双半圆遮罩**方案：两个 clipper 各露出一半圆环，
里面的 `<circle>` 用 `stroke-dasharray=周长` + `stroke-dashoffset=周长/2` **只画半圈**，
再各自被 `left-spin` / `right-spin` 反向旋转。把两半在屏幕上的可见部分并起来，等价于一整段弧：

```
起始角 = 容器自转 + 图层旋转 + 钳口角
扫过角 = 540° − 2 × 钳口角
```

| 项 | 值 | 缓动 |
|---|---|---|
| 容器整圈自转 | 1568ms，360° | linear |
| 图层旋转 | 5332ms，1080°（8 段 × 135°） | standard（每段各缓动一次） |
| 半圆钳口伸缩 | 1333ms，265° ↔ 130° | standard |

于是弧长在 **10° ~ 280°** 之间伸缩，一个图层周期里正好 4 轮。

**关键性质**：图层每段 666.5ms，与钳口半周期同长、同缓动，两者叠加后
**两个端点全程都只前进、不会有一端倒着缩**；而且一段里一端恒速 229.6°/s、
另一端甩到约 1870°/s，下一段互换——这就是 Material 环形进度那种「一头稳稳走、一头追上去」的手感。

> 早期版本用的是自创的「尾钉住、头往前跑」两段式，实测头速会到 **−874°/s**（倒缩 29°）、
> 尾速从 162 跳到 704°/s。现在这套实测：两端倒退帧数 **0**，跨所有周期边界速度连续。

确定进度的弧长变化是 500ms + `standard` 的过渡（mdui 的 long2）。

## 滑块（`M3Slider`）

M3 Expressive 的滑块：**胶囊轨道 + 竖条手柄**，不是传统圆钮。用法和 `HSlider` 完全一样
（`value` / `value_changed` / `min_value` / `max_value` / `step` 全都在）。

几何取自 md3e 的 `<md-slider>`：

| 部件 | 规格 |
|---|---|
| 轨道 | 16dp 高、全圆角；底轨 `secondary_container`，已选段 `primary` |
| 手柄 | 44dp 高；静止 **4dp** 宽、悬停 **6dp**、按下/聚焦 **2dp** 且 `scale(1.15, 0.95)` |
| 刻度点 | 4dp 圆点；已经过的 `on_primary`@0.7，还没到的 `on_secondary_container`@0.5 |
| 手柄宽度过渡 | 200ms（expressive 空间弹簧） |
| 数值气泡 | `inverse_surface` 底 + `inverse_on_surface` 字、8dp 圆角；按住或悬停时出现，**底边正好压在轨道上沿**（md3e 的 `bottom:32px` 换算过来就是这个位置），手柄竖条上半截藏进气泡里 |

```gdscript
var 滑 := M3Slider.new()
滑.min_value = 0; 滑.max_value = 100; 滑.step = 10; 滑.value = 60
滑.显示刻度 = true     # 画离散刻度点（按 step 自动算，>40 个就不画）
滑.刻度数 = 0          # 想手动指定刻度段数就设这里
滑.显示数值 = true     # 按住/悬停时手柄上方出现数值气泡
滑.气泡字号 = 20       # 在 1920 画布下 14 太小，按需调大
```

设置页的两条音量滑块已经开了 `显示数值`、`气泡字号 = 20`（那里标签字号是 26，14 会显得很小）。

### 一个容易踩的坑：`has_focus()` ≠ `:focus-visible`

参考实现里手柄变细用的是 CSS 的 `:focus-visible`（**只有键盘切过来的焦点**才算）。
Godot 没有对应概念，直接用 `Control.has_focus()` 会出事：**鼠标点一下滑块也会给它焦点**，
于是手柄被永久锁在按下宽度（2dp），之后再怎么悬停都不会放大，移开也不回弹。

所以这里自己判：`focus_entered` 时看 `Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)`——
按着鼠标拿到的焦点是点出来的，不算；`drag_started` 时也直接清掉这个标记。

轨道两端各留出手柄一半，所以 0% 和 100% 时手柄不会探出控件外。

> 实现方式：把 `slider` / `grabber_area` / `grabber` 等内建 StyleBox 全部换成
> `StyleBoxEmpty`，所有绘制改由 `_draw()` 完成 —— 这样既保留了 `HSlider` 的取值、
> 拖动和信号，外观又能完全自己控制。

## 主题 / 配色

颜色令牌集中在 `M3Theme`（静态类，不需要 autoload）：

```gdscript
M3Theme.primary = Color(0, 0.349, 0.78)
M3Theme.应用种子(Color("0b57d0"))   # 按种子色派生整套令牌
M3Theme.scale = 1.5                 # 整套组件整体放大
```

`M3Theme.应用种子()` 内部走 **`M3Palette`**：在 **CIELAB** 空间里以 L\*（就是 MD3 里 tone 的定义）取各级色调，
固定色相/彩度、超出 sRGB 色域时自动降彩度，比 HSV 插值准得多。
各令牌的取法遵循 MD3 映射（primary=tone40、primaryContainer=tone90、surface=tone98、outline=neutralVariant tone50 …）。

颜色角色是**完整 37 个**（primary / secondary / tertiary / error / background / surface /
surface container lowest…highest / surface dim / surface bright / inverse / outline / shadow / scrim），
其中 `background`、`on_background`、`scrim` 是做 dialog / drawer / snackbar 的必需品。
surface container 的 tone 取值（浅色 100/96/94/92/90，深色 4/10/12/17/22）来自 mdui 的实测实现。

`M3Button` 的状态层 / 涟漪有两条变体相关的规则（见 `状态色()` 与 `涟漪峰值()`）：

- **色调（TONAL）按钮**的状态色用 `on_secondary_container` 而不是 `secondary_container`——
  它的底色本身就是 `secondary_container`，叠同色等于没有反馈。
- **填充（FILLED）和色调按钮**的涟漪峰值会被压低（×0.32 / ×0.22）——
  涟漪色与底色明度差大，按 `涟漪不透明度` 全量叠上去会把整颗按钮冲淡或压黑，文字对比度跟着掉。

### 涟漪的两种速度（`M3Ripple`）

**时长可以三层配置，从全局到单个按钮：**

| 层 | 在哪改 | 作用范围 |
|---|---|---|
| ① 全局（推荐） | **项目设置 → `m3/ripple`** | 整个项目所有按钮，不用改代码 |
| ① 全局（代码） | `M3Theme.涟漪长按时长` 等 5 个静态变量 | 同上，程序里随时改 |
| ② 单个按钮 | 按钮检视器里的 **「涟漪」分组** | 只影响这一个按钮 |

按钮上的 5 个涟漪导出属性**默认都是 `-1` = 跟随全局**；设成 `0` 或正数才单独覆盖。
涟漪实例（`M3Ripple`）自己的那 4 个时长同理，也是 `-1` 跟随全局。

```gdscript
# 全局：一行改完，所有按钮都跟着变
M3Theme.涟漪长按时长 = 0.8

# 单个按钮：只让这一颗慢慢铺开
按钮.涟漪长按时长 = 1.5
```

| 项 | 全局变量 | 项目设置键 | 默认 |
|---|---|---|---|
| 起始不透明度 | `M3Theme.涟漪不透明度` | `m3/ripple/opacity` | 0.55 |
| 长按时长 | `M3Theme.涟漪长按时长` | `m3/ripple/hold_duration` | 0.45s |
| 扩散时长 | `M3Theme.涟漪扩散时长` | `m3/ripple/spread_duration` | 0.225s |
| 淡入时长 | `M3Theme.涟漪淡入时长` | `m3/ripple/fade_in_duration` | 0.075s |
| 淡出时长 | `M3Theme.涟漪淡出时长` | `m3/ripple/fade_out_duration` | 0.15s |

> 项目设置里那几项由 `plugin.gd` 在 `_enter_tree` 时登记，
> 再由 `M3ThemeManager` 单例在启动时读进 `M3Theme`。
> 插件没启用、或没设过，就保持 `M3Theme` 里的默认值。

各时长的含义：

| 导出属性 | 用在哪 |
|---|---|
| `长按时长` | **按住不放**时的扩散速度（慢，长按过程才看得清波形） |
| `扩散时长` | **松开**后补完剩余部分的「原来的速度」（mdui 的 225ms） |
| `淡入时长` | 不透明度淡入（mdui 的 75ms） |
| `淡出时长` | 松开后的淡出（mdui 的 150ms） |

松开时剩余部分按 `clampf(扩散时长 × 剩余, 0.04, 0.10)` 补完，所以：

- **轻点**：按下瞬间就松手 → 波形只长了一点点，然后 0.10s 内补满、0.15s 淡出，整体约 0.26s，很脆；
- **长按**：0.45s 慢慢铺开（90ms 时才到一半、225ms 才接近满），按住期间一直保持；
- **长按到一半松手**：剩余那段仍按上面的原速补完，不会跟着变慢。

想整体调快调慢，改 `M3Ripple` 上的这两个导出属性即可（按钮是运行时 `M3Ripple.new()` 出来的，
所以改脚本默认值就是全局生效）。

### 松手事件被吃掉时的兜底

`M3Button` 除了监听 `button_up`，按住期间还会用 `_process` 盯一下
`Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)`，松开了就自己收掉涟漪。

原因是：`M3ScrollStretch` 在拖拽滚动时会 `set_input_as_handled()` 把松手事件吃掉
（这是为了让「拖动 = 滚动，不算点击」），而 Godot 里 `_input` 比 GUI 派发**更早**，
于是按钮永远收不到 `button_up`，涟漪就一直停在满格——看起来就是「松手了还高亮着」。

触摸会模拟成鼠标左键（Godot 默认 `emulate_mouse_from_touch`），所以这一条同时覆盖鼠标和手指。
键盘激活（没有指针按下）时不会开这个兜底。

## 动效令牌（`M3Motion`）

数值对齐 **m3e（Material 3 Expressive）** 与 **mdui 2** 的官方 sys token，全部是静态常量 / 静态函数，直接拿来用：

```gdscript
# 时长
M3Motion.短4          # 0.20s   —— 状态层、小图标
M3Motion.中3          # 0.35s
M3Motion.长2          # 0.50s

# 弹簧（M3 Expressive 的空间位移曲线，y 会略微超过 1，带一点点过冲）
M3Motion.弹簧_快_时长  # 0.35s
M3Motion.弹簧_快(t)    # cubic-bezier(0.27, 1.06, 0.18, 1)
M3Motion.弹簧_默认_效果(t)  # 颜色/透明度用，不过冲

# 缓动（真·三次贝塞尔，等价 CSS cubic-bezier）
M3Motion.强调减速(t)   # cubic-bezier(0.05, 0.7, 0.1, 1) —— 进场
M3Motion.强调加速(t)   # cubic-bezier(0.3, 0, 0.8, 0.15) —— 退场

# 状态层不透明度
M3Motion.状态_悬停 / 状态_聚焦 / 状态_按下 / 状态_拖动
```

`M3Motion.三次贝塞尔(进度, x1, y1, x2, y2)` 是共用的 CSS 等价求解器，要自定义曲线时用它。

### 真·弹簧（Compose MotionScheme）

上面那组 `弹簧_*` 是「看起来像弹簧」的贝塞尔曲线。需要**真的弹**的时候用这一组，
它是二阶阻尼谐振子的**解析解**，数值取自 AndroidX Compose 的 `MotionScheme`：

```gdscript
# 预设：[阻尼比, 刚度, 质量]
M3Motion.弹簧方案["表现_空间_中"]   # 0.70 / 450 —— M3 Expressive 默认的空间位移
M3Motion.弹簧方案["标准_空间_中"]   # 1.00 / 700 —— 不过冲的标准方案

M3Motion.弹簧解(0.2, 0.7, 450.0)          # 自定义：t 秒时的位置（0→1，欠阻尼会 >1）
M3Motion.弹簧按预设(0.2, "表现_空间_中")   # 按预设名
M3Motion.弹簧时长(0.7, 450.0)             # 算稳定时间，用来决定 tween 跑多久
```

| 预设 | 阻尼比 | 刚度 | 过冲 | 稳定 |
|---|---|---|---|---|
| 表现_空间_慢 | 0.70 | 250 | 4.6% | 0.81s |
| 表现_空间_中 | 0.70 | 450 | 4.6% | 0.61s |
| 表现_空间_快 | 0.75 | 800 | 2.8% | 0.48s |
| 表现_效果_慢/快 | 1.00 | 800 / 1400 | 无 | 0.45 / 0.35s |
| 标准_空间_慢/中/快 | 1.00 | 300 / 700 / 1400 | 无 | 0.71 / 0.48 / 0.35s |

用 `tween_method` 驱动时把归一化时间乘回秒数即可，例如

```gdscript
补间.tween_method(
	func(t: float) -> void: 控件.scale = Vector2.ONE * lerpf(0.9, 1.0, M3Motion.弹簧按预设(t * 0.6, "表现_空间_中")),
	0.0, 1.0, 0.6)
```

## 形状令牌（`M3Shape`）

```gdscript
M3Shape.特小   # 4
M3Shape.小     # 8
M3Shape.中     # 12
M3Shape.大     # 16
M3Shape.大加强 # 20
M3Shape.特大   # 28
M3Shape.特大加强 # 32
M3Shape.超特大 # 48
M3Shape.全圆   # 9999（药丸）
```

配合 `M3Theme.样式(色, M3Shape.大)` 使用；组件的 `圆角` 导出属性默认值就是这些令牌。

## 和项目现有的 1920×1080 缩放

项目已经有「1920 渲染 + 窗口缩放」，所以 `M3ThemeManager.自动缩放` **默认关闭**，
避免双重缩放。想用它的缩放再打开即可。
