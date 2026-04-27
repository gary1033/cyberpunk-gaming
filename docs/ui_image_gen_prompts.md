# UI Image_Gen Prompts

Date: 2026-04-27

These prompts are for image_gen / image2-style generation. The listed PNGs have been copied into the runtime target paths and are wired in game UI.

## AP Status Bar

Status: generated and connected to the in-location AP widget.

Runtime target:

```text
assets/sprites/ui/ap_status_bar.png
```

Generated copy:

```text
assets/generated/ui/ap_status_bar.png
```

Prompt:

```text
Create a transparent PNG game UI asset for NEON MEMORIES: a compact high-tech cyberpunk action point status bar, horizontal capsule frame, dark translucent smoked glass, thin cyan circuit traces, amber energy fill accents, subtle magenta warning notches, crisp 2D HUD style, no readable text, no numbers, no logo, no background, designed to sit in the top-right corner without covering gameplay. Export as a clean isolated UI sprite with alpha transparency, 512x96.
```

Negative prompt:

```text
no words, no AP letters, no numbers, no watermark, no brand logo, no large opaque rectangle, no fantasy ornament, no photorealistic object, no bright white background
```

## Main Menu Start Background

Status: generated and connected to the main menu background, with ColorRect fallback.

Runtime target:

```text
assets/sprites/ui/main_menu_background.png
```

Generated copy:

```text
assets/generated/ui/main_menu_background.png
```

Prompt:

```text
Create a 1280x720 title screen background for NEON MEMORIES, cyberpunk noir detective adventure, rain-soaked Hong Kong inspired Kowloon extension district at night, detective office window overlooking dense neon apartments, cyan and magenta reflections on wet glass, dark cinematic mood, strong first-screen identity space for the title at upper left, enough negative space for four menu buttons below, no text, no logos, no characters in foreground, detailed but readable 2D game key art, widescreen composition.
```

Negative prompt:

```text
no readable text, no watermark, no real brand logos, no UI buttons, no character portrait, no blank gradient background, no washed-out white haze, no fantasy medieval elements
```
