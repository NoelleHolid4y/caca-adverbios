extends Control

@onready var LetterGrid: GridContainer = $LetterGrid
@onready var WordLabel: Label = $Word 
@onready var Reset: Button =  $ResetWord

func _ready() -> void:
	LetterGrid.word_updated.connect(_on_word_updated)
	Reset.pressed.connect(_on_reset_pressed)

func _on_word_updated(word: String):
	WordLabel.text = word

func _on_reset_pressed():
	LetterGrid.clear_selection()
