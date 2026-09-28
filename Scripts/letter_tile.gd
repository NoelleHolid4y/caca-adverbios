extends Button

@onready var LetterTile: Button = $"."

var LETTERS = [
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
	"T", "U", "V", "W", "X", "Y", "Z"
	]
var current_letter: String = ""

signal letter_pressed(tile: Button)

func _ready() -> void:
	current_letter = reroll_letter()
	LetterTile.pressed.connect(_on_tile_pressed)

func get_random_letter():
	return LETTERS[randi() % len(LETTERS)]

func reroll_letter():
	var letter = get_random_letter()
	LetterTile.text = letter
	return letter

func _on_tile_pressed():
	print("Pressed tile of letter %c" % current_letter)
	letter_pressed.emit(self)

func _on_debug_rand_pressed() -> void:
	print(reroll_letter())
