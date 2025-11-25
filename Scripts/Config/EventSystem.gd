extends Node

#BulletIn Signal

@warning_ignore("unused_signal")
signal BUL_create_bulletin

@warning_ignore("unused_signal")
signal BUL_destroy_bulletin

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

#Player Signal

@warning_ignore("unused_signal")
signal PLA_frezze_player

@warning_ignore("unused_signal")
signal PLA_unfrezze_player

@warning_ignore("unused_signal")
signal PLA_change_energy

@warning_ignore("unused_signal")
signal PLA_energy_updated

@warning_ignore("unused_signal")
signal PLA_change_health

@warning_ignore("unused_signal")
signal PLA_health_updated

#Equip Signal

@warning_ignore("unused_signal")
signal EQU_hotkey_pressed

@warning_ignore("unused_signal")
signal EQU_equip_item

@warning_ignore("unused_signal")
signal EQU_unequip_item

@warning_ignore("unused_signal")
signal EQU_active_hotbar_slot_updated

#Spawn Signal

@warning_ignore("unused_signal")
signal SPA_spawn_scene
