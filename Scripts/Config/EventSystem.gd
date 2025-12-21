extends Node

#BulletIn Signal

@warning_ignore("unused_signal")
signal BUL_create_bulletin

@warning_ignore("unused_signal")
signal BUL_destroy_bulletin

@warning_ignore("unused_signal")
signal BUL_destroy_all_bulletins

@warning_ignore("unused_signal")
signal STA_change_stage

#Inventory Signal

@warning_ignore("unused_signal")
signal INV_try_to_pickup_item

@warning_ignore("unused_signal")
signal INV_ask_update_inventory

@warning_ignore("unused_signal")
signal INV_inventory_updated

@warning_ignore("unused_signal")
signal INV_hotbar_updated

@warning_ignore("unused_signal")
signal INV_switch_to_item_indexes

@warning_ignore("unused_signal")
signal INV_add_item

@warning_ignore("unused_signal")
signal INV_delete_crafting_item

@warning_ignore("unused_signal")
signal INV_delete_item_by_index

@warning_ignore("unused_signal")
signal INV_add_item_by_index

#Player Signal

@warning_ignore("unused_signal")
signal PLA_freeze_player

@warning_ignore("unused_signal")
signal PLA_unfreeze_player

@warning_ignore("unused_signal")
signal PLA_change_energy

@warning_ignore("unused_signal")
signal PLA_energy_updated

@warning_ignore("unused_signal")
signal PLA_change_health

@warning_ignore("unused_signal")
signal PLA_health_updated

@warning_ignore("unused_signal")
signal PLA_change_hunger

@warning_ignore("unused_signal")
signal PLA_hunger_updated

@warning_ignore("unused_signal")
signal PLA_player_sleep

#Equip Signal

@warning_ignore("unused_signal")
signal EQU_hotkey_pressed

@warning_ignore("unused_signal")
signal EQU_equip_item

@warning_ignore("unused_signal")
signal EQU_unequip_item

@warning_ignore("unused_signal")
signal EQU_active_hotbar_slot_updated

@warning_ignore("unused_signal")
signal EQU_delete_equipped_item

#Spawn Signal

@warning_ignore("unused_signal")
signal SPA_spawn_scene

@warning_ignore("unused_signal")
signal SPA_spawn_vfx

@warning_ignore("unused_signal")
signal SPA_spawn_damage_number(damage: float, position: Vector3)

#SFX/Music Signal
@warning_ignore("unused_signal")
signal SFX_play_sfx

@warning_ignore("unused_signal")
signal SFX_play_dynamic_sfx

@warning_ignore("unused_signal")
signal MUS_play_music

@warning_ignore("unused_signal")
signal SET_music_volume_changed

@warning_ignore("unused_signal")
signal SET_sfx_volume_changed

#Game Signal
@warning_ignore("unused_signal")
signal GAM_fast_forward_day_night_anim

@warning_ignore("unused_signal")
signal GAM_game_fade_in

@warning_ignore("unused_signal")
signal GAM_game_fade_out

@warning_ignore("unused_signal")
signal GAM_update_navmesh

#HUD Signal
@warning_ignore("unused_signal")
signal HUD_hide_hud

@warning_ignore("unused_signal")
signal HUD_show_hud

#Settings Signal
@warning_ignore("unused_signal")
signal SET_res_scale_changed

@warning_ignore("unused_signal")
signal SET_ssaa_changed

@warning_ignore("unused_signal")
signal SET_fullscreen_changed

@warning_ignore("unused_signal")
signal SET_ask_settings_resource

@warning_ignore("unused_signal")
signal SET_save_settings

#XP Signal
@warning_ignore("unused_signal")
signal XP_award_xp

@warning_ignore("unused_signal")
signal XP_xp_updated

#Skill Signal
@warning_ignore("unused_signal")
signal SKL_try_unlock_skill

@warning_ignore("unused_signal")
signal SKL_skill_unlocked

@warning_ignore("unused_signal")
signal SKL_is_skill_unlocked

@warning_ignore("unused_signal")
signal SKL_get_skill_level

#Crafting Signal
@warning_ignore("unused_signal")
signal CRAFT_unlock_weapon_tier

@warning_ignore("unused_signal")
signal CRAFT_unlock_recipe

#Inventory Signal (for skill unlocks)
@warning_ignore("unused_signal")
signal INV_add_inventory_slots

@warning_ignore("unused_signal")
signal INV_inventory_slots_added

#Player Stat Modifications (for skill unlocks)
@warning_ignore("unused_signal")
signal PLA_enable_double_jump

@warning_ignore("unused_signal")
signal PLA_increase_movement_speed

@warning_ignore("unused_signal")
signal PLA_increase_max_health

@warning_ignore("unused_signal")
signal PLA_increase_max_energy

@warning_ignore("unused_signal")
signal PLA_increase_attack_damage

#Time Signal
@warning_ignore("unused_signal")
signal TIM_time_updated

@warning_ignore("unused_signal")
signal TIM_day_changed

@warning_ignore("unused_signal")
signal TIM_skip_time

@warning_ignore("unused_signal")
signal TIM_set_time_speed

#Mission Signal
@warning_ignore("unused_signal")
signal MIS_mission_completed

@warning_ignore("unused_signal")
signal MIS_mission_progress_updated

@warning_ignore("unused_signal")
signal MIS_item_collected

@warning_ignore("unused_signal")
signal MIS_item_crafted

#Level Signal
@warning_ignore("unused_signal")
signal LEV_level_up

@warning_ignore("unused_signal")
signal LEV_level_updated
