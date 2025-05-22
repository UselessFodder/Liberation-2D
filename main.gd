extends Node2D

#var timers = []

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$mainUI.update_ammo_count($player.current_weapon.current_ammo_count,$player.current_weapon.ammo_count)
#
#	for i in timers.size():
#		var current_timer = timers[i]
#		if current_timer > 0:
#			current_timer -= 1
#		else:
#			timers.remove_at(i)
