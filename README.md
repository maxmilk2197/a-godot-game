# 养只妹妹 (Raising a Little Sister)

> A **raising × visual novel (dating-sim / romantic raise)** game made with Godot 4.
> One night, a girl who calls herself your "little sister" — **A-yun** — knocks on your door. From that day on, you live under the same roof: talk to her, cheer her up, and spend your days together.

> 一个用 Godot 4 制作的 **养成 × 视觉小说（Galgame / 恋爱养成）** 游戏。
> 在某个夜里，一个自称是你「妹妹」的女孩 **阿云** 敲开了你的家门。从那天起，你们住在同一个屋檐下——陪她说话、逗她开心、一起把日子过下去。

---

## 🎮 Game Overview / 游戏简介

**EN**
- **Genre**: 2D raising / visual novel (dialogue-driven, with raising stats)
- **Engine**: Godot 4.7 (`config/features = "4.7"`, Mobile renderer, Jolt physics)
- **Language**: Simplified Chinese
- **Version**: 0.05 (test build)
- **Resolution**: 1280×720, stretchable

An opening plays first (first meeting), then you enter the "home" scene to begin the raising gameplay.

**中文**
- **类型**：2D 养成 / 视觉小说（剧情对话为主，辅以养成数值）
- **引擎**：Godot 4.7（Mobile 渲染、Jolt 物理）
- **语言**：中文（简体）
- **版本**：0.05（测试版）
- **分辨率**：1280×720，可拉伸

开局会播放一段片头（初次见面），之后进入「家」的场景正式开始养成。

---

## ✨ Core Gameplay / 核心玩法

### Raising System (Stats) / 养成系统（数值）

Actions during the day influence your sister's stats, which are persisted to your save file:
通过日常行动影响妹妹的状态，属性会持久化到存档：

| Stat / 属性 | Description / 说明 | Initial / 初始 |
| ---- | ---- | ---- |
| 心情 Mood | 0~100, sister's mood / 妹妹的心情 | 60 |
| 好感 Affection | 0~100, closeness with sister / 与妹妹的亲密度 | 30 |
| 体力 Stamina | 0~100, energy / 精力 | 70 |
| 金币 Gold | Money, earned by chores / 金钱 | 0 |
| 游玩天数 Days | From day 1 / 从第 1 天开始 | 1 |
| 时段 Period | Day / Night / 白天 / 晚上 | Day 白天 |
| 行动点 Actions | Actions available per period / 每个时段可行动次数 | 3 |

- Sleeping toggles Day ⇄ Night (night→day increases the day counter), resets action points and restores stamina.
- Stat changes from dialogue have a ±2 random jitter.
- **睡觉**：白天 ⇄ 晚上切换（晚上→白天时天数 +1），重置行动点、恢复体力。
- 对话里的数值变化会带 ±2 随机浮动。

### Raising Actions (home bottom bar) / 养成行动（「家」底部行动栏）

**EN**
- **交流 Talk** / **摸摸 Pat**: trigger story dialogue with A-yun, affecting mood & affection.
- **做家务 Chore**: spend stamina and earn gold.
- **睡觉 Sleep**: toggle day/night / advance the day.
- **离开 Leave**: go to the outside world (currently only "go home").

**中文**
- **交流 / 摸摸**：触发与阿云的剧情对话，影响心情与好感。
- **做家务**：消耗体力，赚取金币。
- **睡觉**：翻天 / 推进天数。
- **离开**：前往屋外世界（目前只有回家）。

### Story Dialogue (Dialogic-driven) / 对话剧情（Dialogic 插件驱动）

**EN**
- Multiple timelines under `res://对话/*.dtl`: first meeting, bedroom, raising talk, raising pat…
- Supports choice branches, text input, character portraits (default / angry), BGM / SFX, and auto save/load.

**中文**
- 多条 `res://对话/*.dtl` 剧情线：初次见面、卧室、养成交流、养成摸摸……
- 支持选择分支、文本输入、立绘表情（默认 / 生气的云）、BGM / 音效、自动存读档。

### AI Chat (LLM-powered) / AI 聊天（接入大模型）

**EN**
- At home you can open **AI Chat** with your sister; she talks to you in real time with her "bratty little devil (メスガキ)" personality.
- Configure API URL / key / model / system prompt in the popup.
- Conversation history is persisted per save slot and auto-restored next time.

**中文**
- 在家里可与妹妹打开 **AI 聊天**，她会以「雌小鬼（メスガキ）」的性格和你实时对话。
- 可在弹窗中配置 API 地址 / 密钥 / 模型 / 系统提示词。
- 对话记录按存档槽位持久化，下次进入自动恢复。

### Phone System / 手机系统

**EN**
- Status-bar time **follows the day/night period** (day & night each remember their own time; click to edit, persisted).
- **Album**: the wallpaper is a photo; tap the invisible hotspot on the wallpaper to open the album full-screen.
- **Chat App**: chat online with your sister / A-yun, with optional AI auto-replies.

**中文**
- 手机主界面：状态栏时间 **跟随游戏时段自动切换**（白天/晚上分别记忆，点击可编辑，持久化保存）。
- **相册**：壁纸即照片，点击壁纸空白处的**隐形链接**可打开相册全屏查看。
- **聊天 App**：与妹妹/阿云在线聊天，支持 AI 自动回复。

### Computer System / 电脑系统

**EN**
- Simulated desktop with closable windows.
- Built-in lightweight **terminal** supporting `help`, `echo`, `whoami`, `pwd`, `clear`, `exit`, plus real `ssh user@host command` (uses system OpenSSH).

**中文**
- 模拟桌面 + 可关闭的窗口。
- 内置简易 **终端**，支持 `help`、`echo`、`whoami`、`pwd`、`clear`、`exit`，以及真的 `ssh user@host command`（调用系统 OpenSSH）。

---

## 🕹️ Controls / 操作

**EN**
| Control | Effect |
| ---- | ---- |
| Left mouse / Space / Enter | Advance dialogue, click buttons |
| Right-click / Esc | Close phone and other UI |
| Click status-bar time | Edit current period's time (HH:MM) |
| Click blank wallpaper | Open album |

**中文**
| 操作 | 效果 |
| ---- | ---- |
| 鼠标左键 / 空格 / 回车 | 推进对话、点击按钮 |
| 右键 / Esc | 关闭手机等界面 |
| 点击状态栏时间 | 编辑当前时段显示的时间（HH:MM） |
| 点击壁纸空白处 | 打开相册 |

---

## 📥 Getting & Running / 获取与运行

### Windows Test Build / Windows 测试版

**EN**
Run the exported executable directly:
```
下载/养只妹妹_测试版.exe
```
(Single file with embedded PCK — no Godot installation needed.)

**中文**
- 直接运行导出的可执行文件：
  ```
  下载/养只妹妹_测试版.exe
  ```
  （单文件，已内嵌 PCK，无需安装 Godot。）

### Run from Source / 从源码运行

**EN**
1. Install [Godot 4.7](https://godotengine.org/download/archive/) (or 4.6+, 4.7 recommended).
2. Open `project.godot` at the repository root with Godot.
3. Wait for the first import to finish, then press **F5** to run.

**中文**
1. 安装 [Godot 4.7](https://godotengine.org/download/archive/)（或 4.6+，推荐 4.7）。
2. 用 Godot 打开项目根目录下的 `project.godot`（即本仓库根目录）。
3. 首次打开会自动导入资源，等待完成后按 **F5** 运行。

---

## 🛠️ Export from Source (Windows) / 从源码导出（Windows）

```
Godot_v4.7-stable_win64_console.exe --headless --path <project root> --export-release "Windows Desktop" <output>.exe
```

**EN**
The matching **export templates** must be installed (`%APPDATA%\Godot\export_templates\4.7.stable`). The project includes `export_presets.cfg` with Windows / Linux / Android presets.

**中文**
需要先在本机安装对应的 **导出模板**（`%APPDATA%\Godot\export_templates\4.7.stable`）。
项目内置 `export_presets.cfg`，包含 Windows / Linux / Android 预设。

---

## 📁 Project Structure / 项目结构

```
a-godot-game/
├─ project.godot            # Engine config (autoload / Dialogic / input) 工程配置
├─ export_presets.cfg       # Export presets (Win / Linux / Android) 导出预设
├─ 场景/  Scenes            # UI scenes
│  ├─ 主菜单/ Main menu      # 主菜单、设置、关于
│  ├─ 家/ Home               # 客厅（养成面板、AI 聊天、手机入口）
│  ├─ 屋外/ Outside          # 屋外世界
│  ├─ 手机/ Phone            # 手机主界面、聊天、相册
│  ├─ 电脑/ Computer         # 电脑主界面、窗口、终端
│  ├─ 存档/ Save             # 存档保存 / 加载窗口
│  └─ 测试/ Test             # 养成测试
├─ 脚本/  Scripts (GDScript)
│  ├─ 全局/ Global (autoload)# 存档、养成、AI 对话、设置、音量……
│  ├─ 手机/ 电脑/ 家/ 屋外/ 存档界面/ 主菜单/
├─ 对话/ Dialogues           # Dialogic timelines (*.dtl)
├─ 角色/ Characters          # 角色定义（阿云 yun、你、旁白）
├─ 资源/ Assets              # 字体、纹理、音频、对话主题、主题、着色器、stylebox
└─ addons/dialogic/          # Dialogic dialogue plugin
```

### Global Autoloads / 全局自动加载（autoload）
`Dialogic`、`cmd`、`save`（存档）、`info`（全局变量）、`AIChat`（AI 对话）、`Raise`（养成）、`Audio`（音量）、`Settings`（设置数据）、`SceneNav`（场景导航）。

---

## 🔧 Key Technical Points / 主要技术点

**EN**
- **Dialogue**: Dialogic 2.x plugin; theme at `资源/对话主题/02.tres` — dialogue bubble / name plate / choice buttons use a warm & cozy style (rounded corners, translucency, soft shadows).
- **Unified UI Theme**: `资源/主题/温馨主题.tres` — unified rounded buttons / input fields / panels.
- **Effects**: `资源/着色器/亚克力.gdshader` — Gaussian-blur frosted glass for the phone and computer dock.
- **AI Chat**: `脚本/全局/AI对话管理器.gd` — HTTP calls to an OpenAI-compatible API.
- **Saving**: JSON save files at `user://Saves/save_N.json`, multi-slot + autosave.

**中文**
- **对话**：Dialogic 2.x 插件，主题资源 `资源/对话主题/02.tres`，对话气泡/名字栏/选项为温馨治愈风（圆角、半透明、柔和阴影）。
- **统一 UI 主题**：`资源/主题/温馨主题.tres`，统一圆角按钮 / 输入框 / 面板风格。
- **界面效果**：`资源/着色器/亚克力.gdshader` 高斯模糊毛玻璃，用于手机 / 电脑底栏。
- **AI 聊天**：`脚本/全局/AI对话管理器.gd`，走 HTTP 调用兼容 OpenAI 格式的 API。
- **存档**：JSON 存档于 `user://Saves/save_N.json`，支持多槽位 + 自动保存。

---

## ⚠️ Notes & Disclaimer / 已知说明与免责声明

**EN**
- Some images (backgrounds / portraits / buttons) come from public asset packs and the web — **for study & sharing only**; do not use them for commercial release.
- Fonts: HarmonyOS Sans, LXGW WenKai Mono, GenSenRounded, etc. — respect each license.
- AI chat requires you to configure a working API key yourself; the game ships no key.
- The AI "prompt" contains an adult-oriented setting with an **optional toggle** string in the source (you can delete/modify it). Please mind content ratings and compliance.
- Test build may contain unfinished scenes (e.g., the outside world only offers "go home").

**中文**
- 本游戏使用到的部分图片素材（背景/立绘/按钮）来自公开素材包与网络，**仅用于学习交流**；请勿将资源用于商业发布。
- 字体：HarmonyOS Sans、LXGW WenKai Mono、GenSenRounded 等，请按各自许可证使用。
- AI 聊天需要自行配置可用的 API 密钥，游戏本身不内置任何密钥。
- 涉及 AI 对话的「提示词」中带有成人向设定的**可选开关**字符（项目源码中可自行删除/修改），请注意内容分级与合规。
- 测试版可能存在未完成场景（如屋外世界目前仅「回家」）。

---

## 📌 Roadmap / 可扩展方向

**EN**
- [ ] More storylines & events
- [ ] Outside world with multiple explorable locations
- [ ] Album with multiple photos & swipe viewing
- [ ] Edit "day / night time" in the settings page
- [ ] More raising gameplay (part-time jobs, shopping, festival events)

**中文**
- [ ] 更多剧情线与事件
- [ ] 屋外世界多地点探索
- [ ] 相册多照片、滑动查看
- [ ] 设置页加入「白天时间 / 晚上时间」编辑
- [ ] 更多养成玩法（打工、逛街、节日事件）

---

## 📄 License / 许可

**EN**
This project is for study and sharing. Third-party plugins (e.g., Dialogic) and assets belong to their respective authors.

**中文**
本项目仅供学习与交流。所用第三方插件（Dialogic 等）与素材版权归其各自作者所有。
