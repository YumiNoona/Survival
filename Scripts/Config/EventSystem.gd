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
