extends GridContainer

@onready var LetterGrid: GridContainer = $"."
@onready var LetterTile: PackedScene = preload("res://Scenes/letter_tile.tscn")

var COLS: int = 4
var ROWS: int = 4
var num_letters: int = COLS * ROWS

var tiles: Array[Node] = []
var selected_tiles: Array[Node] = []

signal word_updated(word: String)

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
		tile.letter_pressed.connect(_on_letter_pressed)

func clear_grid():
	for tile in tiles:
		tile.queue_free()
	tiles.clear()

func _on_letter_pressed(tile: Button):
	if tile.button_pressed:
		selected_tiles.append(tile)
		word_updated.emit(get_current_word())
	elif tile in selected_tiles:
		selected_tiles.erase(tile)
		word_updated.emit(get_current_word())

func get_current_word():
	var word: String = ""
	for tile in selected_tiles:
		word += tile.current_letter
	return word

func clear_selection():
	for tile in selected_tiles:
		tile.button_pressed = false
	selected_tiles.clear()
	word_updated.emit("")
	print("Cleared selection!")

func debug_grid():
	print("Current tiles:")
	for tile in tiles:
		print(tile.current_letter)
