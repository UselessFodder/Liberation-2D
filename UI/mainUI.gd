extends CanvasLayer

var ammo_count_label

func update_ammo_count(current_ammo, max_ammo):
	var new_text = str(current_ammo, '/', max_ammo)
	ammo_count_label.text = new_text

# Called when the node enters the scene tree for the first time.
func _ready():
	ammo_count_label = $MarginContainer/Rows/BottomBar/HBoxContainer/AmmoCountLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
