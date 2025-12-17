extends Node

var total_xp: int = 0
var available_xp: int = 0 

func _enter_tree() -> void:
	EventSystem.XP_award_xp.connect(award_xp)
	EventSystem.SKL_skill_unlocked.connect(_on_skill_unlocked)

func award_xp(amount: int) -> void:
	total_xp += amount
	available_xp += amount
	EventSystem.XP_xp_updated.emit(available_xp, total_xp)

func _get_available_xp() -> int:
	return available_xp

func _spend_xp(amount: int) -> bool:
	if available_xp >= amount:
		available_xp -= amount
		EventSystem.XP_xp_updated.emit(available_xp, total_xp)
		return true
	return false

func _on_skill_unlocked(_skill_key: String) -> void:
	pass
