extends Resource
## EvidenceData - All evidence item definitions.
class_name EvidenceData

static func get_evidence(evidence_id: String) -> Dictionary:
	var all_evidence := get_all_evidence()
	return all_evidence.get(evidence_id, {})

static func get_all_evidence() -> Dictionary:
	return {
		# ============================================
		# CHAPTER 1: 失蹤的記憶 (10 items)
		# ============================================
		"commission_letter": {
			"name": "美玲的委託信",
			"description": "林美玲寫的委託書，詳述弟弟林浩然三天前失蹤的情況。",
			"chapter": 1,
			"icon": "commission_letter"
		},
		"work_id": {
			"name": "浩然的工作證",
			"description": "林浩然的記憶技師執照，隸屬於「永恆記憶」工作室。",
			"chapter": 1,
			"icon": "work_id"
		},
		"abyss_receipt": {
			"name": "深淵酒吧的收據",
			"description": "三天前在深淵酒吧的消費收據，有一間包廂的預約紀錄。",
			"chapter": 1,
			"icon": "receipt"
		},
		"data_chip": {
			"name": "加密的數據晶片",
			"description": "在浩然工作室中找到的加密晶片，內容無法直接讀取。",
			"chapter": 1,
			"icon": "data_chip",
			"eagle_eye_only": true
		},
		"stranger_photo": {
			"name": "陌生人的全息照片",
			"description": "酒吧監控截圖，一個戴著全息面具的人與浩然會面。",
			"chapter": 1,
			"icon": "photo"
		},
		"memory_device_log": {
			"name": "記憶提取設備使用紀錄",
			"description": "浩然工作室的設備日誌，顯示近期大量非授權的記憶提取操作。",
			"chapter": 1,
			"icon": "log",
			"eagle_eye_only": true
		},
		"comm_recording": {
			"name": "損壞的通訊錄音",
			"description": "一段部分損壞的加密通話錄音，能隱約聽到「回聲」和「交貨」等字眼。",
			"chapter": 1,
			"icon": "recording"
		},
		"dr_chen_schedule": {
			"name": "Dr. 陳的預約紀錄",
			"description": "浩然同事 Dr. 陳的診所預約表，顯示浩然最後一天有一個「特殊客戶」預約。",
			"chapter": 1,
			"icon": "schedule"
		},
		"broken_memory_player": {
			"name": "損壞的記憶播放器",
			"description": "美玲公寓中被浩然拆開的家用記憶播放器，內部韌體被改成能讀取回聲網路的記憶編碼。",
			"chapter": 1,
			"icon": "memory_capsule"
		},
		"kai_eye_glitch_log": {
			"name": "凱的鷹眼異常紀錄",
			"description": "掃描損壞播放器時自動生成的鷹眼錯誤紀錄，顯示義眼與播放器短暫交換了同源加密握手。",
			"chapter": 1,
			"icon": "log",
			"eagle_eye_only": true
		},

		# ============================================
		# CHAPTER 2: 記憶黑市 (10 items)
		# ============================================
		"echo_symbol": {
			"name": "回聲網路標記符號",
			"description": "回聲網路的識別標記——一個螺旋形的音波圖案。在多個地下場所的牆上都見過。",
			"chapter": 2,
			"icon": "symbol"
		},
		"memory_sample": {
			"name": "記憶樣本",
			"description": "一個記憶樣本膠囊，裝著某人的一段記憶。用鷹眼可以預覽片段。",
			"chapter": 2,
			"icon": "memory_capsule"
		},
		"warehouse_map": {
			"name": "廢棄倉庫位置地圖",
			"description": "標記了回聲網路在東區廢棄倉庫據點位置的地圖。",
			"chapter": 2,
			"icon": "map"
		},
		"hao_ran_diary": {
			"name": "浩然的個人日記",
			"description": "部分加密的電子日記，記錄了浩然加入回聲網路的經過和越來越深的不安。",
			"chapter": 2,
			"icon": "diary"
		},
		"trade_ledger": {
			"name": "交易帳本副本",
			"description": "記憶黑市的交易記錄副本，記載了大量記憶買賣的細節和金額。",
			"chapter": 2,
			"icon": "ledger"
		},
		"zhengtek_memo": {
			"name": "正和科技內部備忘錄",
			"description": "正和科技關於「回聲計畫」的內部備忘錄，提到了記憶技術的「特殊應用」。",
			"chapter": 2,
			"icon": "memo"
		},
		"victim_list": {
			"name": "受害者名單",
			"description": "被提取記憶的受害者名單，有些人標記為「已完全提取」。",
			"chapter": 2,
			"icon": "list"
		},
		"comm_frequency": {
			"name": "回聲網路通訊頻率",
			"description": "回聲網路內部通訊的加密頻率，可用於追蹤他們的活動。",
			"chapter": 2,
			"icon": "frequency"
		},
		"rusty_key": {
			"name": "生鏽的電子鑰匙",
			"description": "在廢棄倉庫裡找到的電子鑰匙，上面刻著一個序號。",
			"chapter": 2,
			"icon": "key",
			"eagle_eye_only": true
		},
		"fake_id_chip": {
			"name": "偽造的身份晶片",
			"description": "小鬼製作的偽造身份晶片，身份為記憶收藏家「張偉」。",
			"chapter": 2,
			"icon": "id_chip"
		},

		# ============================================
		# CHAPTER 3: 回聲深處 (10 items)
		# ============================================
		"overwrite_report": {
			"name": "覆寫技術研究報告",
			"description": "蕭博士的記憶覆寫技術完整研究報告，詳述如何覆寫一個人的記憶和人格。",
			"chapter": 3,
			"icon": "report"
		},
		"zhengtek_funding": {
			"name": "正和科技資金流向",
			"description": "正和科技向回聲網路秘密轉移資金的文件，證明了公司的直接參與。",
			"chapter": 3,
			"icon": "funding"
		},
		"dr_xiao_journal": {
			"name": "蕭博士個人日誌",
			"description": "蕭博士的個人日誌，記錄了他從理想主義神經科學家到瘋狂研究者的心路歷程。",
			"chapter": 3,
			"icon": "journal"
		},
		"hao_ran_sos": {
			"name": "浩然的求救訊息",
			"description": "隱藏在記憶樣本中的求救訊息：「他們要覆寫我的記憶，救救我」。",
			"chapter": 3,
			"icon": "sos"
		},
		"lab_keycard": {
			"name": "實驗室門禁卡",
			"description": "正和科技秘密實驗室的門禁卡，最高安全級別。",
			"chapter": 3,
			"icon": "keycard"
		},
		"overwritten_profiles": {
			"name": "被覆寫者前後對比",
			"description": "數份被覆寫記憶的受害者資料，包含覆寫前後的人格對比。令人不寒而慄。",
			"chapter": 3,
			"icon": "profiles"
		},
		"echo_ai_log": {
			"name": "AI迴響對話紀錄",
			"description": "實驗室中覺醒的人工智慧「迴響」與研究人員的對話紀錄。它聲稱擁有數千人的記憶碎片。",
			"chapter": 3,
			"icon": "ai_log"
		},
		"kai_memory_fragment": {
			"name": "凱的記憶碎片",
			"description": "屬於凱·川崎的被篡改記憶碎片。你的過去可能不是你以為的那樣。",
			"chapter": 3,
			"icon": "memory_fragment",
			"eagle_eye_only": true
		},
		"authorization_order": {
			"name": "正和科技授權令",
			"description": "正和科技高層簽署的「回聲計畫」正式授權令，蓋有最高執行長印章。",
			"chapter": 3,
			"icon": "authorization"
		},
		"dr_xiao_comms": {
			"name": "蕭博士與高層通訊",
			"description": "蕭博士與正和科技高層的加密通訊紀錄，討論記憶覆寫技術的「目標名單」。",
			"chapter": 3,
			"icon": "comms"
		},
	}
