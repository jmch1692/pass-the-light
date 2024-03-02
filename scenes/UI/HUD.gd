extends Control
	
@onready var level : Label = $CanvasLayer/Level

@export var npc_texture : Texture2D

var saved_npcs : Array[TextureRect] = []

func _ready():
	level.text = "Level: " + str(GlobalGameSettings.game_settings["current_level"])
	SignalBus.npc_saved.connect(_on_npc_saved)
	SignalBus.npc_lost.connect(_on_npc_lost)
	SignalBus.increase_level.connect(_on_increase_level)
	
func _draw():
	level.text = "Level: " + str(GlobalGameSettings.game_settings["current_level"])
	for npc in saved_npcs:
		if !npc.is_inside_tree():
			self.get_node("CanvasLayer").add_child(npc)
		
func _on_npc_saved():
	var saved_npc = TextureRect.new()
	saved_npc.texture = npc_texture
	if saved_npcs.is_empty():
		saved_npc.position = Vector2i(15, 10)
		saved_npcs.append(saved_npc)
	else:
		var last_position = saved_npcs.back()
		var new_position = Vector2i(last_position.position.x + 20, last_position.position.y)
		saved_npc.position = new_position
		saved_npcs.append(saved_npc)
		
	queue_redraw()
	
func _on_npc_lost():
	if not saved_npcs.is_empty():
		var lost_npc = saved_npcs.pop_back()
		lost_npc.queue_free()

func _on_increase_level():
	GlobalGameSettings.game_settings["saved_npcs_total"] += saved_npcs.size()
	GlobalGameSettings.game_settings["current_level"] += 1
