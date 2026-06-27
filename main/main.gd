extends Node

#func _ready():
	#var world = preload("res://world/world.tscn").instantiate()
	#add_child(world)
#
	#var ui = preload("res://interface/interface.tscn").instantiate()
	#add_child(ui)
	
	#ui.set_world(world)
	#GameSettings.set_fullscreen(true)
	
	#var hud = ui.find_child("TextureButton", true, false)
	#var battle_system = world.find_child("BattleSystemNode", true, false)
	
	#if hud and battle_system:
		#hud.end_turn.connect(battle_system.execute_turn_actions)
		
	#GameManager.current_context = GameManager.Context.MAIN_MENU


func _on_config_pressed() -> void:
	PauseMenu.pause()
