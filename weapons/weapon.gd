extends Node2D

class_name weapon

@export var display_name = "Default Weapon"
@export var damage = 30
@export var automatic = false
@export var shot_cycle = 5

var shot = load("shot.gd")
var shot_timer = 0
var is_firing = false

func shoot(shot_start, shot_pos):
	#	print("Mouse Click/Unclick at: ", event.position)
	var shot_scene = preload("res://shot.tscn")
#	var new_shot = shot.new()
	var new_shot = shot_scene.instantiate()
#	$".".get_parent().add_child(new_shot)
	get_tree().current_scene.add_child(new_shot)
#	new_shot.draw_shot(shot_start,shot_pos)
	new_shot.start = shot_start
	new_shot.end = shot_pos
	new_shot.damage = damage
	new_shot.shoot_projectile()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
