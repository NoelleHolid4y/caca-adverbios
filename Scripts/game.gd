extends Control

@onready var LetterGrid: GridContainer = %LetterGrid
@onready var WordLabel: Label = %PlayerWord
@onready var Sentence: Label = %Sentence
@onready var ScoreLabel: Label = %Score
@onready var Reset: Button = %ResetWord
@onready var Submit: Button = %Submit
@onready var SpaceButton: Button = %Space
@onready var bank: SentenceBank = preload("res://Data/answer_key.tres")
@onready var current_sentence: SentenceData

var score: float = 0.0
var score_mult: float = 1.0

func _ready() -> void:
	LetterGrid.word_updated.connect(_on_word_updated)
	Reset.pressed.connect(_on_reset_pressed)
	Submit.pressed.connect(_on_submit_pressed)
	SpaceButton.pressed.connect(LetterGrid.add_space)
	start_round()

func start_round(): #TODO: handle difficulty scaling 
	current_sentence = bank.get_random_sentence()
	Sentence.text = current_sentence.sentence
	ScoreLabel.text = "Score: " + str(score)
	LetterGrid.generate_grid(current_sentence.get_main_answer())

func calculate_score(answer: String) -> float:
	var is_not_main: bool = not (answer == current_sentence.get_main_answer())
	var score_gain: float = 0.0
	score_gain = answer.length() * current_sentence.difficulty * score_mult + (int(is_not_main) * 50)
	return score_gain

func _on_word_updated(word: String):
	WordLabel.text = word

func _on_reset_pressed():
	LetterGrid.clear_selection()

func _on_submit_pressed() -> void:
	var is_correct_answer = current_sentence.is_correct(LetterGrid.get_current_word_clean())
	if is_correct_answer:
		score += calculate_score(LetterGrid.get_current_word_clean())
		start_round()
	else:
		print("Wrong!")
		#TODO: make it end the round with result screen (or add lives system)
