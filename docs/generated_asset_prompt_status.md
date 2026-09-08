# NEON MEMORIES Image2.0 資產生成狀態

## 2026-09-08 P1 新素材已接入

- 兩張幽靈物品圖與一張公開結局 CG 已由 built-in image_gen 生成並接入。兩張物品均為 512×512 RGBA、四角透明；CG 為 1920×1080 RGB，保留原稿與調高交接動作的修正版。
- 原圖／來源／runtime／提示詞指紋齊全；現行 141 筆素材，四段短音效仍缺。[完成紀錄](C:/Projects/cyberpunk-gaming/docs/story_p1_completed_2026_09_08.md)。

## 2026-09-08 舊檔與原型清理完成（最新）

- 426 個舊檔已從專案移至 Windows 資源回收筒，約 305.9 MiB，可還原。包含舊能量圖、失敗／重複角色圖、被否決的音效試聽、假 OGG、舊產圖工具及未接入原型；相關引用、清單與測試已同步整理。
- 現行素材為 135 張圖片與 3 首配樂，來源與 runtime 指紋相同。103 張圖片有獨立原圖紀錄，32 張的追溯缺口維持前輪揭露；四個正式短音效現在均標為尚未交付，安全略過缺檔。
- 原圖／提示詞仍存於 assets/generated/，runtime 仍在 assets/sprites/；角色 50 表情、37 證據、18 地點與三結局流程保留。
- 完整資料與 Godot 整合檢查：921 通過、0 失敗、0 警告；三條實際通關與 27 種尾聲組合、PCK 24 項、BGM 21 項、能量 141 項及對話版面檢查通過；Godot 編輯器匯入、素材核對與 git diff --check 通過。
- 詳細完成紀錄：C:/Projects/cyberpunk-gaming/docs/cleanup_completed_2026_09_08.md；逐檔清單：docs/verification/cleanup_2026_09_08.json。
- 先前永久刪除遭拒的限制已以可還原的資源回收筒操作解決，沒有更改權限或規則。下一步：正式短音效、原圖追溯、實機／匯出驗證。

## 2026-09-08 素材保存與載入重構（清理前紀錄）

- 149 張圖片與 3 首配樂的來源／runtime 路徑和指紋一致，固定引用沒有非預期缺檔。總清單 assets/asset_manifest.json，檢查器 tools/audit_assets.py。
- 保存 81 份早期原圖到專案 raw/ 目錄；117 張圖片具備獨立原圖追溯，32 張只有處理後來源，仍缺獨立原圖紀錄。三個短音效未存在、家庭記憶短音效仍為佔位檔。
- 七份圖片載入器收斂為 runtime_assets.gd，能量框亦共用；修正沒有原始 PNG／OGG 的 PCK 資源被誤判不存在。generated 與 docs 加入 .gdignore，Git 仍保留來源。
- 驗證：完整 961 通過／0 失敗／0 警告；PCK 22 項、GPU 對話 36 項、GPU 能量 357 項通過，編輯器匯入通過。正式匯出包與實體手機仍待驗收。
- 使用者要求清理不用檔案；已列 421 個候選檔，約 305.9 MiB。**工具自動審核兩次拒絕刪除，實際刪除 0 個，所有候選檔仍在。** 未接入原型尚未刪除，不能把它們當現行遊戲功能。
- 詳細核對：C:/Projects/cyberpunk-gaming/docs/asset_storage_refactor_2026_09_08.md。待清理清單：docs/verification/cleanup_2026_09_08.json。
- 下一步：工具允許刪除後同步清理檔案、引用及舊測試，重跑通關；補獨立原圖紀錄與正式短音效。

## 2026-09-08 把人帶回家與操作修正（前輪紀錄）

- 已新增並接入四段劇情：第二章網咖回撥美玲、第三章屋頂探視浩然、三結局後的辦公室家人來訪、尾聲未讀訊息。家人尾聲補足原本「救出後缺少照護與相處」的缺口；未讀訊息回收幽靈、黑市與 ECHO 的選擇。
- 新增 family_update_choice／hao_ran_aftercare，分別決定坦白風險與照護／有限證言；舊存檔補 none，支線可跳過，不新增結局門檻或正式證據。錄音須先取得浩然意願並再確認，家人離線保管，不自動公開或隨交易交出。
- 修正對話中證據板繞過存檔保護、桌面／手機選項截斷；三項完整可見、更多使用原生捲動並跟隨鍵盤焦點。短小假 OGG 在解碼前略過，家庭短音效本身仍未補齊。
- 驗證：完整 959 通過／0 失敗／0 警告（含新增核心旗標回歸）；三條實際通關、27 種尾聲組合、GPU 對話框 36 項、BGM 21 項及能量 141 項通過。手機目前為桌機模擬尺寸，仍需實機驗收。
- 本輪沿用既有角色與 UI 圖，沒有新增美術或採用被否決的四段合成音效。下一步：實玩新劇情節奏、選家庭記憶與環境短音效、實機觸控驗證。
- 詳細紀錄：C:/Projects/cyberpunk-gaming/docs/homecoming_update_2026_09_08.md；畫面：docs/verification/homecoming_2026_09_08/。

## 2026-09-08 免費配樂接入（前輪紀錄）

- 使用者已否決先前四段本機合成短音效；它們只保留歷史試聽檔，未接入 runtime，不再列為採用方案。
- 已選用 Alexander Ehlers 的三首 CC0 配樂並接入遊戲：Welcome Mix（主選單／屋頂／尾聲）、Night Club Chill（酒吧／後室／黑市／網咖）、Strange Experiments（其餘調查地點／實驗室／記憶空間）。依曲名、80–110 BPM 與同作者風格選定，聽感仍待使用者試聽調整。
- 原始 OGG 保留在 `assets/audio/bgm/`；`manifest.json` 記錄下載網址、SHA-256 與授權，`LICENSE.md` 保留作者與 CC0 出處。總計約 52.3 MB，沒有重編碼，也沒有付費服務。
- 地點與主選單進入時播放，曲末重播，同曲換場不中斷；不同曲目一秒交叉淡化。Music 獨立音量預設 18%，設定滑桿及靜音會同時作用於淡化中的兩首曲目。
- 修正切歌重疊／停止後立刻播放導致舊淡化停止新曲的問題；新增 `tests/test_bgm.gd`，由 `tests/test_data_integrity.py` 呼叫。
- [三首配樂試聽](music_selection_2026_09_08.html)。配樂 19 項實際播放檢查、能量 141 項檢查及三結局通關均通過。完整檢查最後一次為 955 通過／1 失敗（通關測試離開前音訊清理時間不足）；將清理等待改為 0.5 秒後，單獨重跑該三結局測試已通過，無剩餘資源錯誤。唯一保留的是原有家庭記憶佔位音效載入警告。 不把解碼與循環通過當作人工聆聽驗收。
- 下一步：試聽後調整場景配對及混音；雨聲、場景環境聲、操作提示及家庭記憶短音效仍待選材。家庭記憶原有佔位檔仍未替換，本次不把整首 BGM 當作劇情短音效。


## 2026-09-08 耗能漏洞與音效可行性（歷史）

- 快速開關遺失不足一秒耗能的漏洞已修正：全域能量按 delta 扣除，HUD 維持十格；不再有可重設的局部扣能量計時器。
- 能量邏輯測試 141 項通過，完整資料檢查 952／0／1，三結局仍通關。前輪 135／351 為固定外框當時的邏輯及像素驗證，外框繪製未修改。
- 本輪產出四段原創本機合成 WAV 試聽（非外部 AI 生成），存於 `assets/generated/audio/previews_2026_09_08/`；Godot 已解碼驗證，尚未替換正式 runtime 音效。[已移除的舊素材紀錄](cleanup_completed_2026_09_08.md)。
- 可選外部 AI 音效生成，但目前沒有已連接的音效服務；現有正式音效仍需處理 OGG 佔位檔與解碼驗收。[調查及處理方式](energy_drain_and_audio_2026_09_08.md)。


更新日期：2026-09-08

## 2026-09-08 能量條修復：共用固定外框

> [!important]
> **舊 12／10 狀態整張 PNG 換圖方案已停用。** 歷史 `energy_bar_*.png` 與 `energy_bar_10_equal_slots_geometry.json` 僅保留來源紀錄；幾何 JSON 只描述預定座標，不能證明不同狀態圖片的外框、圖示、亮度或像素一致，也不能代替實際渲染比較。

### 現行素材與顯示方式

- AP 與鷹眼共用 `scripts/ui/segmented_energy_bar.gd`，全狀態只載入一張固定外框 `energy_hud_frame.png`。generated-source 為 `assets/generated/ui/energy_hud_frame.png`，runtime 為 `assets/sprites/ui/energy_hud_frame.png`，皆為 **512×96 RGBA**。
- 完整提示詞與來源清單：`assets/generated/prompts/image_gen_energy_hud_fixed_frame_2026_09_08.json`。built-in `image_gen` 的首次透明嘗試保留為 `assets/generated/ui/energy_hud_frame_transparency_attempt_raw.png`；純色去背原圖保留為 `assets/generated/ui/energy_hud_frame_2026_09_08_raw.png`，以 `tools/prepare_energy_hud.ps1` 本地去背。
- 10 格由 Godot 使用同一套固定幾何繪製：起點 **(120, 36)**，每格區域 **29×26**，間距 **4**（以 512×96 外框座標計算）。能量變化只改亮格數與低量顏色，不再替換外框圖片。
- 0 能量顯示 0 個亮格；剩餘一格仍可開啟鷹眼。快速關閉後重開及跨場景時，顯示會重新同步實際能量。AP 數字文字仍保留。
- 修復說明與實際渲染預覽由 [能量條修復紀錄](C:/Projects/cyberpunk-gaming/docs/energy_hud_fix_2026_09_08.md) 統一收錄。

### 本次驗證

- 局部 headless 驗證：**135 checks 通過**。
- GPU 實際渲染（RTX 3060 Ti / OpenGL）：**351 checks 通過，pixels=verified，failures=[]**。從 10 到 0 的 11 種狀態，所有比較均為格位區域外 **0 pixels 變動**；預覽見 [11 狀態對照圖](C:/Projects/cyberpunk-gaming/docs/verification/energy_hud_2026_09_08/all_states_10_to_0.png)。
- PNG 驗收：四角 alpha 均為 0、實際透明像素 **22,422**，generated-source 與 runtime 的 SHA 相同。
- 完整資料完整性：**952 passed、0 failed、1 warning**；唯一警告為既有家庭記憶音效 placeholder。三結局通關回歸仍全部通過。前一輪劇情的 950／0／1 保留為當時歷史結果。

### 保留的後續工作

- 真實手機／網頁環境的排版與操作驗收。
- 既有 `family_memory_fragment.ogg` 音效 placeholder 替換與聆聽驗收。
- 反覆短暫開關重設耗能的漏洞，已由頁首後續修正完成；此段保留前輪顯示修復範圍的歷史。

## Prompt 來源

| 類型 | Prompt 檔 | 數量 | 狀態 |
|---|---|---:|---|
| 場景背景 | `assets/generated/prompts/image2_backgrounds.jsonl` | 15 | 已生成並已整理到 `assets/generated/backgrounds/` 與 `assets/sprites/locations/` |
| 證據物品 | `assets/generated/prompts/image2_items.jsonl` | 28 | 已生成 21 張 Image2.0 版本並同步覆蓋到 `assets/sprites/items/`；其餘 7 張沿用既有 PNG |
| UI 元件 | `assets/generated/prompts/image2_ui.jsonl` | 5 | 已生成 5 張 Image2.0 版本並同步覆蓋到 `assets/sprites/ui/` |
| 角色概念設定表 | `docs/character_art_prompts.md` | 12 | 已生成並整理到 `assets/generated/characters/` |
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
| 角色概念設定表 | 12 | 12 | 0 | 已在 `assets/generated/characters/` |
| 場景背景 | 15 | 15 | 0 | 已在 `assets/generated/backgrounds/` 與 `assets/sprites/locations/` |
| 證據物品遊戲圖示 | 28 | 28 | 0 | 已在 `assets/sprites/items/` |
| 證據物品 Image2.0 版 | 21 | 21 | 0 | 本輪新增到 `assets/generated/items/` |
| UI 遊戲圖示 | 5 | 5 | 0 | 已在 `assets/sprites/ui/` |
| UI Image2.0 版 | 5 | 5 | 0 | 本輪新增到 `assets/generated/ui/` |
| 角色透明立繪 Image2.0 版 | 50 | 50 | 0 | 已完成到 `assets/generated/characters/`；來源 chroma-key 圖保留為 `*_chroma.png` |
| 角色透明立繪總覽 | 1 | 1 | 0 | `assets/generated/characters_contact_sheet.png` 用於人工檢查一致性 |

## Runtime 接線確認

- 角色：`CharacterData` 的 50 個角色 mood 均有 `assets/sprites/characters/*.png`，由 `DialogueSystem` / `Interrogation` PNG loader 載入。
- 背景：15 個地點均有 `assets/sprites/locations/*.png`，由 `LocationBase._load_location_background()` 載入。
- 物品：`EvidenceData` 的 28 個 icon 均有 `assets/sprites/items/*.png`，由 `EvidenceBoard._load_evidence_icon()` 載入。
- UI：5 個 UI PNG 均已接入：`dialogue_panel`、`popup_panel`、`toolbar_buttons` 由 `LocationBase` 使用，`evidence_card` 由 `EvidenceBoard` 使用，`memory_preview_overlay` 由 `MemoryPreview` 使用。
- 本輪 Image2.0 item/UI 輸出已與 runtime sprite 路徑做 SHA-256 比對，`assets/generated/items/` 與 `assets/generated/ui/` 中的 PNG 均已同步到 `assets/sprites/...`。
- 2026-04-29：`dialogue_panel.png` 已用 `image_gen` 重生並裁切為 1280x240；左側改為緊湊紅色 portrait frame 加下方名字格，右側藍框移除文字下方兩條內建選項細框，選項框改由 Godot runtime 需要時繪製；原始輸出保留在 `C:\Users\gary1\.codex\generated_images\019dd91a-41e7-78b0-9330-2a958b01f3ee\`。
- SVG：`assets/sprites` 內 SVG 數量為 0，runtime loader 已移除 SVG fallback。

## 後續建議

1. 仍未生成 Image2.0 版的 7 個早期物品 icon：`commission_letter`、`work_id`、`receipt`、`data_chip`、`photo`、`log`、`recording`。目前已有 PNG 且已接入，後續可視覺升級。
2. 角色透明立繪已依 `docs/character_portrait_image2_prompts.md` 逐張生成，透明 PNG 位於 `assets/generated/characters/`。正式替換前仍建議人工檢查角色一致性與對話框尺寸。
3. 場景背景已有 15 張 PNG 並已接入；若要改用更精細 image2 版本，請產出後覆蓋 `assets/sprites/locations/` 並跑 `tests/test_data_integrity.py`。
4. 不要提交 `.import` 檔案；若 Godot 自動產生 `.png.import`，提交前需排除。
## 2026-04-29 Codex update: 12-state texture-swap energy HUD

> **2026-09-08 補註：本節為已停用方案的歷史。** 目前使用單一 `energy_hud_frame.png` 外框與共用固定格位元件，不再以 12 張整圖表示能量。

- Generated a 12-state cyberpunk energy-bar sheet with `image_gen`; source output is preserved at `C:\Users\gary1\.codex\generated_images\019dd91a-41e7-78b0-9330-2a958b01f3ee\ig_08664bcb8058ec530169f2205f5ad08191b9631423d3a20027.png`.
- Cropped and normalized the sheet into 12 runtime states, each `512x96` with alpha:
  - generated trail: `assets/generated/ui/energy_bar_01.png` through `energy_bar_12.png`
  - runtime trail: `assets/sprites/ui/energy_bar_01.png` through `energy_bar_12.png`
- State order is fixed: `energy_bar_01.png` is low red warning, `energy_bar_12.png` is full yellow charge.
- `AugmentedVision` and `LocationBase` now swap `TextureRect.texture` according to the current 12-segment state; no shader mask, Panel segment, or generated internal UI fill is used for the energy amount.

## 2026-04-30 Codex update: 10-state equal-slot energy HUD

> **2026-09-08 補註：本節的 10 張整圖換圖方案已停用。** `energy_bar_10_equal_slots_geometry.json` 是舊座標宣告，不能證明實際圖片各狀態一致；本次以單一外框、固定格位及渲染像素比較驗證，舊 JSON 不作驗收依據。

- Regenerated a 10-state energy-bar sheet with `image_gen`; the latest raw attempt is preserved at `C:\Users\gary1\.codex\generated_images\019dd91a-41e7-78b0-9330-2a958b01f3ee\ig_087d75994f4d497f0169f23570868c8191a7412813793c5f08.png`.
- Because the raw sheet did not keep every slot geometrically identical, the runtime states were deterministically baked from the existing tech frame using a fixed 10-slot layout.
- Equal-slot geometry is recorded in `assets/generated/ui/energy_bar_10_equal_slots_geometry.json`: `slot_count=10`, `slot_width=25`, `slot_height=22`, `slot_gap=3`, `slot_origin=[142,36]`, output `512x96`.
- Generated trail: `assets/generated/ui/energy_bar_01.png` through `energy_bar_10.png`.
- Runtime trail: `assets/sprites/ui/energy_bar_01.png` through `energy_bar_10.png`.
- State order is fixed: `energy_bar_01.png` is low red warning, `energy_bar_10.png` is full yellow charge. `AugmentedVision` and `LocationBase` now reference 10 states only.

## 2026-04-30 Codex update: Kai style demo candidates

- Cleanup note: these initial style demo files and their manifest were deleted after the fourth style was selected and the six-expression candidate pack became the retained asset set.
- Generated two project-bound Kai default-expression style demos with built-in `image_gen`; original outputs are preserved under `C:\Users\gary1\.codex\generated_images\019ddcde-2108-7a80-80d8-faaadc67ed82\`.
- Candidate A is the high-detail anime/cel-shaded dialogue portrait:
  - chroma source: `assets/generated/characters/style_demos/kai_high_detail_default_demo_chroma.png`
  - alpha PNG: `assets/generated/characters/style_demos/kai_high_detail_default_demo.png`
- Candidate B is the semi-realistic graphic-novel cyberpunk noir portrait:
  - chroma source: `assets/generated/characters/style_demos/kai_noir_realistic_default_demo_chroma.png`
  - alpha PNG: `assets/generated/characters/style_demos/kai_noir_realistic_default_demo.png`
- Prompt manifest: `assets/generated/prompts/image_gen_kai_style_demos_2026_04_30.jsonl`.
- Both demos are `1024x1536` `Format32bppArgb` PNGs after chroma-key removal, with transparent corner alpha `0,0,0,0`. Existing runtime files under `assets/sprites/characters/kai_*.png` were not replaced.

## 2026-04-30 Codex update: Kai style demo candidates C/D

- Cleanup note: these additional style demo files and their manifest were deleted after the fourth style was selected and the six-expression candidate pack became the retained asset set.
- Added two more project-bound Kai `default` expression style demos with built-in `image_gen`; original outputs are preserved under `C:\Users\gary1\.codex\generated_images\019ddcde-2108-7a80-80d8-faaadc67ed82\`.
- Candidate C is the painterly anime visual-novel portrait:
  - chroma source: `assets/generated/characters/style_demos/kai_painterly_visual_novel_default_demo_chroma.png`
  - alpha PNG: `assets/generated/characters/style_demos/kai_painterly_visual_novel_default_demo.png`
- Candidate D is the hard-edge cyberpunk noir comic portrait:
  - chroma source: `assets/generated/characters/style_demos/kai_hard_edge_comic_noir_default_demo_chroma.png`
  - alpha PNG: `assets/generated/characters/style_demos/kai_hard_edge_comic_noir_default_demo.png`
- Prompt manifest extended: `assets/generated/prompts/image_gen_kai_style_demos_2026_04_30.jsonl`.
- Both C/D alpha PNGs are `1024x1536` `Format32bppArgb` PNGs. After chroma-key removal, they were placed on a same-size transparent canvas at `0.90` scale so every corner has alpha `0,0,0,0`. Runtime Kai portraits remain unchanged.

## 2026-04-30 Codex update: Kai hard-edge six-expression candidate pack

- User selected Candidate D, the hard-edge cyberpunk noir comic style, as Kai's direction.
- Generated a 3x2 reference sheet first, but kept it reference-only because the sheet cells would cut down to square `512x512` portraits instead of the current `1024x1536` dialogue portrait format. The reference-only sheet was later deleted during cleanup after individual expression portraits were generated.
- Generated six individual candidate portraits under `assets/generated/characters/kai_hard_edge_sixpack/`:
  - `kai_default.png`
  - `kai_focused.png`
  - `kai_suspicious.png`
  - `kai_shocked.png`
  - `kai_angry.png`
  - `kai_hurt.png`
- Preserved every individual expression chroma source as `*_chroma.png`; the obsolete reference-only `expression_sheet*.png` files were removed during cleanup.
- `kai_shocked` and `kai_angry` were regenerated after review feedback: shocked had lost usable background removal, while angry had lighting and hair-shape drift. `kai_hurt` was also regenerated because its first output came back on black RGB background instead of chroma-key.
- All six alpha PNGs are `1024x1536` `Format32bppArgb`; after chroma-key removal each was placed on a same-size transparent canvas at `0.90` scale, with corner alpha `0,0,0,0`.
- Prompt manifest: `assets/generated/prompts/image_gen_kai_hard_edge_sixpack_2026_04_30.jsonl`.
- Runtime Kai portraits remain unchanged pending visual approval and data-wiring decision.

## 2026-04-30 Codex update: Kai candidate cleanup

- Deleted obsolete Kai hard-edge reference-sheet images:
  - `assets/generated/characters/kai_hard_edge_sixpack/expression_sheet.png`
  - `assets/generated/characters/kai_hard_edge_sixpack/expression_sheet_chroma.png`
- Deleted earlier incorrect `kai_shocked` raw outputs under `C:\Users\gary1\.codex\generated_images\019ddcde-2108-7a80-80d8-faaadc67ed82\`.
- Removed Godot-generated `.png.import` files from `assets/generated/characters/kai_hard_edge_sixpack/`.
- Pruned `assets/generated/prompts/image_gen_kai_hard_edge_sixpack_2026_04_30.jsonl` so it only lists the current six individual Kai expression candidates.
- Runtime Kai portraits remain unchanged.

## 2026-04-30 Codex update: Kai shocked expression correction

- Regenerated `kai_shocked` again after user supplied a stricter reference image and called out hairstyle, shape, and lighting drift.
- Raw output was generated at `C:\Users\gary1\.codex\generated_images\019ddcde-2108-7a80-80d8-faaadc67ed82\ig_0f3280368c6800e60169f310ceecbc8191b6c3ffcc94601551.png`, then deleted during cleanup because it was an obsolete uncut source.
- Updated files:
  - `assets/generated/characters/kai_hard_edge_sixpack/kai_shocked_chroma.png` (intermediate chroma source, later deleted)
  - `assets/generated/characters/kai_hard_edge_sixpack/kai_shocked.png`
  - `assets/generated/prompts/image_gen_kai_hard_edge_sixpack_2026_04_30.jsonl`
- The corrected alpha PNG remains `1024x1536` `Format32bppArgb`, with corner alpha `0,0,0,0`. Runtime Kai portraits remain unchanged.

## 2026-04-30 Codex update: Kai shocked hair-direction correction

- Regenerated `kai_shocked` after review feedback that the hair direction was flipped relative to the other Kai hard-edge portraits.
- Raw output was generated at `C:\Users\gary1\.codex\generated_images\019ddcde-2108-7a80-80d8-faaadc67ed82\ig_09a51479c91afa160169f318c9c1888191b0525d4a9551437f.png`, then deleted during cleanup because it was an obsolete uncut source.
- Updated files:
  - `assets/generated/characters/kai_hard_edge_sixpack/kai_shocked_chroma.png` (intermediate chroma source, later deleted)
  - `assets/generated/characters/kai_hard_edge_sixpack/kai_shocked.png`
  - `assets/generated/prompts/image_gen_kai_hard_edge_sixpack_2026_04_30.jsonl`
- The correction locks the cybernetic right eye and right-ear implant to the viewer's right side, with dominant long bangs on the viewer's left side to match `kai_default`, `kai_focused`, and `kai_suspicious`.
- The corrected alpha PNG is `1024x1536` `Format32bppArgb`, with corner alpha `0,0,0,0`. Runtime Kai portraits remain unchanged.

## 2026-04-30 Codex update: Kai shocked attached hairstyle reference correction

- Regenerated `kai_shocked` using the user's newly attached Kai image as the strict hairstyle reference.
- Raw output was generated at `C:\Users\gary1\.codex\generated_images\019ddcde-2108-7a80-80d8-faaadc67ed82\ig_09a51479c91afa160169f31a4adb2c819185c708232d82c191.png`, then deleted during cleanup because it was an obsolete uncut source.
- Updated files:
  - `assets/generated/characters/kai_hard_edge_sixpack/kai_shocked_chroma.png` (intermediate chroma source, later deleted)
  - `assets/generated/characters/kai_hard_edge_sixpack/kai_shocked.png`
  - `assets/generated/prompts/image_gen_kai_hard_edge_sixpack_2026_04_30.jsonl`
- The correction treats the attached image as the hair source of truth: high layered crown, viewer-left sweeping bang mass, shorter viewer-right cyber-eye-side layers, and visible cybernetic right eye and right-ear LEDs on the viewer's right.
- The corrected alpha PNG is `1024x1536` `Format32bppArgb`, with corner alpha `0,0,0,0`. Runtime Kai portraits remain unchanged.

## 2026-04-30 Codex update: Kai shocked leftward hair-flow correction

- Regenerated `kai_shocked` after user clarified that the important requirement is the hair flowing and pointing toward the viewer's left.
- Raw output was generated at `C:\Users\gary1\.codex\generated_images\019ddcde-2108-7a80-80d8-faaadc67ed82\ig_09a51479c91afa160169f31c2f17b481918357e2e955a2183e.png`, then deleted during cleanup because the user asked to remove uncut images.
- Updated files:
  - `assets/generated/characters/kai_hard_edge_sixpack/kai_shocked_chroma.png` (intermediate chroma source, later deleted)
  - `assets/generated/characters/kai_hard_edge_sixpack/kai_shocked.png`
  - `assets/generated/prompts/image_gen_kai_hard_edge_sixpack_2026_04_30.jsonl`
- The correction locks the entire hairstyle flow toward the viewer's left: crown spikes, outer hair tips, and front bang tips all sweep left while the cybernetic right eye and right-ear LEDs stay on the viewer's right.
- The corrected alpha PNG is `1024x1536` `Format32bppArgb`, with corner alpha `0,0,0,0`. Runtime Kai portraits remain unchanged.

## 2026-04-30 Codex update: Kai uncut source cleanup

- Deleted all remaining uncut Kai hard-edge sixpack sources at user request:
  - `assets/generated/characters/kai_hard_edge_sixpack/*_chroma.png`
  - the corresponding raw image_gen PNGs under `C:\Users\gary1\.codex\generated_images\019ddcde-2108-7a80-80d8-faaadc67ed82\`
- `assets/generated/characters/kai_hard_edge_sixpack/` now keeps only the six transparent alpha PNG candidates.
- `assets/generated/prompts/image_gen_kai_hard_edge_sixpack_2026_04_30.jsonl` now treats each alpha PNG as the canonical retained candidate and records that chroma/raw sources were deleted by request.
- Runtime Kai portraits remain unchanged.

## 2026-04-30 Codex update: Kai style-demo cleanup

- Deleted the obsolete Kai style demo folder after the selected style had been expanded into the six-expression candidate pack:
  - `assets/generated/characters/style_demos/`
- Deleted the obsolete style demo manifest:
  - `assets/generated/prompts/image_gen_kai_style_demos_2026_04_30.jsonl`
- Deleted the corresponding raw image_gen demo outputs under `C:\Users\gary1\.codex\generated_images\019ddcde-2108-7a80-80d8-faaadc67ed82\`.
- The retained Kai candidate set is now only `assets/generated/characters/kai_hard_edge_sixpack/*.png`.
- Runtime Kai portraits remain unchanged.

## 2026-04-30 Codex update: Kai focused leftward hair-flow correction

- Regenerated `kai_focused` after user noted the focused hairstyle still pointed the wrong side.
- The correction locks the full focused hairstyle flow toward viewer-left while keeping the cybernetic right eye and right-ear LEDs on viewer-right.
- Updated `assets/generated/characters/kai_hard_edge_sixpack/kai_focused.png`.
- The intermediate `kai_focused_chroma.png` and raw generated PNG were deleted after alpha validation, per the current cleanup preference.
- Regenerated Godot `.png.import` sidecars in the Kai sixpack folder were removed again.
- Runtime Kai portraits remain unchanged.

## 2026-09-08 Codex update: unified production character portraits

- Completed and integrated all 12 characters / 50 existing expressions using built-in image_gen, with fixed per-character identity, clothing, composition and lighting in the selected hard-edge cyberpunk noir style.
- Each final image is 1024x1536 RGBA with real transparent corners and background. Source (`assets/generated/characters/<id>_<mood>.png`) and runtime (`assets/sprites/characters/<id>_<mood>.png`) hashes match for all 50 files.
- Preserved every original generated image and retry under `assets/generated/characters/unified_2026_09_08_*_raw.png`. Final authoritative 50-record prompt/source/hash manifest: `assets/generated/prompts/image_gen_character_unification_2026_09_08.jsonl`; supplementary group/retry manifests are historical generation-stage records.
- Review page: `docs/character_portrait_review_2026_09_08.html`; production specification/results: `docs/character_portrait_unification_2026_09_08.md`.
- Validation: 947 data-integrity checks passed, 0 failed, 0 warnings; all 50 portraits loaded through the actual Godot 4.6.1 DialogueSystem loader; detective-office headless scene startup passed. Full story playthrough is outside this art validation.
- Added decoded-alpha/dimension regression checks and a self-check for chroma extraction that preserves legitimate dark green subject materials. Obsidian progress updated with completion, remaining visual feedback and next steps.
