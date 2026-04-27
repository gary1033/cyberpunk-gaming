# NEON MEMORIES

賽博龐克黑色偵探冒險遊戲 / Cyberpunk Noir Detective Adventure

## 遊戲簡介

2087年，九龍延伸區。你是凱·川崎，前正和科技安全調查員，現為落魄私家偵探。一樁失蹤案將你捲入記憶交易、企業陰謀與身份危機的漩渦中。

## 特色

- **指向點擊冒險 + 視覺小說混合玩法**
- **鷹眼義體掃描系統** — 發現隱藏線索
- **證據板推理系統** — 連接證據推導真相
- **審問壓力系統** — 掌控對話節奏
- **三章劇情 + 三個結局分支**
- **28 件可收集證據**
- **15 個可探索場景**
- **跨平台支援** — 電腦、手機、網頁

## 技術

- **引擎**: Godot 4 (GDScript)
- **基準解析度**: 1280x720 (自適應縮放)
- **平台**: Windows / macOS / Linux / Android / iOS / HTML5

## 啟動方法

### 使用 Godot Editor

1. 安裝 Godot 4.6+。
2. 開啟 Godot，選擇 Import / 匯入專案。
3. 選取本專案的 `project.godot`。
4. 進入 Editor 後按 `F5` 執行遊戲。

### Windows PowerShell

使用本機指定的 Godot 4.6.2 console 版本啟動專案：

```powershell
cd C:\Projects\cyberpunk-gaming
& 'C:\Users\gary1\OneDrive\桌面\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe' --path .
```

只檢查專案能否載入並立刻退出：

```powershell
cd C:\Projects\cyberpunk-gaming
& 'C:\Users\gary1\OneDrive\桌面\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe' --headless --path . --quit
```

直接載入單一地點場景做 smoke test：

```powershell
cd C:\Projects\cyberpunk-gaming
& 'C:\Users\gary1\OneDrive\桌面\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe' --headless --path . --scene res://scenes/locations/chapter1/detective_office.tscn --quit-after 2
```

## 測試

資料完整性檢查：

```powershell
python tests\test_data_integrity.py
```

劇情進度覆蓋分：

```powershell
python tests\test_story_progression.py --score
```

重新產生本地 fallback 圖片資產：

```powershell
python tools\render_generated_assets.py
```

## 專案結構

```
project.godot          # Godot 專案設定
scripts/core/          # 核心系統（遊戲管理、場景切換、存檔、輸入）
scripts/gameplay/      # 遊戲機制（對話、證據板、審問、鷹眼）
scripts/data/          # 遊戲數據（對話、證據、角色、案件）
scripts/ui/            # UI 腳本（主選單、場景基礎）
scenes/                # 場景文件
assets/shaders/        # Shader 效果（雨、霓虹、掃描線）
```
