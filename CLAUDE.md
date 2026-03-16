# CHROME AND RAIN - 開發指南

## 專案資訊
- **引擎**: Godot 4 (GDScript)
- **類型**: 賽博龐克黑色偵探冒險遊戲
- **平台**: 電腦 / 手機 / 網頁

## 開發規則

### 程式碼品質
- 每次 push 前必須檢視程式碼是否乾淨（無除錯用的 print、無未使用的變數、無註解掉的程式碼區塊）
- Push 後會交給 Codex 進行自動化程式碼檢查

### 專案結構
- `scripts/core/` — 核心系統（autoload 單例）
- `scripts/gameplay/` — 遊戲機制
- `scripts/data/` — 遊戲數據（對話、證據、角色、案件）
- `scripts/ui/` — UI 腳本
- `scenes/` — Godot 場景檔案
- `assets/shaders/` — Shader 效果

### Git 慣例
- 分支: `claude/cyberpunk-game-ideas-Mok3L`
- Commit 訊息使用 conventional commits 格式（feat/fix/refactor/docs）
- 不要提交 `.godot/` 目錄或 `.import` 檔案
