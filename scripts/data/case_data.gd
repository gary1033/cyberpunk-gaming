extends Resource
## CaseData - Chapter structure, scene locations, and case flow data.
class_name CaseData

static func get_chapter_data(chapter: int) -> Dictionary:
	var chapters := {
		1: {
			"title": "失蹤的記憶",
			"description": "一個神秘女子委託你尋找失蹤的弟弟——記憶技師林浩然。",
			"action_points": 20,
			"starting_location": "detective_office",
			"locations": {
				"detective_office": {
					"name": "偵探辦公室",
					"description": "你的辦公室，位於九龍延伸區的一棟老舊大樓裡。",
					"connections": ["mei_ling_apartment", "abyss_bar", "east_district_street"],
					"initial_dialogue": "ch1_mei_ling_intro",
					"hotspots": ["desk", "evidence_board", "window", "phone"]
				},
				"mei_ling_apartment": {
					"name": "林美玲的公寓",
					"description": "美玲和浩然合住的公寓。浩然的房間裡可能有線索。",
					"connections": ["detective_office", "east_district_street"],
					"story_actions": [
						{
							"id": "inspect_hao_ran_drawer",
							"title": "調查浩然上鎖抽屜",
							"dialogue": "ch1_hao_ran_drawer_search",
							"story_cg": "cg_mei_ling_apartment_memory_trace",
							"requires_evidence": "commission_letter"
						},
						{
							"id": "inspect_original_backup_album",
							"title": "檢視家庭相簿與原始備份提示",
							"dialogue": "ch1_original_backup_album",
							"story_cg": "cg_mei_ling_apartment_memory_trace",
							"requires_evidence": "hao_ran_drawer_note"
						},
						{
							"id": "review_family_memory_clip",
							"title": "回放家庭記憶片段",
							"dialogue": "ch1_family_memory_clip",
							"story_cg": "cg_family_memory_clip",
							"requires_evidence": "commission_letter"
						},
						{
							"id": "scan_broken_memory_player",
							"title": "掃描損壞記憶播放器",
							"dialogue": "ch1_kai_eye_glitch_scan",
							"requires_evidence": "commission_letter"
						}
					],
					"hotspots": ["hao_ran_room", "computer", "bookshelf", "drawer"]
				},
				"abyss_bar": {
					"name": "深淵酒吧",
					"description": "東區地下三層的酒吧，霓虹紫色燈光和合成音樂。",
					"connections": ["detective_office", "east_district_street"],
					"initial_dialogue": "ch1_abyss_bar_enter",
					"hotspots": ["bar_counter", "booth", "snake_corner", "back_door"]
				},
				"hao_ran_workshop": {
					"name": "浩然的工作室",
					"description": "東區第七街地下的「永恆記憶」工作室。門鎖被破壞。",
					"connections": ["east_district_street"],
					"initial_dialogue": "ch1_workshop_enter",
					"story_actions": [
						{
							"id": "decode_eye_signature",
							"title": "比對鷹眼異常訊號",
							"dialogue": "ch1_eye_signature_decode",
							"requires_flag": "deduced_eye_echo_signature",
							"requires_evidence": "data_chip"
						},
						{
							"id": "reconstruct_hao_ran_motive",
							"title": "還原浩然的家庭動機",
							"dialogue": "ch1_hao_ran_family_motive",
							"requires_flag": "deduced_hao_ran_family_motive",
							"requires_evidence": "family_memory_clip"
						},
						{
							"id": "decode_hao_ran_last_message",
							"title": "解讀浩然留給美玲的加密留言",
							"dialogue": "ch1_hao_ran_encrypted_message",
							"story_cg": "cg_hao_ran_encrypted_message",
							"requires_evidence": "original_backup_hint"
						},
						{
							"id": "consult_dr_chen_eye_warning",
							"title": "聯絡 Dr. 陳解讀播放器協定",
							"dialogue": "ch1_dr_chen_eye_warning",
							"requires_flag": "deduced_player_echo_codec",
							"requires_evidence": "kai_eye_glitch_log"
						}
					],
					"hotspots": ["memory_device", "desk_workshop", "data_chip_spot", "broken_lock"],
					"requires_flag": "knows_workshop_location"
				},
				"east_district_street": {
					"name": "東區街道",
					"description": "雨中的東區街道。霓虹招牌照亮濕漉漉的路面。",
					"connections": ["detective_office", "mei_ling_apartment", "abyss_bar", "hao_ran_workshop"]
				}
			},
			"interrogations": {
				"ajie": {
					"name": "阿傑",
					"opening_line": "又是你。這次想問什麼？",
					"clam_up_threshold": 80,
					"broke_threshold": 60,
					"questions": [
						{
							"text": "那天晚上的包廂客人是誰？",
							"type": "neutral",
							"pressure_change": 10,
							"response_normal": "我跟你說了，他戴著全息面具。我看不到臉。",
							"response_pressured": "...他的面具偶爾會閃爍。我瞥到了一個企業標記——像是正和科技的。",
							"response_clammed": "我什麼都不知道。你走吧。",
							"reveals": "corporate_connection",
							"requires_pressure": 50
						},
						{
							"text": "浩然來酒吧的頻率是多少？",
							"type": "gentle",
							"pressure_change": 5,
							"response_normal": "最近兩個月，每週都來。之前從沒見過他。",
							"response_pressured": "每次來都帶著一個小箱子。我猜裡面是記憶樣本之類的。",
							"requires_pressure": 30,
							"reveals": "regular_visits"
						},
						{
							"text": "你是不是在幫他們做什麼交易？",
							"type": "aggressive",
							"pressure_change": 25,
							"response_normal": "我只是個酒保。別把我扯進去。",
							"response_pressured": "好吧...我幫他們預約包廂，收了一點錢。但我真的不知道他們在幹什麼。",
							"response_clammed": "我有權保持沉默。你不是警察。",
							"requires_pressure": 40,
							"reveals": "ajie_involved"
						},
						{
							"text": "浩然最後離開時是什麼狀態？",
							"type": "gentle",
							"pressure_change": 5,
							"response_normal": "就...正常吧。跟那個人聊了很久，然後一起離開的。",
							"response_pressured": "其實他看起來有點慌。走的時候好像在跟對方爭論什麼。",
							"requires_pressure": 35,
							"reveals": "argument_observed"
						}
					],
					"evidence_reactions": {
						"abyss_receipt": {
							"response": "是，那是我們的收據。浩然那天訂了二號包廂。",
							"pressure_change": 5
						},
						"stranger_photo": {
							"response": "...你從哪弄到這張照片的？",
							"pressure_change": 15,
							"reveals": "photo_reaction"
						},
						"comm_recording": {
							"response": "（明顯慌張）這...這不是在我的酒吧錄的。",
							"pressure_change": 20,
							"reveals": "recording_panic"
						}
					},
					"default_evidence_response": "這跟我有什麼關係？我只是個酒保。"
				}
			}
		},

		2: {
			"title": "記憶黑市",
			"description": "追蹤回聲網路的線索，潛入記憶黑市。",
			"action_points": 20,
			"starting_location": "bitstorm_cafe",
			"locations": {
				"bitstorm_cafe": {
					"name": "比特風暴網咖",
					"description": "駭客聚集的地下網咖，三排老舊電腦散發著藍光。",
					"connections": ["memory_black_market", "zhengtek_exterior", "sewer_passage"],
					"initial_dialogue": "ch2_opening",
					"story_actions": [
						{"id": "talk_to_kid", "title": "詢問小鬼", "dialogue": "ch2_kid_encounter"}
					],
					"hotspots": ["kid_corner", "bulletin_board", "terminal"]
				},
				"memory_black_market": {
					"name": "記憶黑市",
					"description": "隱藏在廢棄地鐵站的地下市場。各種非法記憶在這裡交易。",
					"connections": ["bitstorm_cafe", "sewer_passage"],
					"requires_flag": "has_fake_id",
					"initial_dialogue": "ch2_memory_market_enter",
					"story_actions": [
						{"id": "meet_ghost", "title": "尋找幽靈", "dialogue": "ch2_ghost_encounter", "requires_flag": "entered_market"}
					],
					"hotspots": ["mask_merchant", "memory_stall", "ghost_meeting", "exit_tunnel"]
				},
				"abandoned_warehouse": {
					"name": "廢棄倉庫",
					"description": "回聲網路的據點之一。裡面堆滿了記憶提取設備。",
					"connections": ["sewer_passage"],
					"initial_dialogue": "ch2_warehouse_explore",
					"hotspots": ["equipment", "desk_warehouse", "hidden_room", "diary_spot"]
				},
				"zhengtek_exterior": {
					"name": "正和科技大樓外圍",
					"description": "正和科技總部的後門區域。趙明在這裡等你。",
					"connections": ["bitstorm_cafe", "sewer_passage"],
					"initial_dialogue": "ch2_zhao_ming_meeting",
					"hotspots": ["back_entrance", "zhao_meeting_spot", "surveillance_camera"]
				},
				"sewer_passage": {
					"name": "下水道通道",
					"description": "連接各個地下場所的秘密通道。潮濕、黑暗，偶爾有老鼠經過。",
					"connections": ["bitstorm_cafe", "memory_black_market", "abandoned_warehouse", "zhengtek_exterior"]
				}
			}
		},

		3: {
			"title": "回聲深處",
			"description": "深入回聲網路總部，面對真相。",
			"action_points": 20,
			"starting_location": "echo_network_hq",
			"locations": {
				"echo_network_hq": {
					"name": "回聲網路總部",
					"description": "地下第十層的高科技設施。冰冷的白色走廊和嗡嗡作響的伺服器。",
					"connections": ["secret_lab", "memory_space"],
					"initial_dialogue": "ch3_opening",
					"hotspots": ["server_room", "control_panel", "corridor", "locked_door"]
				},
				"secret_lab": {
					"name": "正和科技秘密實驗室",
					"description": "記憶覆寫技術的核心實驗室。蕭博士的領地。",
					"connections": ["echo_network_hq", "rooftop"],
					"initial_dialogue": "ch3_dr_xiao_confrontation",
					"story_actions": [
						{"id": "find_hao_ran", "title": "搜尋浩然", "dialogue": "ch3_hao_ran_found"}
					],
					"hotspots": ["overwrite_device", "dr_xiao_desk", "hao_ran_chair", "ai_terminal"]
				},
				"memory_space": {
					"name": "凱的記憶空間",
					"description": "鷹眼觸發的內心空間。碎片化的記憶在這裡漂浮。",
					"connections": ["echo_network_hq"],
					"initial_dialogue": "ch3_echo_ai",
					"hotspots": ["memory_fragment_1", "memory_fragment_2", "memory_fragment_3"]
				},
				"rooftop": {
					"name": "屋頂",
					"description": "正和科技大樓的屋頂。風雨交加。城市的霓虹燈在遠處閃爍。",
					"connections": ["secret_lab", "office_epilogue"],
					"story_actions": [
						{
							"id": "resolve_case",
							"title": "結束案件",
							"use_calculated_ending": true,
							"ending_dialogues": ["ending_a_justice", "ending_b_grey_deal", "ending_c_memory_rebirth"]
						}
					],
					"hotspots": ["city_view", "confrontation_spot"]
				},
				"office_epilogue": {
					"name": "偵探辦公室（尾聲）",
					"description": "一切結束後。你的辦公室，雨還在下。",
					"story_actions": [
						{
							"id": "resolve_case_epilogue",
							"title": "回顧案件",
							"use_calculated_ending": true,
							"ending_dialogues": ["ending_a_justice", "ending_b_grey_deal", "ending_c_memory_rebirth"]
						}
					],
					"connections": []
				}
			}
		},
		"interrogations": {
			"dr_xiao": {
				"name": "蕭博士",
				"opening_line": "川崎先生，我們終於面對面了。坐吧。",
				"clam_up_threshold": 90,
				"broke_threshold": 80,
				"questions": [
					{
						"text": "你為什麼要做記憶覆寫的研究？",
						"type": "gentle",
						"pressure_change": 5,
						"response_normal": "因為記憶是人類最大的枷鎖，也是最大的寶藏。如果我們能編輯記憶，就能消除一切痛苦。",
						"response_pressured": "...一開始確實是為了治療創傷後壓力症。但正和科技看到了其他可能性。",
						"response_clammed": "你不會理解的。",
						"reveals": "xiao_motivation",
						"requires_pressure": 70
					},
					{
						"text": "正和科技用你的技術做了什麼？",
						"type": "neutral",
						"pressure_change": 10,
						"response_normal": "他們資助研究，我提供成果。這就是科學與資本的關係。",
						"response_pressured": "他們想用記憶覆寫來控制關鍵人物。政客、法官...甚至軍事指揮官。我無法阻止他們。",
						"response_clammed": "我已經說得夠多了。",
						"reveals": "zhengtek_plan",
						"requires_pressure": 75
					},
					{
						"text": "你對我做了什麼？我的記憶被篡改過嗎？",
						"type": "aggressive",
						"pressure_change": 15,
						"response_normal": "什麼讓你這麼認為？你的鷹眼只是一個普通的義體掃描器。",
						"response_pressured": "...你是我們最早的成功案例之一。你以為你是因為揭發腐敗而離開正和科技？真相沒那麼簡單。",
						"response_clammed": "這不重要了。重要的是未來。",
						"reveals": "kai_truth",
						"requires_pressure": 80
					},
					{
						"text": "放了浩然。這一切到此為止。",
						"type": "aggressive",
						"pressure_change": 20,
						"response_normal": "浩然很安全。他在這裡比外面安全得多。",
						"response_pressured": "好吧...也許是時候結束了。浩然在B區第三實驗室。但你要知道，他已經不完全是原來的他了。",
						"response_clammed": "你沒有資格對我提要求。",
						"reveals": "hao_ran_location",
						"requires_pressure": 85
					}
				],
				"evidence_reactions": {
					"overwrite_report": {
						"response": "你看到了完整的研究報告...我本以為那份已經被銷毀了。",
						"pressure_change": 20,
						"reveals": "report_reaction"
					},
					"zhengtek_funding": {
						"response": "（沉默良久）...是的。正和科技資助了一切。從第一天開始。",
						"pressure_change": 25,
						"reveals": "funding_confirmed"
					},
					"kai_memory_fragment": {
						"response": "（微微顫抖）你找到了...你自己的記憶碎片。那你應該已經知道了。",
						"pressure_change": 30,
						"reveals": "kai_memory_confirmed"
					}
				},
				"default_evidence_response": "有趣。但這改變不了什麼。"
			}
		}
	}
	return chapters.get(chapter, {})
