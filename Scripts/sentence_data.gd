class_name SentenceData
extends Resource

enum ClauseType {
	CAUSAL, CONCESSIVA, CONDICIONAL, CONSECUTIVA, COMPARATIVA,
	CONFORMATIVA, FINAL, PROPORCIONAL, TEMPORAL
}

@export_multiline var sentence: String = ""
@export var answers: Array[String] = []
@export var classification: ClauseType = ClauseType.CAUSAL
# @export_multiline var explanation: String = ""
@export_range(1, 5) var difficulty: int = 1

func get_main_answer() -> String:
	return answers[0] if answers.size() > 0 else ""

func is_correct(word: String):
	for answer in answers:
		if _normalize(answer) == _normalize(word):
			return true
	return false

static func _normalize(word: String):
	const TRANSLATABLE := "ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ"
	const TRANSLATED := "AAAAAEEEEIIIIOOOOOUUUUÇ"
	var result := word.to_upper()
	for i in TRANSLATABLE.length():
		result = result.replace(TRANSLATABLE[i], TRANSLATED[i])
	return result
