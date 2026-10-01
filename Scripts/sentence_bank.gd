class_name SentenceBank
extends Resource

@export var sentences: Array[SentenceData] = []

func get_random_sentence(max_difficulty: int = 5) -> SentenceData:
	var pool := sentences.filter(func(s): return s.difficulty <= max_difficulty)
	return pool.pick_random() if pool.size() > 0 else null
