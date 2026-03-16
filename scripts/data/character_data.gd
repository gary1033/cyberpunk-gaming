extends Resource
## CharacterData - Character profiles and portrait configurations.
class_name CharacterData

static func get_character(character_id: String) -> Dictionary:
	var characters := get_all_characters()
	return characters.get(character_id, {})

static func get_all_characters() -> Dictionary:
	return {
		"kai": {
			"name": "凱·川崎",
			"name_en": "Kai Kawasaki",
			"role": "主角 / 偵探",
			"description": "前正和科技安全調查員，現為落魄私家偵探。左眼是「鷹眼」義體掃描器。",
			"moods": ["default", "serious", "surprised", "thoughtful"]
		},
		"mei_ling": {
			"name": "林美玲",
			"name_en": "Mei Ling Lin",
			"role": "委託人",
			"description": "浩然的姐姐。外表堅強但內心焦慮。隱瞞了部分關於弟弟的真相。",
			"moods": ["default", "worried", "nervous", "relieved", "frightened"]
		},
		"ajie": {
			"name": "阿傑",
			"name_en": "Ajie",
			"role": "深淵酒吧酒保",
			"description": "壯碩的男人，手臂滿是發光的電路紋身。看似粗獷但觀察力敏銳。",
			"moods": ["default", "suspicious", "nervous", "angry", "cooperative"]
		},
		"snake": {
			"name": "蛇女",
			"name_en": "Snake",
			"role": "情報販子",
			"description": "戴蛇形面具的神秘女子。什麼都知道，但一切都有價格。",
			"moods": ["default", "amused", "serious", "threatening"]
		},
		"dr_chen": {
			"name": "Dr. 陳",
			"name_en": "Dr. Chen",
			"role": "記憶技師",
			"description": "浩然的同事和朋友。知道一些內情但害怕牽連。",
			"moods": ["default", "nervous", "frightened", "relieved"]
		},
		"ghost": {
			"name": "幽靈",
			"name_en": "Ghost",
			"role": "回聲網路中間人",
			"description": "回聲網路的聯絡人。全身包裹在反光斗篷中，聲音經過變聲處理。",
			"moods": ["default", "hostile", "cautious", "revealed"]
		},
		"zhao_ming": {
			"name": "趙明",
			"name_en": "Zhao Ming",
			"role": "正和科技安全主管",
			"description": "凱的前同事和朋友。選擇留在公司內部試圖改變。動機複雜。",
			"moods": ["default", "conflicted", "nervous", "determined", "sincere", "sad"]
		},
		"kid": {
			"name": "小鬼",
			"name_en": "Kid",
			"role": "街頭駭客",
			"description": "12歲的天才駭客。在比特風暴網咖出沒。態度輕浮但技術一流。",
			"moods": ["default", "excited", "serious", "angry"]
		},
		"mask_merchant": {
			"name": "面具商人",
			"name_en": "Mask Merchant",
			"role": "記憶黑市攤主",
			"description": "記憶黑市中最大的攤主。戴著不斷變換的全息面具。",
			"moods": ["default", "interested", "suspicious"]
		},
		"dr_xiao": {
			"name": "蕭博士",
			"name_en": "Dr. Xiao",
			"role": "回聲網路首腦",
			"description": "前神經科學家，記憶覆寫技術的發明者。相信自己在「推動人類進化」。",
			"moods": ["default", "calm", "intense", "philosophical", "amused", "cracking"]
		},
		"hao_ran": {
			"name": "林浩然",
			"name_en": "Hao Ran Lin",
			"role": "失蹤的記憶技師",
			"description": "美玲的弟弟。天才記憶技師，但被回聲網路的誘惑拉入深淵。",
			"moods": ["default", "dazed", "confused", "hopeful"]
		},
		"echo_ai": {
			"name": "AI「迴響」",
			"name_en": "Echo AI",
			"role": "人工智慧",
			"description": "由數千份被提取記憶中誕生的意識。既不完全是人，也不完全是機器。",
			"moods": ["default"]
		}
	}
