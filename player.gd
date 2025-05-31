extends Node2D
class_name Player

@export var health = 100
@export var speed = 200
var max_health = health

var health_bar = Rect2(Vector2(position.x - (20/2), position.y - 20), Vector2(20, 5))
var health_color = Color(1,0,0)
var health_bg = Rect2(Vector2(position.x - (20/2)-1, position.y - 21), Vector2(20+2, 7))
var health_bg_color = Color(1,1,1)

var shot = load("shot.gd")
var velocity = Vector2.ZERO
var force = Vector2.ZERO

#weapon vars
var selected_weapon_slot
var current_weapon: weapon
var automatic: bool
var shot_cycle: int
var shot_timer = 0
var is_firing = false

func movement():
	velocity = Vector2.ZERO # The player's movement vector.
	#check for movement keys and add or remove movement vector
	if Input.is_action_pressed("move_east"):
		velocity.x += 1
	if Input.is_action_pressed("move_west"):
		velocity.x -= 1
	if Input.is_action_pressed("move_south"):
		velocity.y += 1
	if Input.is_action_pressed("move_north"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	#ensure sprite is pointing in correct direction
	$AnimatedSprite2D.flip_h = get_global_mouse_position().x < $".".global_position.x
		
	return velocity

func zoom():
	#zoom in or our with mouse wheel
	if Input.is_action_just_pressed("zoom_in"):
		if $Camera2D.zoom.x < 4.0:
			$Camera2D.zoom.x += 0.5
			$Camera2D.zoom.y += 0.5
	elif Input.is_action_just_pressed("zoom_out"):
		if $Camera2D.zoom.x > 1.0:
			$Camera2D.zoom.x -= 0.5
			$Camera2D.zoom.y -= 0.5

func shoot():
	var shot_pos = get_global_mouse_position()
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
	
	if velocity != Vector2.ZERO:
		shot_start.x += (velocity.x / 20)
		shot_start.y += (velocity.y / 20)

	#get current weapon and fire
	current_weapon.shoot(shot_start,shot_pos)

func change_weapon(new_weapon_slot):
	current_weapon = new_weapon_slot.selected_weapon
	automatic = current_weapon.automatic
	shot_cycle = current_weapon.shot_cycle
	
	#display new weapon
	display_text_temporary(current_weapon.display_name, 2)

func display_text(new_text):
	$overheadlabel.text = new_text
	
func display_text_temporary(new_text,timer):
	$overheadlabel.text = new_text
	await get_tree().create_timer(timer).timeout
	$overheadlabel.text = ""

func change_heath(change_amount):
	health = health + change_amount
	queue_redraw()

func knockback(dir, power):
	force = dir.normalized() * power

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("players")
	
	#set current weapon
	selected_weapon_slot = $primaryweapon
	change_weapon(selected_weapon_slot)

func _draw():
	var bar_size: float = float(20) * (float(health)/float(max_health))
	health_bar.size = Vector2(bar_size, 5)
	
	#DEBUG
	#print((float(health)/float(max_health)))
	if bar_size > 0:
		draw_rect(health_bg, health_bg_color, true)
		draw_rect(health_bar, health_color, true)


func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if event.pressed == true and event.button_index == 1:
			if automatic:
				is_firing = true
				shot_timer = 0
			elif shot_timer == 0:
				shoot()
				shot_timer = shot_cycle
		elif event.pressed == false and event.button_index == 1:
			is_firing = false
		
	elif event is InputEventMouseMotion:
		$cursor.global_position =  get_global_mouse_position()
		
	if event is InputEventKey:
		if event.is_action_pressed("primary_weapon"):
			print("primary weapon key pressed")
			change_weapon($primaryweapon)
		elif event.is_action_pressed("secondary_weapon"):
			print("secondary weapon key pressed")
			change_weapon($secondaryweapon)
			
		if event.is_action_pressed("reload"):
			print("reloading")
			current_weapon.reload()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#handle movement
	velocity = movement()
	position += (velocity + force) * delta
	
	force.x = move_toward(force.x,0,5)
	force.y = move_toward(force.y,0,5)
	
	#handle zoom
	zoom()
	
	if is_firing && shot_timer == 0:
		shoot()
		shot_timer += shot_cycle
	if shot_timer > 0:
		shot_timer -= 1

func get_label():
	return $overheadlabel
