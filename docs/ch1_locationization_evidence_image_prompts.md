# Chapter 1 Locationization Evidence Icon Prompts

本批次用於第一章完整地點化後新增的 3 個旁證 icon。所有圖都必須保留 generated source 與 runtime target，並以 image_gen 實際生成後接入專案。

## Shared Style

- 用途：Godot evidence board item icon。
- 尺寸：512x512。
- 背景：透明 alpha PNG。內部流程先生成純色 chroma-key 背景，再本地去背。
- 風格：cyberpunk noir detective evidence prop, clean readable silhouette, realistic object detail, cyan/magenta neon rim light, dark metal and rain-worn texture.
- 禁止：文字不可亂碼、不可有 watermark、不可有 logo、不可有角色臉、不可有背景場景、不可有陰影殘留、不可裁切主體。
- 驗收：runtime PNG 512x512、有 alpha channel、四角透明、generated/runtime SHA 相同。

## old_city_queue_ticket

- Evidence ID：`old_city_queue_ticket`
- 中文名稱：舊城警署等候號碼單
- Generated source：`assets/generated/items/ch1_old_city_queue_ticket.png`
- Runtime target：`assets/sprites/items/old_city_queue_ticket.png`
- Prompt：

```text
Use case: stylized-concept
Asset type: cyberpunk noir game evidence icon
Primary request: a wet old-city police precinct queue ticket, torn at one corner, with a faded number strip and tiny bureaucratic stamp blocks, no readable text except abstract marks
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal
Subject: a single rain-soaked paper queue ticket from a city police self-service kiosk
Style/medium: detailed semi-realistic painted game icon, cyberpunk noir detective evidence prop
Composition/framing: centered object, three-quarter top-down view, generous padding, strong readable silhouette
Lighting/mood: cold white office light with subtle cyan neon edge, weary bureaucratic mood
Color palette: off-white damp paper, faded blue-gray ink, small magenta/cyan scan marks
Constraints: background must be one uniform #00ff00 color; no shadows, no reflections, no floor plane; do not use #00ff00 in the subject; no watermark; no legible real-world text
Avoid: hands, faces, full room, police logo, English words, Chinese words, messy typography
```

## clinic_anonymous_case_note

- Evidence ID：`clinic_anonymous_case_note`
- 中文名稱：匿名記憶污染病歷
- Generated source：`assets/generated/items/ch1_clinic_anonymous_case_note.png`
- Runtime target：`assets/sprites/items/clinic_anonymous_case_note.png`
- Prompt：

```text
Use case: stylized-concept
Asset type: cyberpunk noir game evidence icon
Primary request: an anonymous clinic case note on a small medical clipboard, patient name blacked out, neural waveform sticker and small cybernetic eye diagnostic tag
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal
Subject: a compact medical case note from an underground memory clinic, with redacted name bars and subtle neural scan lines
Style/medium: detailed semi-realistic painted game icon, cyberpunk noir medical evidence prop
Composition/framing: centered object, slight angle, clipboard and paper fully visible, generous padding
Lighting/mood: harsh clinic light, sterile but anxious, slight cyan glow from diagnostic tag
Color palette: pale medical paper, dark graphite redaction bars, muted teal diagnostic marks, tiny warning red accents
Constraints: background must be one uniform #00ff00 color; no shadows, no reflections, no floor plane; do not use #00ff00 in the subject; no watermark; no readable real-world text
Avoid: doctors, patients, faces, blood, hospital room, readable private data, brand logos
```

## abyss_surveillance_delay_log

- Evidence ID：`abyss_surveillance_delay_log`
- 中文名稱：深淵酒吧監控延遲紀錄
- Generated source：`assets/generated/items/ch1_abyss_surveillance_delay_log.png`
- Runtime target：`assets/sprites/items/abyss_surveillance_delay_log.png`
- Prompt：

```text
Use case: stylized-concept
Asset type: cyberpunk noir game evidence icon
Primary request: a compact surveillance delay log module from a nightclub backroom, a small black data slate showing abstract timeline bars and a three-minute gap marker
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal
Subject: a palm-sized black surveillance terminal/data slate with magenta timeline bars, cyan timestamp blocks, and one obvious blank gap
Style/medium: detailed semi-realistic painted game icon, cyberpunk noir evidence prop
Composition/framing: centered object, slight perspective tilt, full device visible, generous padding
Lighting/mood: nightclub backroom glow, purple neon reflection on dark plastic, suspicious and secretive
Color palette: matte black device, purple/magenta UI bars, cyan small indicators, subtle worn metal edges
Constraints: background must be one uniform #00ff00 color; no shadows, no reflections, no floor plane; do not use #00ff00 in the subject; no watermark; no readable real-world text
Avoid: full surveillance room, people, camera lens close-up, brand marks, legible numbers, messy UI text
```
