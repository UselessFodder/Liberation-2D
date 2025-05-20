extends Node2D
@export var tiles: Array[Texture2D] = []
#define number of grid squares and size of each
var grid_size = 64

var scale_x = 2
var scale_y = 2

var start_loc = -1 * (grid_size/2)

var background = []

# Called when the node enters the scene tree for the first time.
func _ready():
	background.resize(grid_size)
	for i in range(grid_size):
		background[i] = []
		background[i].resize(grid_size)
		for j in grid_size:
			background[i][j] = tiles.pick_random()
		
	#print(background[0][0])

func _draw():
	var current_X = start_loc
	var current_Y = start_loc
	
#	draw_texture(background[0][0],Vector2(0,0))
	#use background tiles to create Texture2Ds at correct grid locations
	for i in background:
		for j in i:
			draw_set_transform(Vector2.ZERO, 0.0, Vector2(scale_x, scale_y))
			draw_texture(j,Vector2(current_X*16, current_Y*16))
			#print(j)
			current_Y = current_Y + 1

		current_X = current_X + 1
		current_Y = start_loc

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#creates a randomized background map
func generate_map():
	pass
