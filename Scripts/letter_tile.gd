extends Button

@onready var LetterTile: Button = $"."

var LETTERS = [
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
	"T", "U", "V", "W", "X", "Y", "Z"
	]
var current_letter: String = ""

func _ready() -> void:
	current_letter = reroll_letter()
	# print(current_letter)


func get_random_letter():
	return LETTERS[randi() % len(LETTERS)]

func reroll_letter():
	var letter = get_random_letter()
	LetterTile.text = letter
	return letter

func _on_debug_rand_pressed() -> void:
	print(reroll_letter())
