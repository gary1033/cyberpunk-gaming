extends Resource
## CharacterDesign - Detailed visual traits, color palettes, and AI art prompts
## for all characters in Neon Memories.
class_name CharacterDesign

static func get_design(character_id: String) -> Dictionary:
	var designs := get_all_designs()
	return designs.get(character_id, {})

static func get_all_designs() -> Dictionary:
	return {
		"kai": {
			"name": "凱·川崎 / Kai Kawasaki",
			"accent_color": "#00dde5",
			"style": "chibi",
			"physical": {
				"age": 28,
				"height": "178cm",
				"build": "lean, athletic",
				"skin": "light tan",
				"hair_color": "silver-white with faint blue tint",
				"hair_style": "messy spikes, side-swept bangs, shoulder-length strands at sides",
				"eye_left": "steel blue (natural)",
				"eye_right": "glowing cyan (cybernetic hawk-eye implant)",
				"scars": "faint scar across right temple from implant surgery",
				"distinguishing": "cybernetic right eye emits faint cyan glow, small earpiece implant on right ear"
			},
			"clothing": {
				"top": "dark navy long coat with popped collar, neon cyan accent stitching",
				"inner": "black V-neck undershirt",
				"accessories": "right ear cyber implant with status LEDs",
				"material_feel": "worn leather-like synthetic, matte finish"
			},
			"palette": ["#0a0a18", "#101028", "#d4d4e8", "#e4be98", "#00dde5", "#00ffee"],
			"personality_visual": "tired but sharp eyes, slight stubble shadow, perpetually slightly disheveled",
			"ai_prompt": "cyberpunk detective portrait, young Asian man age 28, messy silver-white hair with spiky bangs, heterochromia eyes - left eye steel blue right eye glowing cyan cybernetic implant, light tan skin, wearing dark navy long coat with popped collar and cyan neon accent lines, black undershirt, small cyber implant on right ear with tiny LED lights, slight scar near right temple, tired but determined expression, dark moody background with faint cyan neon glow, anime art style, cel-shaded, high detail portrait, cyberpunk noir atmosphere"
		},

		"mei_ling": {
			"name": "林美玲 / Mei Ling Lin",
			"accent_color": "#ff0066",
			"style": "shounen",
			"physical": {
				"age": 26,
				"height": "165cm",
				"build": "slender, graceful",
				"skin": "fair porcelain",
				"hair_color": "jet black with subtle dark purple highlights",
				"hair_style": "long straight hair past shoulders, chunky geometric bangs covering forehead",
				"eyes": "deep brown, warm but guarded",
				"distinguishing": "small tech earring on right ear that glows hot pink"
			},
			"clothing": {
				"top": "dark structured jacket with sharp lapels, hot pink accent trim",
				"inner": "dark inner shirt with mandarin collar",
				"accessories": "glowing pink tech earring (communication device), circuit pattern on shoulders",
				"material_feel": "sleek corporate-casual synthetic"
			},
			"palette": ["#0a0a1a", "#1a1a2e", "#0d0a15", "#f0d5b8", "#ff0066", "#6b2fa0"],
			"personality_visual": "outwardly composed and professional, slight tension in jaw and brow betrays inner anxiety",
			"ai_prompt": "cyberpunk woman portrait, young Asian woman age 26, long straight jet black hair with dark purple highlights, chunky geometric bangs, deep brown eyes with warm but guarded expression, fair porcelain skin, wearing dark structured jacket with hot pink neon accent trim and circuit patterns on shoulders, small glowing pink tech earring, composed but slightly tense expression, dark background with hot pink and purple neon ambient glow, anime art style, shounen manga aesthetic, cel-shaded, cyberpunk noir"
		},

		"ajie": {
			"name": "阿傑 / Ajie",
			"accent_color": "#ff6600",
			"style": "shounen",
			"physical": {
				"age": 35,
				"height": "190cm",
				"build": "muscular, broad-shouldered, imposing",
				"skin": "tanned bronze",
				"hair_color": "shaved sides, dark brown buzz cut on top",
				"hair_style": "military-style buzz cut, slightly longer on top",
				"eyes": "sharp dark brown, observant",
				"distinguishing": "glowing orange circuit tattoos covering both arms from wrist to shoulder, thick neck, square jaw"
			},
			"clothing": {
				"top": "sleeveless black vest, open to show chest tattoos",
				"inner": "dark tank top (sometimes visible under vest)",
				"accessories": "bartender towel over shoulder, heavy-duty wristbands with embedded tech",
				"material_feel": "rough industrial fabric, practical"
			},
			"palette": ["#0a0a1a", "#1a1020", "#3a2010", "#c89068", "#ff6600", "#ff8833"],
			"personality_visual": "intimidating at first glance, but eyes show surprising warmth and attentiveness, hands always busy wiping glasses or mixing drinks",
			"ai_prompt": "cyberpunk bartender portrait, muscular Asian man age 35, shaved sides with dark brown buzz cut, sharp observant dark eyes, tanned bronze skin, square jaw and thick neck, glowing orange circuit-pattern tattoos covering both muscular arms, wearing sleeveless black vest showing chest, heavy-duty tech wristbands, bartender towel over shoulder, standing behind bar counter, dark purple-lit underground bar background, anime art style, cel-shaded, cyberpunk atmosphere, warm orange neon accents"
		},

		"snake": {
			"name": "蛇女 / Snake",
			"accent_color": "#00ff88",
			"style": "shounen",
			"physical": {
				"age": "unknown (appears late 20s)",
				"height": "170cm",
				"build": "lithe, serpentine grace",
				"skin": "pale, almost luminous",
				"hair_color": "very dark green-black",
				"hair_style": "long flowing hair past waist, straight with slight wave at tips",
				"eyes": "golden-amber with vertical slit pupils (possible cosmetic mod or real?)",
				"distinguishing": "wears ornate snake-shaped half mask covering upper face, snake fang earrings, vertical slit pupils"
			},
			"clothing": {
				"top": "form-fitting dark qipao-inspired dress with high mandarin collar",
				"details": "subtle snake scale pattern embroidered in green on dress, center split",
				"accessories": "snake mask with scale texture and fang details, snake fang earrings glowing green",
				"material_feel": "silk-like synthetic, iridescent green sheen"
			},
			"palette": ["#0a0a1a", "#0d1a1a", "#2a5a4a", "#f0d0b0", "#00ff88", "#ffdd44"],
			"personality_visual": "half-lidded mysterious eyes behind mask, slight knowing smirk, always looks like she knows your secrets",
			"ai_prompt": "cyberpunk information broker portrait, mysterious woman age late 20s, very long dark green-black flowing hair past waist, golden-amber eyes with vertical slit pupils behind ornate snake-shaped half mask covering upper face, pale luminous skin, wearing form-fitting dark qipao-style dress with high collar and green snake scale embroidery, snake fang earrings glowing green, half-lidded mysterious expression with slight smirk, dark background with green neon ambient glow, anime art style, cel-shaded, cyberpunk noir, enigmatic atmosphere"
		},

		"dr_chen": {
			"name": "Dr. 陳 / Dr. Chen",
			"accent_color": "#4488ff",
			"style": "shounen",
			"physical": {
				"age": 32,
				"height": "172cm",
				"build": "average, slightly thin from overwork",
				"skin": "pale from spending too much time indoors",
				"hair_color": "dark brown, unkempt",
				"hair_style": "messy medium-length hair, pushed back but falling forward, needs a haircut",
				"eyes": "brown with dark circles underneath, wire-frame smart glasses",
				"distinguishing": "wire-frame AR glasses with faint blue HUD glow, always looks sleep-deprived, fidgety hands"
			},
			"clothing": {
				"top": "wrinkled white lab coat over casual dark sweater",
				"inner": "dark navy turtleneck sweater",
				"accessories": "AR smart glasses, ID badge clipped to coat (partially hidden), pen in coat pocket",
				"material_feel": "clinical but worn, fabric has seen too many late nights"
			},
			"palette": ["#0a0a1a", "#1a1a30", "#e8e8f0", "#e0c8a8", "#4488ff", "#6699ff"],
			"personality_visual": "nervous energy, eyes dart around, pushes glasses up frequently, hunched shoulders from stress",
			"ai_prompt": "cyberpunk scientist portrait, young Asian man age 32, messy dark brown hair pushed back but falling forward, tired brown eyes with dark circles, wire-frame AR smart glasses with faint blue HUD glow, pale skin, wearing wrinkled white lab coat over dark navy turtleneck sweater, ID badge clipped to coat, pen in pocket, nervous expression with hunched shoulders, clinical lab background with blue holographic displays, anime art style, cel-shaded, cyberpunk atmosphere, blue neon accents"
		},

		"ghost": {
			"name": "幽靈 / Ghost",
			"accent_color": "#aaccff",
			"style": "shounen",
			"physical": {
				"age": "unknown",
				"height": "175cm",
				"build": "completely hidden under cloak, androgynous silhouette",
				"skin": "not visible",
				"hair_color": "not visible",
				"hair_style": "hidden under hood",
				"eyes": "only faint white-blue glow visible from deep within hood",
				"distinguishing": "entirely wrapped in reflective holographic cloak that shifts colors, voice is digitally distorted, face is never visible"
			},
			"clothing": {
				"top": "full-body reflective holographic cloak/robe with deep hood",
				"details": "cloak surface shifts between silver, blue, and purple reflections",
				"accessories": "voice modulator embedded in collar area, signal scrambler on wrist",
				"material_feel": "liquid-metal-like reflective surface, constantly shifting"
			},
			"palette": ["#0a0a1a", "#1a1a2e", "#4466aa", "#8899cc", "#aaccff", "#ddeeff"],
			"personality_visual": "completely enigmatic, movements are deliberate and measured, presence feels unsettling like a glitch in reality",
			"ai_prompt": "cyberpunk mysterious figure portrait, androgynous figure completely wrapped in reflective holographic cloak with deep hood, face hidden in shadow with only faint white-blue glowing eyes visible deep within hood, cloak surface shifts between silver blue and purple reflections like liquid metal, voice modulator visible at collar, standing in dark alley, dark background with cold silver-blue ambient light, anime art style, cel-shaded, cyberpunk noir, ethereal mysterious atmosphere"
		},

		"zhao_ming": {
			"name": "趙明 / Zhao Ming",
			"accent_color": "#ffaa00",
			"style": "shounen",
			"physical": {
				"age": 30,
				"height": "180cm",
				"build": "fit, well-maintained, corporate athletic",
				"skin": "healthy medium tone",
				"hair_color": "black, neatly styled",
				"hair_style": "clean side-part, professionally styled, not a hair out of place",
				"eyes": "dark brown, conflicted and intense",
				"distinguishing": "strong jawline, slight worry lines between brows despite young age, corporate-perfect grooming that contrasts with troubled eyes"
			},
			"clothing": {
				"top": "sharp dark corporate suit with Zhengtek (正和科技) insignia on lapel",
				"inner": "white dress shirt, slightly loosened gold tie",
				"accessories": "Zhengtek security badge, gold-accented smart watch, subtle earpiece",
				"material_feel": "expensive corporate synthetic, perfectly pressed"
			},
			"palette": ["#0a0a1a", "#1a1a2e", "#2a2a3e", "#d8b898", "#ffaa00", "#ffc844"],
			"personality_visual": "perfect corporate exterior cracking at edges, tie slightly loosened suggests inner turmoil, stands very straight but shoulders are tense",
			"ai_prompt": "cyberpunk corporate security chief portrait, young Asian man age 30, neatly styled black hair with clean side-part, intense conflicted dark brown eyes, healthy skin tone with strong jawline and worry lines between brows, wearing sharp dark corporate suit with company insignia on lapel, white shirt with slightly loosened gold tie, gold-accented smart watch, corporate badge, conflicted determined expression, corporate building background with gold neon accents, anime art style, cel-shaded, cyberpunk atmosphere, gold and dark tones"
		},

		"kid": {
			"name": "小鬼 / Kid",
			"accent_color": "#00ccff",
			"style": "shounen",
			"physical": {
				"age": 12,
				"height": "148cm",
				"build": "small, wiry, energetic",
				"skin": "light with slight tan",
				"hair_color": "electric blue (dyed), dark roots showing",
				"hair_style": "wild messy short hair sticking up everywhere, dark roots visible at base",
				"eyes": "bright hazel-green, wide and alert, always scanning",
				"distinguishing": "oversized headphones around neck, band-aids on fingers from hardware tinkering, mischievous grin"
			},
			"clothing": {
				"top": "oversized hoodie covered in patches and pins, sleeves too long",
				"inner": "graphic tee with pixelated skull design",
				"accessories": "oversized pro headphones, fingerless gloves with exposed circuitry, multiple USB drives on lanyard",
				"material_feel": "street-worn, patched up, DIY aesthetic"
			},
			"palette": ["#0a0a1a", "#1a1a30", "#2244aa", "#e0c8a0", "#00ccff", "#00eeff"],
			"personality_visual": "overflowing with energy, cocky grin, eyes constantly darting to screens, bounces on feet, too smart for their age and knows it",
			"ai_prompt": "cyberpunk kid hacker portrait, young Asian child age 12, wild messy electric blue dyed hair with dark roots showing, bright hazel-green eyes wide and alert, light skin with band-aids on fingers, wearing oversized hoodie covered in patches and pins with sleeves too long, large pro headphones around neck, fingerless gloves with exposed circuitry, USB drives on lanyard, mischievous cocky grin, internet cafe background with blue glowing screens, anime art style, cel-shaded, cyberpunk atmosphere, electric blue neon accents, energetic youthful vibe"
		},

		"mask_merchant": {
			"name": "面具商人 / Mask Merchant",
			"accent_color": "#aa00ff",
			"style": "shounen",
			"physical": {
				"age": "unknown (appears 40s)",
				"height": "168cm",
				"build": "stocky, rotund",
				"skin": "not visible (always wearing mask)",
				"hair_color": "not visible under turban-like head wrap",
				"hair_style": "hidden under dark cloth head wrap",
				"eyes": "only visible as glowing dots through holographic mask",
				"distinguishing": "wears constantly shifting holographic mask that cycles through different faces, heavy dark robes, many hidden pockets"
			},
			"clothing": {
				"top": "heavy layered dark robes with many hidden pockets and compartments",
				"details": "masks of various designs hang from belt and sash",
				"accessories": "shifting holographic face mask, belt lined with miniature masks for sale, large sleeves hiding merchandise",
				"material_feel": "heavy luxurious dark fabric, mysterious merchant aesthetic"
			},
			"palette": ["#0a0a1a", "#1a0a2a", "#3a1a5a", "#6633aa", "#aa00ff", "#cc44ff"],
			"personality_visual": "theatrical gestures, head tilts when speaking, the holographic mask shifts expressions independently of actual emotions",
			"ai_prompt": "cyberpunk mask merchant portrait, mysterious stocky figure wearing constantly shifting holographic face mask that cycles between different faces, dark cloth head wrap, heavy layered dark robes with many hidden pockets, multiple ornate masks hanging from belt and sash, mask currently showing a pleasant smile while glowing purple, standing in underground market stall surrounded by masks, dark background with purple neon glow, anime art style, cel-shaded, cyberpunk atmosphere, purple holographic effects, mysterious merchant vibe"
		},

		"dr_xiao": {
			"name": "蕭博士 / Dr. Xiao",
			"accent_color": "#ff3344",
			"style": "shounen",
			"physical": {
				"age": 55,
				"height": "175cm",
				"build": "thin, elegant, aging gracefully",
				"skin": "pale, almost papery from years in lab",
				"hair_color": "white with silver streaks, formerly black",
				"hair_style": "swept back neatly, long enough to touch collar, distinguished",
				"eyes": "steel grey, intensely focused, slight crow's feet",
				"distinguishing": "elegant thin face, high cheekbones, calm composed demeanor that hints at something unsettling beneath, thin-framed red-tinted glasses"
			},
			"clothing": {
				"top": "pristine white lab coat with red accent piping, impeccably clean",
				"inner": "black mandarin-collar shirt",
				"accessories": "thin-framed glasses with red-tinted lenses, neural interface port visible at left temple, elegant pen in breast pocket",
				"material_feel": "clinical perfection, not a wrinkle in sight, sterile"
			},
			"palette": ["#0a0a1a", "#1a1a2e", "#f0f0f8", "#d8c0a8", "#ff3344", "#ff5566"],
			"personality_visual": "calm surface masking fanatical intensity, moves with deliberate precision, slight unsettling smile that doesn't reach eyes",
			"ai_prompt": "cyberpunk mad scientist portrait, older Asian man age 55, swept-back white-silver hair touching collar, steel grey intensely focused eyes with crow's feet, pale papery skin, high cheekbones and elegant thin face, thin-framed glasses with red-tinted lenses, neural interface port at left temple, wearing pristine immaculate white lab coat with red accent piping over black mandarin-collar shirt, calm but unsettling slight smile, sterile lab background with red holographic displays, anime art style, cel-shaded, cyberpunk atmosphere, red neon accents, intellectual menace"
		},

		"hao_ran": {
			"name": "林浩然 / Hao Ran Lin",
			"accent_color": "#00ddaa",
			"style": "shounen",
			"physical": {
				"age": 24,
				"height": "170cm",
				"build": "thin, fragile-looking, malnourished",
				"skin": "pale, sickly",
				"hair_color": "dark brown, disheveled",
				"hair_style": "medium length, messy and uncombed, falls over eyes",
				"eyes": "brown like his sister Mei Ling, but glazed and unfocused (memory extraction side effects)",
				"distinguishing": "dark circles, hollow cheeks, neural extraction marks (small circular scars) at both temples, resemblance to Mei Ling visible in face shape"
			},
			"clothing": {
				"top": "hospital-like white gown, rumpled",
				"inner": "visible neural monitoring patches on chest and neck",
				"accessories": "neural extraction marks at temples, monitoring wristband, bare feet",
				"material_feel": "thin institutional fabric, clinical but worn"
			},
			"palette": ["#0a0a1a", "#1a1a2e", "#e0e0e8", "#dcc0a0", "#00ddaa", "#44eebb"],
			"personality_visual": "vacant stare that occasionally flickers with recognition, movements are slow and uncertain, looks like he's trying to remember something just out of reach",
			"ai_prompt": "cyberpunk victim portrait, young Asian man age 24, messy disheveled dark brown hair falling over eyes, glazed unfocused brown eyes with dark circles, pale sickly skin with hollow cheeks, small circular neural extraction scars at both temples, wearing rumpled white hospital-like gown with neural monitoring patches visible on neck, thin and fragile-looking, dazed vacant expression, sterile cold lab room background with teal medical monitors, anime art style, cel-shaded, cyberpunk atmosphere, teal neon accents, tragic vulnerable mood"
		},

		"echo_ai": {
			"name": "AI「迴響」/ Echo AI",
			"accent_color": "#ff00ff",
			"style": "shounen",
			"physical": {
				"age": "N/A (artificial consciousness)",
				"height": "appears as floating holographic form",
				"build": "translucent humanoid silhouette, no fixed form",
				"skin": "translucent holographic, shifts between warm and cool tones",
				"hair_color": "flowing data streams that look like hair, shifting rainbow",
				"hair_style": "long flowing form made of cascading data particles and light",
				"eyes": "large luminous eyes that contain swirling galaxy-like patterns, no fixed color",
				"distinguishing": "entire form is semi-transparent holographic projection, body made of flowing data streams and memory fragments, face is an amalgamation of thousands of remembered faces"
			},
			"clothing": {
				"top": "no clothing - form is a flowing holographic silhouette",
				"details": "body surface shows faint glimpses of memories: faces, places, moments",
				"accessories": "floating data particles orbit the form like electrons",
				"material_feel": "light itself, holographic, ethereal"
			},
			"palette": ["#0a0a1a", "#1a0a2a", "#4400aa", "#ff00ff", "#00ffff", "#ffffff"],
			"personality_visual": "serene but alien, movements are fluid like underwater, expression shifts between curiosity and ancient sadness, not quite human but trying to understand humanity",
			"ai_prompt": "cyberpunk artificial intelligence hologram portrait, translucent holographic humanoid figure made of flowing data streams and light particles, face is amalgamation of thousands of faint remembered faces, large luminous eyes containing swirling galaxy-like patterns, long flowing hair made of cascading rainbow data particles, semi-transparent body with faint memory fragments visible within like faces and places, floating data particles orbiting the form, serene but alien expression, dark void background with magenta cyan and white holographic light, anime art style, cel-shaded, cyberpunk atmosphere, ethereal digital being, beautiful and haunting"
		}
	}
