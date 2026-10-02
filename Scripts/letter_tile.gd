extends Button

@onready var LetterTile: Button = $"."

var current_letter: String = ""

signal letter_pressed(tile: Button)

func _ready() -> void:
	LetterTile.pressed.connect(_on_tile_pressed)

func set_letter(letter: String):
	current_letter = letter
	LetterTile.text = letter

func _on_tile_pressed():
	letter_pressed.emit(self)
