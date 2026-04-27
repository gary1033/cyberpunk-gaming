# NEON MEMORIES Image2.0 資產生成狀態

更新日期：2026-04-27

## Prompt 來源

| 類型 | Prompt 檔 | 數量 | 狀態 |
|---|---|---:|---|
| 場景背景 | `assets/generated/prompts/image2_backgrounds.jsonl` | 15 | 已生成並已整理到 `assets/generated/backgrounds/` 與 `assets/sprites/locations/` |
| 證據物品 | `assets/generated/prompts/image2_items.jsonl` | 28 | 已生成 21 張 Image2.0 版本並同步覆蓋到 `assets/sprites/items/`；其餘 7 張沿用既有 PNG |
| UI 元件 | `assets/generated/prompts/image2_ui.jsonl` | 5 | 已生成 5 張 Image2.0 版本並同步覆蓋到 `assets/sprites/ui/` |
| 角色概念設定表 | `docs/character_art_prompts.md` | 12 | 已生成並整理到 `assets/generated/characters/reference_sheets/` |
| 角色透明立繪 | `docs/character_portrait_image2_prompts.md` | 50 | 已整理每個角色 mood 的 image2.0 提示詞，並已用 `image_gen` 生成透明 PNG |
| 角色透明立繪 JSONL | `assets/generated/prompts/image2_character_portraits.jsonl` | 50 | 已由 Markdown 轉出，可供 image2.0 CLI 批次生成 |

Image2.0 原始生成資料夾：

```text
C:\Users\gary1\.codex\generated_images\019dca72-c0b6-7a62-8c5d-768e07568751
```

## 本輪新增落地資產

### 場景背景 Image2.0 版

輸出資料夾：

```text
assets/generated/backgrounds/
assets/sprites/locations/
```

共 15 張，皆為 `1280x720` PNG：

```text
detective_office.png
mei_ling_apartment.png
abyss_bar.png
hao_ran_workshop.png
east_district_street.png
bitstorm_cafe.png
memory_black_market.png
abandoned_warehouse.png
zhengtek_exterior.png
sewer_passage.png
echo_network_hq.png
secret_lab.png
memory_space.png
rooftop.png
office_epilogue.png
```

備註：Image2.0 原始輸出中有 1 張額外的 `detective_office` 重複圖，本輪採用較適合偵探辦公室主場景的版本，略過重複圖。

### 證據物品 Image2.0 版

輸出資料夾：

```text
assets/generated/items/
```

共 21 張，皆為 `512x512` PNG：

```text
schedule.png
symbol.png
memory_capsule.png
map.png
diary.png
ledger.png
memo.png
list.png
frequency.png
key.png
id_chip.png
report.png
funding.png
journal.png
sos.png
keycard.png
profiles.png
ai_log.png
memory_fragment.png
authorization.png
comms.png
```

### UI Image2.0 版

輸出資料夾：

```text
assets/generated/ui/
```

共 5 張 PNG：

| 檔案 | 尺寸 |
|---|---:|
| `dialogue_panel.png` | 1280x240 |
| `evidence_card.png` | 512x384 |
| `popup_panel.png` | 768x768 |
| `toolbar_buttons.png` | 1024x256 |
| `memory_preview_overlay.png` | 1280x720 |

## 目前進度總表

| 類型 | 目標數 | 已生成 | 缺少 | 備註 |
|---|---:|---:|---:|---|
| 角色概念設定表 | 12 | 12 | 0 | 已在 `assets/generated/characters/reference_sheets/` |
| 場景背景 | 15 | 15 | 0 | 已在 `assets/generated/backgrounds/` 與 `assets/sprites/locations/` |
| 證據物品遊戲圖示 | 28 | 28 | 0 | 已在 `assets/sprites/items/` |
| 證據物品 Image2.0 版 | 21 | 21 | 0 | 本輪新增到 `assets/generated/items/` |
| UI 遊戲圖示 | 5 | 5 | 0 | 已在 `assets/sprites/ui/` |
| UI Image2.0 版 | 5 | 5 | 0 | 本輪新增到 `assets/generated/ui/` |
| 角色透明立繪 Image2.0 版 | 50 | 50 | 0 | 已完成到 `assets/generated/characters/transparent_regen/`；來源 chroma-key 圖保留為 `*_chroma.png` |
| 角色透明立繪總覽 | 1 | 1 | 0 | `assets/generated/characters/transparent_regen_contact_sheet.png` 用於人工檢查一致性 |

## Runtime 接線確認

- 角色：`CharacterData` 的 50 個角色 mood 均有 `assets/sprites/characters/*.png`，由 `DialogueSystem` / `Interrogation` PNG loader 載入。
- 背景：15 個地點均有 `assets/sprites/locations/*.png`，由 `LocationBase._load_location_background()` 載入。
- 物品：`EvidenceData` 的 28 個 icon 均有 `assets/sprites/items/*.png`，由 `EvidenceBoard._load_evidence_icon()` 載入。
- UI：5 個 UI PNG 均已接入：`dialogue_panel`、`popup_panel`、`toolbar_buttons` 由 `LocationBase` 使用，`evidence_card` 由 `EvidenceBoard` 使用，`memory_preview_overlay` 由 `MemoryPreview` 使用。
- 本輪 Image2.0 item/UI 輸出已與 runtime sprite 路徑做 SHA-256 比對，`assets/generated/items/` 與 `assets/generated/ui/` 中的 PNG 均已同步到 `assets/sprites/...`。
- SVG：`assets/sprites` 內 SVG 數量為 0，runtime loader 已移除 SVG fallback。

## 後續建議

1. 仍未生成 Image2.0 版的 7 個早期物品 icon：`commission_letter`、`work_id`、`receipt`、`data_chip`、`photo`、`log`、`recording`。目前已有 PNG 且已接入，後續可視覺升級。
2. 角色透明立繪已依 `docs/character_portrait_image2_prompts.md` 逐張生成，透明 PNG 位於 `assets/generated/characters/transparent_regen/`。正式替換前仍建議人工檢查角色一致性與對話框尺寸。
3. 場景背景已有 15 張 PNG 並已接入；若要改用更精細 image2 版本，請產出後覆蓋 `assets/sprites/locations/` 並跑 `tests/test_data_integrity.py`。
4. 不要提交 `.import` 檔案；若 Godot 自動產生 `.png.import`，提交前需排除。
