---
title: NEON MEMORIES 第一章缺乏背景、證據與畫面圖片生成提示詞
created: 2026-04-28
updated: 2026-04-28
tags:
  - project/NEON-MEMORIES
  - chapter/1
  - asset-prompts
  - image-generation
status: prompt-ready
---

# NEON MEMORIES 第一章缺乏背景、證據與畫面圖片生成提示詞

## 使用原則

- 本檔只整理第一章目前缺乏或仍使用通用 placeholder 的背景圖、證據 icon、劇情 CG 與 UI/畫面變體。
- 目前第一章擴章已可玩，但 `old_city_police_outpost`、`dr_chen_clinic`、`abyss_bar_backroom` 仍是 story action，不是獨立地圖；若要升級為可切換場景，需要先生成背景，再新增 scene 與 SceneManager 路徑。
- 新增圖片時保留原始生成圖於 `assets/generated/...`，再複製到 runtime target path。
- 所有場景與 CG 為不透明 PNG；證據 icon 為透明 PNG。
- 視覺風格統一：寫實心理驚悚、賽博龐克黑色偵探、雨夜霓虹、低飽和暗部、青色/洋紅 UI 光、避免卡通感與過度乾淨的科幻棚拍。

## P0 缺口總覽

| 類型 | ID / 檔名 | 目前狀態 | 用途 |
|---|---|---|---|
| 場景背景 | `old_city_police_outpost.png` | 缺圖，現在掛在東區街道 action | 舊城警署前哨、警方拒絕立案 |
| 場景背景 | `dr_chen_clinic.png` | 缺圖，現在掛在東區街道 action | Dr. 陳診所、義眼後門警告 |
| 場景背景 | `abyss_bar_backroom.png` | 缺圖，現在掛在深淵酒吧 action | 包廂紀錄、遮罩客戶 |
| 場景變體 | `east_district_street_camera_gap_variant.png` | 缺圖 | 東區監控空窗、街道系統壓迫 |
| 場景變體 | `hao_ran_workshop_three_evidence_variant.png` | 缺圖 | 第一章三證據終局推理 |
| 證據 icon | `eleven_pm_call_log.png` | 使用 `recording.png` | 十一點未接來電紀錄 |
| 證據 icon | `rejected_missing_person_report.png` | 使用 `report.png` | 被退回的失蹤通報 |
| 證據 icon | `street_camera_gap.png` | 使用 `log.png` | 東區監控空窗 |
| 證據 icon | `masked_client_receipt.png` | 使用 `receipt.png` | 遮罩客戶包廂紀錄 |
| 證據 icon | `clinic_eye_warning_log.png` | 使用 `schedule.png` | Dr. 陳義眼警告紀錄 |
| 證據 icon | `black_market_entry_hint.png` | 使用 `symbol.png` | 第二章雙線入口提示 |
| 劇情 CG | `cg_ch1_snake_trade_choice.png` | 缺圖 | 蛇女資料晶片交易選擇 |
| 劇情 CG | `cg_ch1_three_evidence_inference.png` | 缺圖 | 家庭備份、義眼握手、黑市入口交會 |

## 場景背景 Prompts

### 1. `old_city_police_outpost`

- 目標檔名：`old_city_police_outpost.png`
- 原始保存：`assets/generated/backgrounds/old_city_police_outpost.png`
- Runtime 目標：`assets/sprites/locations/old_city_police_outpost.png`
- 用途：若升級為獨立地圖，作為 `old_city_police_outpost` 背景。
- 尺寸：1280x720
- 背景：不透明
- Prompt:

```text
Create a 1280x720 opaque background for a cyberpunk noir detective game. Scene: an old city police outpost in a rainy neon district, cramped front desk behind scratched security glass, piles of rejected reports, old blue police light flickering, corporate risk-classification terminals glowing faint cyan, damp floor reflecting magenta and teal neon, oppressive bureaucracy, realistic psychological thriller mood, cinematic composition with clear foreground desk, midground clerk window, background case files and surveillance monitors. No characters in foreground, no readable real-world logos, no text-heavy signage, no cartoon style.
```

- Negative prompt:

```text
no anime, no cute style, no clean sci-fi lobby, no bright daylight, no readable real-world brands, no gore, no fantasy elements, no overexposed neon, no blurry low-detail environment
```

- 驗收標準：一眼看出是舊警署前哨；有「被制度壓住」的壓迫感；畫面右側或後景需能放 UI 不遮重要資訊。

### 2. `dr_chen_clinic`

- 目標檔名：`dr_chen_clinic.png`
- 原始保存：`assets/generated/backgrounds/dr_chen_clinic.png`
- Runtime 目標：`assets/sprites/locations/dr_chen_clinic.png`
- 用途：若升級為獨立地圖，作為 Dr. 陳診所背景。
- 尺寸：1280x720
- 背景：不透明
- Prompt:

```text
Create a 1280x720 opaque background for a cyberpunk noir psychological thriller. Scene: Dr. Chen's hidden grey-market clinic behind a neon alley, small medical room with old surgical chair, cybernetic eye maintenance tools, cracked diagnostic monitors, rain-streaked frosted glass, handwritten cash-only notes, sterile white light contaminated by teal and magenta neon, shelves of encrypted memory cartridges and medical files, uneasy but humane atmosphere. Composition should leave lower third readable for dialogue UI, with the surgical chair and eye diagnostic rig as focal points. No characters, no gore, no explicit surgery.
```

- Negative prompt:

```text
no horror gore, no hospital stock photo, no cartoon, no fantasy laboratory, no bright clean corporate lab, no readable real-world brands, no excessive clutter blocking UI
```

- 驗收標準：能同時表現合法醫療與灰色轉介；義眼維修設備必須可辨識；下方對話區不可有關鍵細節。

### 3. `abyss_bar_backroom`

- 目標檔名：`abyss_bar_backroom.png`
- 原始保存：`assets/generated/backgrounds/abyss_bar_backroom.png`
- Runtime 目標：`assets/sprites/locations/abyss_bar_backroom.png`
- 用途：若升級為獨立地圖，作為深淵酒吧包廂/後室背景。
- 尺寸：1280x720
- 背景：不透明
- Prompt:

```text
Create a 1280x720 opaque background for a cyberpunk noir detective game. Scene: the private backroom of Abyss Bar, low ceiling, black glass booth table, holographic privacy curtain, masked-client payment terminal, half-empty glasses, hidden camera lens, neon magenta edge light, teal smoke haze, soundproof padded walls, a sense of secrets being bought and erased. Realistic gritty texture, noir lighting, no visible characters, clear empty chair silhouettes, enough negative space for dialogue UI.
```

- Negative prompt:

```text
no nightclub crowd, no dancing people, no cute anime bar, no fantasy tavern, no readable brand text, no overbright colorful party scene, no explicit violence
```

- 驗收標準：看起來像交易前試探的後室，不是普通酒吧；付款終端與隱藏監控要清楚。

### 4. `east_district_street_camera_gap_variant`

- 目標檔名：`east_district_street_camera_gap_variant.png`
- 原始保存：`assets/generated/backgrounds/east_district_street_camera_gap_variant.png`
- Runtime 目標：`assets/sprites/locations/east_district_street_camera_gap_variant.png`
- 用途：`ch1_street_camera_gap` 的場景變體。
- 尺寸：1280x720
- 背景：不透明
- Prompt:

```text
Create a 1280x720 opaque scene variant for a cyberpunk rain street. Scene: East District street under heavy rain, surveillance cameras on poles all showing black screens, one broken public terminal displaying a timeline gap, wet asphalt reflecting teal and magenta neon, distant police drone searchlight blurred by rain, no people in foreground. The image should feel like the city deliberately looked away for seven minutes. Realistic noir composition, strong mood, clean lower third for dialogue.
```

- Negative prompt:

```text
no daylight, no crowded street market, no cute style, no fantasy, no readable real-world text, no giant explosions, no heavy fog that hides cameras
```

- 驗收標準：監控空窗概念必須視覺化；至少兩個攝影機或螢幕明顯失效。

### 5. `hao_ran_workshop_three_evidence_variant`

- 目標檔名：`hao_ran_workshop_three_evidence_variant.png`
- 原始保存：`assets/generated/backgrounds/hao_ran_workshop_three_evidence_variant.png`
- Runtime 目標：`assets/sprites/locations/hao_ran_workshop_three_evidence_variant.png`
- 用途：`ch1_three_evidence_inference` 的終局推理畫面變體。
- 尺寸：1280x720
- 背景：不透明
- Prompt:

```text
Create a 1280x720 opaque background variant for Hao Ran's memory workshop at the end of Chapter 1. Scene: a dark memory technician workshop with a central evidence table, three projected clue clusters floating above it: family backup memory, cybernetic eye handshake protocol, masked black-market client route. Old memory player, encrypted data chip, police report, and clinic warning log arranged like a detective board. Subtle Eagle Eye HUD distortion, teal and magenta light, realistic noir thriller, no characters, no readable text blocks, leave lower third usable for dialogue UI.
```

- Negative prompt:

```text
no cartoon icons, no clean corporate lab, no fantasy magic symbols, no readable wall of text, no human characters, no overcomplicated UI covering the whole frame
```

- 驗收標準：三證據推論一眼可讀；不能像抽象 UI，要仍是浩然工作室中的實體/投影推理場。

## 證據 Icon Prompts

### 6. `eleven_pm_call_log`

- 目標檔名：`eleven_pm_call_log.png`
- 原始保存：`assets/generated/items/ch1_eleven_pm_call_log.png`
- Runtime 目標：`assets/sprites/items/eleven_pm_call_log.png`
- 尺寸：512x512
- 背景：透明
- Prompt:

```text
Create a 512x512 transparent PNG evidence icon for a cyberpunk detective game: a small cracked home terminal call log chip, showing a minimal holographic timestamp "23:00" style marks without readable full text, one red missed-call pulse, teal circuit traces, rain droplets on the casing, realistic object render, high contrast silhouette, centered, no background.
```

- Negative prompt:

```text
no full UI screenshot, no readable paragraphs, no cartoon, no white background, no hands, no phone brand, no extra objects outside icon
```

- 驗收標準：縮到 64px 仍能看出是通話紀錄；背景透明；不可有品牌字。

### 7. `rejected_missing_person_report`

- 目標檔名：`rejected_missing_person_report.png`
- 原始保存：`assets/generated/items/ch1_rejected_missing_person_report.png`
- Runtime 目標：`assets/sprites/items/rejected_missing_person_report.png`
- 尺寸：512x512
- 背景：透明
- Prompt:

```text
Create a 512x512 transparent PNG evidence icon: a damp rejected missing-person report, folded official paper with a bold red rejection stamp shape, small cyan corporate risk barcode strip, worn corners, rain stains, noir cyberpunk realism, centered object, high readability at small size, no fully readable text.
```

- Negative prompt:

```text
no real police logos, no readable legal text, no cartoon, no white background, no blood, no hands, no generic blank paper
```

- 驗收標準：要像「被退回的官方文件」，不是普通 memo；紅色退件章與企業碼都要存在。

### 8. `street_camera_gap`

- 目標檔名：`street_camera_gap.png`
- 原始保存：`assets/generated/items/ch1_street_camera_gap.png`
- Runtime 目標：`assets/sprites/items/street_camera_gap.png`
- 尺寸：512x512
- 背景：透明
- Prompt:

```text
Create a 512x512 transparent PNG evidence icon: a cyberpunk surveillance camera log shard, small black monitor tile with a broken timeline strip and missing seven-minute segment, teal scanlines, magenta warning triangle, rain-distorted security camera silhouette, realistic UI-object hybrid, centered, readable silhouette at small size.
```

- Negative prompt:

```text
no full-screen dashboard, no readable paragraphs, no cartoon, no white background, no real CCTV logo, no cluttered tiny text
```

- 驗收標準：要看得出「監控空窗」而不是普通 log；缺口時間帶需以圖形表現。

### 9. `masked_client_receipt`

- 目標檔名：`masked_client_receipt.png`
- 原始保存：`assets/generated/items/ch1_masked_client_receipt.png`
- Runtime 目標：`assets/sprites/items/masked_client_receipt.png`
- 尺寸：512x512
- 背景：透明
- Prompt:

```text
Create a 512x512 transparent PNG evidence icon: a dark bar receipt with holographic privacy-mask overlay, black glass payment slip, small glowing hash blocks instead of readable text, faint silhouette of a full-face holographic mask watermark, magenta and teal edge lighting, realistic noir cyberpunk item, centered, no background.
```

- Negative prompt:

```text
no readable itemized receipt text, no restaurant logo, no cartoon, no white background, no human face, no pile of unrelated objects
```

- 驗收標準：必須同時像收據與匿名遮罩客戶紀錄；遮罩/面具意象要清楚。

### 10. `clinic_eye_warning_log`

- 目標檔名：`clinic_eye_warning_log.png`
- 原始保存：`assets/generated/items/ch1_clinic_eye_warning_log.png`
- Runtime 目標：`assets/sprites/items/clinic_eye_warning_log.png`
- 尺寸：512x512
- 背景：透明
- Prompt:

```text
Create a 512x512 transparent PNG evidence icon: a deleted cybernetic eye maintenance warning log, small medical data tablet with eye implant diagram, red backdoor alert glyph, teal diagnostic lines, scratched clinic label, realistic cyberpunk medical object, centered with transparent background, no readable paragraphs.
```

- Negative prompt:

```text
no gore, no detached eyeball, no white background, no cartoon medical icon, no real hospital logo, no dense readable text
```

- 驗收標準：看起來是義眼維修警告，不是普通病歷；紅色後門警告符號要明顯。

### 11. `black_market_entry_hint`

- 目標檔名：`black_market_entry_hint.png`
- 原始保存：`assets/generated/items/ch1_black_market_entry_hint.png`
- Runtime 目標：`assets/sprites/items/black_market_entry_hint.png`
- 尺寸：512x512
- 背景：透明
- Prompt:

```text
Create a 512x512 transparent PNG evidence icon: a composite clue token for entering a memory black market, three small holographic fragments orbiting a spiral echo signature: family memory capsule, cybernetic eye handshake line, masked client route hash. Teal and magenta glow, dark metallic base, realistic cyberpunk evidence icon, centered, no background.
```

- Negative prompt:

```text
no fantasy magic rune, no cartoon, no white background, no readable text, no oversized UI screen, no unrelated weapons
```

- 驗收標準：必須能表現「三證據交會後的入口提示」；螺旋回聲標記可見但不直接像 AI 角色。

## 劇情 CG / 畫面 Prompts

### 12. `cg_ch1_snake_trade_choice`

- 目標檔名：`cg_ch1_snake_trade_choice.png`
- 原始保存：`assets/generated/cg/cg_ch1_snake_trade_choice.png`
- Runtime 目標：`assets/sprites/cg/cg_ch1_snake_trade_choice.png`
- 尺寸：1280x720
- 背景：不透明
- Prompt:

```text
Create a 1280x720 cinematic story CG for a cyberpunk noir detective game. Scene: Snake the information broker in Abyss Bar backroom offering a deal over an encrypted data chip, her snake-like holographic mask glowing faint magenta, Kai's gloved hand partially visible near the chip but no full face, black glass table reflecting teal neon, private booth shadows, moral tension, realistic psychological thriller lighting. Composition should leave lower third readable for dialogue UI.
```

- Negative prompt:

```text
no anime, no seductive pinup pose, no explicit violence, no fantasy snake creature, no readable text, no bright nightclub crowd, no cartoon
```

- 驗收標準：畫面重點是「交易代價」，不是普通酒吧聊天；資料晶片必須清楚。

### 13. `cg_ch1_three_evidence_inference`

- 目標檔名：`cg_ch1_three_evidence_inference.png`
- 原始保存：`assets/generated/cg/cg_ch1_three_evidence_inference.png`
- Runtime 目標：`assets/sprites/cg/cg_ch1_three_evidence_inference.png`
- 尺寸：1280x720
- 背景：不透明
- Prompt:

```text
Create a 1280x720 cinematic story CG for the end of Chapter 1 in a cyberpunk noir detective game. Scene: Kai's evidence board or Hao Ran's workshop table with three clue lines converging: family memory clip, Eagle Eye handshake warning, black-market masked client route. Holographic red thread lines, teal Eagle Eye distortion, magenta neon, rain reflections, no characters or only Kai as dark silhouette from behind. Mood: realization that Hao Ran chose Kai deliberately. Lower third should remain readable for dialogue UI.
```

- Negative prompt:

```text
no fantasy magic, no cartoon detective board, no readable paragraphs, no clean corporate presentation, no crowded characters, no overbright interface
```

- 驗收標準：三條推理線清楚收束；要有「浩然為何選凱」的章末感。

### 14. `cg_ch1_police_report_rejection`

- 目標檔名：`cg_ch1_police_report_rejection.png`
- 原始保存：`assets/generated/cg/cg_ch1_police_report_rejection.png`
- Runtime 目標：`assets/sprites/cg/cg_ch1_police_report_rejection.png`
- 尺寸：1280x720
- 背景：不透明
- Prompt:

```text
Create a 1280x720 story CG for a cyberpunk noir detective game. Close-up of a rejected missing-person report sliding under scratched police-station glass, rainwater on the counter, red rejection stamp, hidden cyan corporate risk barcode visible under Eagle Eye glow, blurred clerk silhouette behind glass, oppressive institutional mood, realistic, low saturation, teal and magenta accents, lower third clean for dialogue.
```

- Negative prompt:

```text
no readable real-world police text, no cartoon, no gore, no clean bright office, no large character faces, no fantasy symbols
```

- 驗收標準：玩家不用讀字也能感到「警署拒絕處理」與「企業壓力」。

### 15. `cg_ch1_street_camera_gap`

- 目標檔名：`cg_ch1_street_camera_gap.png`
- 原始保存：`assets/generated/cg/cg_ch1_street_camera_gap.png`
- Runtime 目標：`assets/sprites/cg/cg_ch1_street_camera_gap.png`
- 尺寸：1280x720
- 背景：不透明
- Prompt:

```text
Create a 1280x720 story CG: rainy East District cyberpunk street, public surveillance terminal showing a broken timeline with a seven-minute missing segment, several street cameras dead at once, teal scanlines and magenta error light, wet asphalt reflections, distant silhouette of Kai as a detective, no readable text blocks, psychological thriller mood, lower third clear for UI.
```

- Negative prompt:

```text
no daylight, no cartoon, no readable paragraphs, no action explosion, no crowd blocking the cameras, no real city logos
```

- 驗收標準：要讓監控空窗成為視覺事件，不只是文字線索。

### 16. `cg_ch1_dr_chen_warning`

- 目標檔名：`cg_ch1_dr_chen_warning.png`
- 原始保存：`assets/generated/cg/cg_ch1_dr_chen_warning.png`
- Runtime 目標：`assets/sprites/cg/cg_ch1_dr_chen_warning.png`
- 尺寸：1280x720
- 背景：不透明
- Prompt:

```text
Create a 1280x720 cinematic story CG in a grey-market cyberpunk clinic. Dr. Chen's diagnostic monitor displays a cybernetic eye handshake protocol and a red backdoor warning, Kai seen as a dark partial silhouette in the chair, surgical tools and memory cartridges around, sterile white light mixed with teal neon, psychological dread, realistic noir lighting, no gore, lower third clear for dialogue.
```

- Negative prompt:

```text
no graphic surgery, no detached eyeball, no cartoon, no bright clean hospital, no readable paragraphs, no fantasy laboratory
```

- 驗收標準：重點是「義眼既是鑰匙也是後門」；Dr. 陳可不入鏡，但診所與警告必須清楚。

## 接入建議

1. 先生成 P0 證據 icon，替換 `EvidenceData` 目前使用的通用 icon：
   - `eleven_pm_call_log`
   - `rejected_missing_person_report`
   - `street_camera_gap`
   - `masked_client_receipt`
   - `clinic_eye_warning_log`
   - `black_market_entry_hint`
2. 再生成三個可升級成獨立地圖的背景：
   - `old_city_police_outpost`
   - `dr_chen_clinic`
   - `abyss_bar_backroom`
3. 最後生成章節演出 CG：
   - 蛇女交易
   - 三證據推論
   - 警署退案
   - 監控空窗
   - Dr. 陳警告
4. 若新增獨立地圖，需同步：
   - `scripts/core/scene_manager.gd`
   - `scripts/data/case_data.gd`
   - `scenes/locations/chapter1/*.tscn`
   - `tests/test_data_integrity.py`
   - Obsidian 進度檔

## 驗收命令

```powershell
python tests\test_data_integrity.py
python tests\test_story_progression.py --score --details
python tests\test_eagle_eye_presentation.py --score
```

Godot CLI 若可用，再補：

```powershell
godot --headless --path . --quit
```
