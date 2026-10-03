extends Control

@onready var LetterGrid: GridContainer = %LetterGrid
@onready var WordLabel: Label = %PlayerWord
@onready var Sentence: Label = %Sentence
@onready var Reset: Button = %ResetWord
@onready var Submit: Button = %Submit
@onready var bank: SentenceBank = preload("res://Data/answer_key.tres")
@onready var current_sentence: SentenceData

func _ready() -> void:
	LetterGrid.word_updated.connect(_on_word_updated)
	Reset.pressed.connect(_on_reset_pressed)
	Submit.pressed.connect(_on_submit_pressed)
	start_round()

func start_round(): #TODO: handle difficulty scaling 
	current_sentence = bank.get_random_sentence()
	Sentence.text = current_sentence.sentence
	LetterGrid.generate_grid(current_sentence.get_main_answer())

func _on_word_updated(word: String):
	WordLabel.text = word

func _on_reset_pressed():
	LetterGrid.clear_selection()

func _on_submit_pressed() -> void:
	if current_sentence.is_correct(LetterGrid.get_current_word()):
		print("Correct!")
		start_round()
	else:
		print("Wrong!")
		#TODO: make it end the round with result screen (or add lives system)
