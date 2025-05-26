extends Node2D

@export var Actor_Node = get_parent()

var actor_speed = 0

var current_pos = Vector2.ZERO
var goal_pos = Vector2.ZERO

var current_target

enum states {IDLE,WAITING,SHOOTING,MOVING}
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
	
	#DEBUG
	print("Entering IDLE state")
	current_state = states.IDLE
	
# Called when the node enters the scene tree for the first time.
func _ready():
	actor_speed = Actor_Node.speed
	start_wait()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_pos = Actor_Node.position
	
	#check to generate new random move
	if current_state == states.IDLE:
		get_random_loc()
		current_state = states.MOVING
	
	if current_state == states.MOVING and current_pos != goal_pos:
		print("current: ", current_pos, " goal: ", goal_pos)
		current_state = states.MOVING
		var velocity = move_to_loc(goal_pos)
		if velocity == Vector2.ZERO:
			start_wait()
		else:
			Actor_Node.position = (Actor_Node.position + velocity * delta).snapped(Vector2.ONE)
#			Actor_Node.position += velocity * delta
