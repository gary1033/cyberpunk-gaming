# NEON MEMORIES

第二章已加入醫療／市場兩條調查線、六個事件與換路機制，並保留舊存檔進度。[最新製作紀錄](docs/chapter_branches_completed_2026_09_09.md)。

賽博龐克黑色偵探冒險遊戲 / Cyberpunk Noir Detective Adventure

## 遊戲簡介

2087年，九龍延伸區。你是凱·川崎，前正和科技安全調查員，現為落魄私家偵探。一樁失蹤案將你捲入記憶交易、企業陰謀與身份危機的漩渦中。

## 特色

- **指向點擊冒險 + 視覺小說混合玩法**
- **鷹眼義體掃描系統** — 四色能量條、12 處耗能掃描與 29 項證據補充讀取
- **證據板推理系統** — 連接證據推導真相
- **選擇與後果** — 黑市交易、幽靈身分與家人照護影響後續
- **三章劇情 + 三個結局分支**
- **39 件正式證據**
- **22 個章節地點**
- **桌面執行與手機版面** — 實體手機與網頁正式匯出仍待驗證

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

使用本機指定的 Godot 4.6.1 console 版本啟動專案：

```powershell
cd C:\Projects\cyberpunk-gaming
& 'C:\Users\gary1\OneDrive\桌面\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --path .
```

只檢查專案能否載入並立刻退出：

```powershell
cd C:\Projects\cyberpunk-gaming
& 'C:\Users\gary1\OneDrive\桌面\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --headless --path . --quit
```

直接載入單一地點場景做 smoke test：

```powershell
cd C:\Projects\cyberpunk-gaming
& 'C:\Users\gary1\OneDrive\桌面\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --headless --path . --scene res://scenes/locations/chapter1/detective_office.tscn --quit-after 2
```

## 測試

資料完整性檢查：

```powershell
python tests\test_data_integrity.py
```

找到 Godot 時，這個指令也會從新遊戲各走完三個結局，檢查章節轉場、結局先決條件及存讀檔。可用 `$env:GODOT_BIN` 指定 Godot console 執行檔；沒有找到引擎時會明確顯示通關測試被略過。

## 章節推進

- 行動點不足時，打開地圖選「休整」恢復行動點，調查進度會保留。
- 完成第一章推理後回到收束對話；第二章新遊戲須完成一條路線交接、倉庫調查與證據核對，地圖才會出現下一章按鈕。舊存檔不強制補做新增事件。
- 第三章屋頂會列出三個結局尚缺的調查。先救出浩然並取得核心證據，再選擇公開、交易或記憶恢復；結局播放完才會解鎖辦公室尾聲。
- 請在對話與轉場結束後存檔。

本輪改動與驗證：[三章流程與結局完成紀錄](docs/story_completion_2026_09_08.md)。

## 其他檢查

劇情進度覆蓋分：

```powershell
python tests\test_story_progression.py --score
```

## 專案結構

```
project.godot          # Godot 專案設定
scripts/core/          # 核心系統（遊戲管理、場景切換、存檔、輸入）
scripts/gameplay/      # 遊戲機制（對話、證據板、鷹眼）
scripts/data/          # 遊戲數據（對話、證據、角色、案件）
scripts/ui/            # UI 腳本（主選單、場景基礎）
scenes/                # 場景文件
assets/shaders/        # Shader 效果（雨、霓虹、掃描線）
```

## 素材保存與重構驗證

- 現行檔案清單：[`assets/asset_manifest.json`](assets/asset_manifest.json)。圖片原始生成與處理後來源放在 `assets/generated/`，遊戲圖片放在 `assets/sprites/`；配樂原始 OGG 與授權放在 `assets/audio/bgm/`。
- 核對所有來源指紋與路徑：`python tools/audit_assets.py`。已知四個短音效缺口會獨立列出，不代表素材全部完成。
- 共用圖片載入器支援匯入資源及尚未匯入的 PNG；PCK 回歸包含沒有原始 PNG／OGG 的封裝情況。
- [保存與重構紀錄](docs/asset_storage_refactor_2026_09_08.md)；[清理完成紀錄](docs/cleanup_completed_2026_09_08.md)。426 個舊檔已移至 Windows 資源回收筒，可還原。
