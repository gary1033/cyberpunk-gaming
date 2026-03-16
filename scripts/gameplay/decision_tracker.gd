extends Node
## DecisionTracker - Tracks player decisions throughout the game and determines ending.

class_name DecisionTracker

# Key decision points that affect the ending
enum DecisionWeight { LOW = 1, MEDIUM = 2, HIGH = 3 }

var _decision_log: Array[Dictionary] = []

func record_decision(decision_id: String, choice: String, weight: DecisionWeight = DecisionWeight.MEDIUM) -> void:
	_decision_log.append({
		"id": decision_id,
		"choice": choice,
		"weight": weight,
		"chapter": GameManager.current_chapter,
		"timestamp": Time.get_ticks_msec()
	})

	# Apply specific effects
	match decision_id:
		"trust_zhao_ming":
			GameManager.decisions["trusted_zhao_ming"] = (choice == "trust")
		"market_disguise":
			GameManager.decisions["identity_exposed_market"] = (choice == "exposed")
		"memory_attitude_final":
			GameManager.decisions["memory_attitude"] = choice

func get_ending_factors() -> Dictionary:
	var factors := {
		"evidence_ratio": float(GameManager.decisions["total_evidence_collected"]) / 28.0,
		"correct_deductions": GameManager.decisions["correct_deductions"],
		"trusted_zhao": GameManager.decisions["trusted_zhao_ming"],
		"identity_exposed": GameManager.decisions["identity_exposed_market"],
		"memory_attitude": GameManager.decisions["memory_attitude"],
		"ajie_pressure": GameManager.decisions["interrogation_pressure_ajie"],
		"ghost_pressure": GameManager.decisions["interrogation_pressure_ghost"],
		"xiao_pressure": GameManager.decisions["interrogation_pressure_dr_xiao"],
	}

	# Calculate affinity scores
	factors["zhao_ming_affinity"] = GameManager.character_affinity.get("zhao_ming", 0)
	factors["mei_ling_affinity"] = GameManager.character_affinity.get("mei_ling", 0)

	return factors

func get_decision_log() -> Array[Dictionary]:
	return _decision_log.duplicate(true)
