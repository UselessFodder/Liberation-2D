extends Node2D
class_name Enemy

@export var max_health = 100
@export var speed = 30
@export var health_size = 20
@export var engagement_dist = 300
@export var accuracy = 50

@onready var ai_component = $AIComponent

var health = max_health
var health_bar = Rect2(Vector2(position.x - (health_size/2), position.y - 20), Vector2(health_size, 5))
var health_color = Color(1,0,0)
var health_bg = Rect2(Vector2(position.x - (health_size/2)-2, position.y - 22), Vector2(health_size+4, 11))
var health_bg_color = Color(1,1,1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	var bar_size: float = float(health_size) * (float(health)/float(max_health))
	health_bar.size = Vector2(bar_size, 7)
	print((float(health)/float(max_health)))
	if bar_size > 0:
		draw_rect(health_bg, health_bg_color, true, 5)
		draw_rect(health_bar, health_color, true, 5)

	#ChatGPT Generated Code
	if ai_component.current_target:
		print("Drawing line")
		var dir = (ai_component.current_target.global_position - global_position).normalized()
		var end = dir * 20
		draw_line(Vector2.ZERO, end, Color.BLACK, 2)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health <= 0:
		queue_free()
	
	queue_redraw()

func change_heath(change_amount):
	health = health + change_amount
	queue_redraw()
