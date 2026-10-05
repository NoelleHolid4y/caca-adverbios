extends Control

@onready var LetterGrid: GridContainer = %LetterGrid
@onready var ClassifyButtons: GridContainer = %ClassifyButtons
@onready var TimeLeft: Label = %TimeLeft
@onready var WordLabel: Label = %PlayerWord
@onready var Sentence: Label = %Sentence
@onready var ScoreLabel: Label = %Score
@onready var FeedbackLabel: Label = %FeedbackLabel
@onready var Reset: Button = %ResetWord
@onready var Submit: Button = %Submit
@onready var SpaceButton: Button = %Space
@onready var NextButton: Button = %Next
@onready var RoundTimer: Timer = %RoundTimer
@onready var TimeBar: ProgressBar = %TimeBar
@onready var bank: SentenceBank = preload("res://Data/answer_key.tres")
@onready var current_sentence: SentenceData

enum GameState {
	ANSWERING, CLASSIFYING, FEEDBACK
}
var state: GameState = GameState.ANSWERING
@onready var panels: Dictionary = {
	GameState.ANSWERING: %AnswerPanel,
	GameState.CLASSIFYING: %ClassifyPanel,
	GameState.FEEDBACK: %FeedbackPanel,
}

const MAX_TIME := 45.0 # (s)
const MIN_TIME := 15.0 # (s)
const TIME_LOSS_PER_ROUND := 2.0
const TIME_GAIN_PER_DIFFICULTY := 2.0
var round_num: int = 0
var score: float = 0.0
var score_mult: float = 1.0
const MULT_STEP: float = 0.5
var pending_points: float = 0.0 # so we can apply multipliers AFTER classification step
var chosen_answer: String = ""
var run_over: bool = false

func _ready() -> void:
	LetterGrid.word_updated.connect(_on_word_updated)
	Reset.pressed.connect(_on_reset_pressed)
	Submit.pressed.connect(_on_submit_pressed)
	SpaceButton.pressed.connect(LetterGrid.add_space)
	NextButton.pressed.connect(_on_next_pressed)
	RoundTimer.timeout.connect(_on_round_timeout)
	TimeBar.max_value = 1.0
	TimeBar.show_percentage = false
	_build_classify_buttons()
	start_round()

func _process(_delta: float) -> void:
	if not RoundTimer.is_stopped():
		TimeBar.value = _time_fraction()
		TimeLeft.text = "Tempo restante: " + str(int(RoundTimer.time_left)) + "s"

#State machine
func _set_state(new_state: GameState) -> void:
	state = new_state
	for s in panels:
		panels[s].visible = (s == state)
	_focus_for_state(state)

# Round logic
func start_round(): #TODO: handle difficulty scaling 
	current_sentence = bank.get_random_sentence()
	chosen_answer = ""
	pending_points = 0.0
	Sentence.text = current_sentence.sentence
	_update_score_label()
	LetterGrid.generate_grid(current_sentence.get_main_answer())
	var round_time := _compute_round_time(current_sentence)
	round_num += 1
	RoundTimer.start(round_time)
	_set_state(GameState.ANSWERING)

func _on_submit_pressed() -> void:
	if state != GameState.ANSWERING:
		return
	var word: String = LetterGrid.get_current_word_clean()
	if not current_sentence.is_correct(word):
		print("Wrong answer!") # ending round only after timeout
		return
	chosen_answer = _denormalize_answer(word) 
	pending_points = calculate_score(chosen_answer)
	Sentence.text = _fill_blank(current_sentence.sentence, chosen_answer)
	_set_state(GameState.CLASSIFYING)

func _on_classification_chosen(type: int) -> void:
	if state != GameState.CLASSIFYING:
		return
	_resolve_round(type == current_sentence.classification)

func _resolve_round(success: bool):
	RoundTimer.stop()
	var clause := _clause_name(current_sentence.classification)
	if chosen_answer == "":  # e.g. timed out before a word was accepted
		chosen_answer = current_sentence.get_main_answer()
	Sentence.text = _fill_blank(current_sentence.sentence, chosen_answer)
	if success:
		score += pending_points
		score_mult += MULT_STEP
		FeedbackLabel.text = "Correto! Oração subordinada adverbial %s.\n+%d pontos" % [clause, int(pending_points)]
		NextButton.text = "Próxima"
	else:
		run_over = true
		FeedbackLabel.text = "Errado! A classificação correta era: %s.\nFim de jogo — pontuação final: %d" % [clause, int(score)]
		NextButton.text = "Jogar de novo"
	_update_score_label()
	_set_state(GameState.FEEDBACK)

#Score calc
func calculate_score(answer: String) -> float:
	var is_not_main := answer != current_sentence.get_main_answer()
	var base := answer.length() * current_sentence.difficulty * score_mult + (int(is_not_main) * 50)
	return base * lerpf(0.75, 2.0, _time_fraction())

# Helper functions
func _build_classify_buttons() -> void:
	for key in SentenceData.ClauseType.keys():
		var b := Button.new()
		b.text = key.capitalize()
		b.pressed.connect(_on_classification_chosen.bind(SentenceData.ClauseType[key]))
		ClassifyButtons.add_child(b)

func _focus_for_state(s: GameState):
	match s:
		GameState.ANSWERING:
			LetterGrid.focus_first_tile()
		GameState.CLASSIFYING:
			ClassifyButtons.get_child(0).grab_focus()
		GameState.FEEDBACK:
			NextButton.grab_focus()

func _denormalize_answer(word: String) -> String:
	var n := SentenceData._normalize(word)
	for a in current_sentence.answers:
		if SentenceData._normalize(a) == n:
			return a
	return word

func _fill_blank(sentence: String, word: String) -> String:
	return RegEx.create_from_string("_+").sub(sentence, word)

func _clause_name(type: int) -> String:
	return SentenceData.ClauseType.keys()[type].capitalize()

func _update_score_label() -> void:
	ScoreLabel.text = "Score: %d  (x%.1f)" % [int(score), score_mult]

func _compute_round_time(sentence: SentenceData) -> float:
	var base := maxf(MAX_TIME - round_num * TIME_LOSS_PER_ROUND, MIN_TIME)
	return base + (sentence.difficulty - 1) * TIME_GAIN_PER_DIFFICULTY

func _time_fraction() -> float:
	return RoundTimer.time_left / RoundTimer.wait_time

func _on_word_updated(word: String):
	WordLabel.text = word

func _on_reset_pressed():
	LetterGrid.clear_selection()

func _on_next_pressed():
	if state != GameState.FEEDBACK:
		return
	if run_over:
		round_num = 0
		score = 0.0
		score_mult = 1.0
		run_over = false
	start_round()

func _on_round_timeout():
	if state == GameState.FEEDBACK:
		return
	_resolve_round(false)
