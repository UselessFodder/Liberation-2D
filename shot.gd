extends Node2D
var start : Vector2 = Vector2(0,0)
var end : Vector2 = Vector2(0,0)
var speed: float = 400.0
var dir: Vector2 = Vector2(0,0)
var life: int = 1
var damage: int = 0

func timed_destroy():
	await get_tree().create_timer(life).timeout
	queue_free()

func shoot_projectile():
	position = start
	dir = (end-start).normalized()
	rotation = dir.angle()

func _draw():
	#draw_line(start, end,Color.WHITE, 1)
	pass

func draw_shot(start_point, end_point):
	start = start_point
	end = end_point
	#queue_redraw()

func check_impact():
	# Create query object
	var physics_point = PhysicsPointQueryParameters2D.new()
	physics_point.position = position
	physics_point.collide_with_areas = true
	physics_point.collide_with_bodies = true
#	physics_point.max_results = 32  # optional

	# Perform intersection test
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_point(physics_point)
	if result.size() > 0:
		var hit_object_collider = result[0]["collider"]
		print("Hit object: ", hit_object_collider.name)
		
		var hit_object = hit_object_collider.get_parent()
		if hit_object is enemy:
			print("Parent is an Enemy!")
			hit_object.change_heath(damage * -1)
			queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	timed_destroy()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += dir * speed * delta
	
	#check if shot has reached end and delete if so
	var endpoint = end - position
	check_impact()
	if endpoint.dot(dir) <= 0:
		queue_free()
