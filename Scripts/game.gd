extends Control

@onready var LetterGrid: GridContainer = $LetterGrid
@onready var WordLabel: Label = $Word 
@onready var Reset: Button =  $ResetWord
@onready var bank: SentenceBank = preload("res://Data/answer_key.tres")
@onready var current_sentence: SentenceData

func _ready() -> void:
	LetterGrid.word_updated.connect(_on_word_updated)
	Reset.pressed.connect(_on_reset_pressed)
	start_round()

func start_round(): #TODO: handle difficulty scaling 
	current_sentence = bank.get_random_sentence()
	LetterGrid.generate_grid(current_sentence.get_main_answer())

func _on_word_updated(word: String):
	WordLabel.text = word

func _on_reset_pressed():
	LetterGrid.clear_selection()
