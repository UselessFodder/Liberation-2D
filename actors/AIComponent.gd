extends Node2D

@export var Actor_Node = get_parent()

var actor_speed = 0

var current_pos = Vector2.ZERO
var goal_pos = Vector2.ZERO

var current_target

enum states {IDLE,WAITING,ENGAGING,SHOOTING,RELOADING,MOVING}
var current_state = states.IDLE

func move_to_loc(new_loc):
	if current_pos.distance_to(goal_pos) < 2:
		Actor_Node.position.x = goal_pos.x
		Actor_Node.position.y = goal_pos.y
		
		return Vector2.ZERO 
	else:
#		if abs(current_pos.y) - abs(goal_pos.y) < 1:
#			Actor_Node.position.y = goal_pos.y
#		if abs(current_pos.x) - abs(goal_pos.x) < 1:
#			Actor_Node.position.x = goal_pos.x
		
		var velocity = Vector2.ZERO
		
		if new_loc.x > current_pos.x:
			velocity.x = 1
		if new_loc.x < current_pos.x:
			velocity.x = -1
		if new_loc.y > current_pos.y:
			velocity.y = 1
		if new_loc.y < current_pos.y:
			velocity.y = -1
		
		velocity.x = velocity.x * actor_speed
		velocity.y = velocity.y * actor_speed	
		
		return velocity

func get_random_loc():
	var move_distance = 100
	#get offset from current position
	var new_x = current_pos.x + (randi_range(-1 * move_distance,move_distance))
	var new_y = current_pos.y + (randi_range(-1 * move_distance,move_distance))
	
	goal_pos = Vector2(new_x,new_y)
	
	#DEBUG
	print("New location received:", goal_pos)
	
	return goal_pos

func start_wait():
	current_state = states.WAITING
	
	var wait_time = randi_range(3,10)
	
	#DEBUG
	print("Entering WAIT state for ", wait_time, " seconds")
	
	await get_tree().create_timer(wait_time).timeout
	
	#unit may have engaged in this time
	if current_state == states.WAITING:
		#DEBUG
		print("Entering IDLE state")
		current_state = states.IDLE

func start_reload():
	current_state = states.RELOADING
	
	var reload_time = randi_range(3,5)
	
	#DEBUG
	print("Entering RELOAD state for ", reload_time, " seconds")
	
	await get_tree().create_timer(reload_time).timeout
	
	var dist = current_pos.distance_to(current_target.global_position)
	var engagement_dist = Actor_Node.engagement_dist
	
	if dist > engagement_dist:
		#if enemy is outside reasonable distance, return to idel
		if dist > engagement_dist * 2:
			print("enemy is now outside range at", dist, ". Entering IDLE state")
			current_target = null
			current_state = states.IDLE
		#if still within reasonable distance, move towards position and retarget
		else:
			print("enemy is now outside range at", dist, ". Entering MOVE state")
			goal_pos = current_target.global_position
			current_state = states.MOVING
			current_target = null
	else:
		print("Entering ENGAGING state")
		current_state = states.ENGAGING

func shoot():
#	#for tuning
#	var accuracy_multiplier = 20
#	#affect accuracy
#	var accuracy = abs(1 - Actor_Node.accuracy/100)
##	var shot_error = Vector2(randf_range(0, accuracy_multiplier * 2 * accuracy) - accuracy_multiplier,
##		randf_range(0, accuracy_multiplier *2 * accuracy) - accuracy_multiplier)
#	var shot_error = Vector2(randfn(accuracy_multiplier, 1) - accuracy_multiplier,
#		randfn(accuracy_multiplier, 1) - accuracy_multiplier)

	#for tuning (ChatGPT assisted)
	var max_deviation = 20.0
	var accuracy = Actor_Node.accuracy
	
	#add in variance for distance
	var dist_to_target = global_position.distance_to(current_target.global_position)
	var dist_deviation = dist_to_target / (Actor_Node.engagement_dist/2)
	
	var shot_deviation = max_deviation * (1.0 - accuracy/100.0) * dist_deviation
	
	#get aiming error
	var shot_error = Vector2(randfn(0,shot_deviation), randfn(0,shot_deviation))
	print("Shot accuracy is ", accuracy, "leading to an offset of ", shot_error)
	
	#get target pos and apply error
	var shot_pos = current_target.global_position + shot_error
	var shot_start = $".".global_position + Vector2(0,0)
	var shot_offset = 6
	
	if shot_pos.x < (shot_start.x - 10):
		shot_start -= Vector2(shot_offset,0)
	elif shot_pos.x > (shot_start.x + 10):
		shot_start += Vector2(shot_offset,0)
	if shot_pos.y < (shot_start.y - 15):
		shot_start -= Vector2(0, shot_offset)
	elif shot_pos.y > (shot_start.y + 15):
		shot_start += Vector2(0, shot_offset)

	#fire
	var shot_scene = preload("res://shot.tscn")
	var new_shot = shot_scene.instantiate()
	get_tree().current_scene.add_child(new_shot)
	new_shot.start = shot_start
	new_shot.end = shot_pos
	new_shot.damage = 30
	new_shot.shoot_projectile()

# Called when the node enters the scene tree for the first time.
func _ready():
	actor_speed = Actor_Node.speed
	start_wait()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_pos = Actor_Node.position
	
	#check if current target exists and is in range
	if current_target == null:
		#check for any players in range
		for player in get_tree().get_nodes_in_group("players"):
			var dist = current_pos.distance_to(player.global_position)
			if dist <= Actor_Node.engagement_dist:
				print ("player ", player," is within range at dist: ", dist)
				current_target = player
				current_state = states.ENGAGING
				break
	
	if current_state == states.ENGAGING:
		shoot()
		start_reload()
	
	#check to generate new random move
	if current_state == states.IDLE:
		get_random_loc()
		current_state = states.MOVING
	
	if current_state == states.MOVING and current_pos != goal_pos:
		#print("current: ", current_pos, " goal: ", goal_pos)
		current_state = states.MOVING
		var velocity = move_to_loc(goal_pos)
		if velocity == Vector2.ZERO:
			start_wait()
		else:
			Actor_Node.position = (Actor_Node.position + velocity * delta).snapped(Vector2.ONE)
#			Actor_Node.position += velocity * delta

#func _draw():
#	#ChatGPT generated code
#	if current_state in [states.ENGAGING, states.SHOOTING] and current_target:
#		var start_point = Actor_Node.global_position
#		var end_point = start_point + (current_target.global_position - start_point).normalized() * 20
#		draw_line(to_local(start_point), to_local(end_point), Color.RED, 2)
#
