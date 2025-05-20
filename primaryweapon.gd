extends Node2D

@export var selected_weapon_scene: PackedScene
var selected_weapon: weapon

# Called when the node enters the scene tree for the first time.
func _ready():
	if selected_weapon_scene:
		selected_weapon = selected_weapon_scene.instantiate() as weapon
		add_child(selected_weapon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
