extends GridContainer

@onready var LetterGrid: GridContainer = $"."
@onready var LetterTile: PackedScene = preload("res://Scenes/letter_tile.tscn")

var COLS: int = 4
var ROWS: int = 4
var num_letters: int = COLS * ROWS

var tiles: Array[Node] = []

func _ready() -> void:
	LetterGrid.columns = COLS
	generate_grid()
	# debug_grid()

func generate_grid():
	clear_grid()
	for i in range(num_letters):
		var tile: Button = LetterTile.instantiate()
		tile.name = "Tile%d" % i
		LetterGrid.add_child(tile)
		tiles.append(tile)

func clear_grid():
	for tile in tiles:
		tile.queue_free()
	tiles.clear()

func debug_grid():
	print("Current tiles:")
	for tile in tiles:
		print(tile.current_letter)
