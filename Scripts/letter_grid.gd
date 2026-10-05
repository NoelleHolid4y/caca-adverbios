extends GridContainer

@onready var LetterGrid: GridContainer = $"."
@onready var LetterTile: PackedScene = preload("res://Scenes/letter_tile.tscn")

# Weitght's source: https://www.dcc.fc.up.pt/~rvr/naulas/tabelasPT/ 
const WEIGHTED_LETTERS: Dictionary = {
	"A": 14, "B": 1.0, "C": 4.4, "D": 5.4, "E": 12.2, "F": 1.0, "G": 1.2,
	"H": 0.8, "I": 6.9, "J": 0.4, "K": 0.1, "L": 2.8, "M": 4.2, "N": 5.3,
	"O": 10.8, "P": 2.9, "Q": 0.9, "R": 6.9, "S": 7.9, "T": 4.9, "U": 4.0,
	"V": 1.3, "W": 0.1, "X": 0.3, "Y": 0.1, "Z": 0.4
}
var rng = RandomNumberGenerator.new()

var COLS: int = 4
var ROWS: int = 4
var num_letters: int = COLS * ROWS

var tiles: Array[Node] = []
var selected: Array = []

signal word_updated(word: String)

func _ready() -> void:
	LetterGrid.columns = COLS
	# generate_grid()
	# debug_grid()

func generate_grid(answer: String) -> void:
	clear_grid()
	var letters := _build_letters(answer)
	for i in range(num_letters):
		var tile: Button = LetterTile.instantiate()
		tile.name = "Tile%d" % i
		LetterGrid.add_child(tile)
		tile.set_letter(letters[i])
		tiles.append(tile)
		tile.letter_pressed.connect(_on_letter_pressed)

func _build_letters(answer: String) -> Array[String]:
	var letters: Array[String] = []
	var normd_answer = SentenceData._normalize(answer).replace(" ", "")
	assert(normd_answer.length() <= num_letters, "Answer doesn't fit grid")
	for c in normd_answer:
			letters.append(c)
	var keys := WEIGHTED_LETTERS.keys()
	var weights := PackedFloat32Array(WEIGHTED_LETTERS.values())
	while letters.size() < num_letters:
		letters.append(keys[rng.rand_weighted(weights)])
	letters.shuffle()
	return letters

func clear_grid() -> void:
	for tile in tiles:
		tile.queue_free()
	tiles.clear()
	clear_selection()

func _on_letter_pressed(tile: Button):
	if tile.button_pressed:
		selected.append(tile)
	elif tile in selected:
		selected.erase(tile)
	_emit_word()

func add_space() -> void:
	if selected.size() == 0 or selected.front() is String or selected.back() is String:
		return
	selected.append(" ")
	_emit_word()

func get_current_word() -> String: # for visuals
	var word: String = ""
	for entry in selected:
		word += entry if entry is String else entry.current_letter
	return word

func get_current_word_clean() -> String: #for validation
	var word := get_current_word().strip_edges()
	while "  " in word:
		word = word.replace("  ", " ")
	return word

func clear_selection():
	for entry in selected:
		if entry is Button:
			entry.button_pressed = false
	selected.clear()
	word_updated.emit("")

func _emit_word() -> void:
	word_updated.emit(get_current_word())

func debug_grid():
	print("Current tiles:")
	for tile in tiles:
		print(tile.current_letter)
