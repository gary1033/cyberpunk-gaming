# NEON MEMORIES - 開發指南

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

### 測試
- 每次 push 前執行 `python3 tests/test_data_integrity.py` 確認資料完整性
- 完整測試：`bash tests/run_tests.sh`
- CI 會在 push 和 PR 時自動執行測試（GitHub Actions）
- 測試涵蓋：場景路徑、對話 ID、證據連結、角色立繪、背景圖片、證據圖標
- **每次修復 bug 後，必須在 `tests/test_data_integrity.py` 中新增對應的回歸測試**，防止相同問題再次發生。回歸測試以 `# Bug regression:` 開頭的註解標記

### Git 慣例
- 分支: `claude/cyberpunk-game-ideas-Mok3L`
- Commit 訊息使用 conventional commits 格式（feat/fix/refactor/docs）
- 不要提交 `.godot/` 目錄或 `.import` 檔案
