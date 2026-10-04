@tool
extends EditorScript

const JSON_PATH := "res://Data/sentences.json"
const BANK_PATH := "res://Data/answer_key.tres"
const GRID_SIZE := 16 # keep in sync with LetterGrid

func _run() -> void:
	var entries := _load_json(JSON_PATH)
	if entries.is_empty():
		return

	var built: Array[SentenceData] = []
	var error_count := 0

	for i in entries.size():
		var errors := _validate(entries[i])
		if errors.is_empty():
			built.append(_build(entries[i]))
		else:
			error_count += 1
			for e in errors:
				push_error("Entry %d: %s" % [i, e])

	if error_count > 0:
		push_error("Import aborted: %d invalid entries. Bank not modified." % error_count)
		return

	var bank: SentenceBank = load(BANK_PATH)
	bank.sentences.assign(built)
	var err := ResourceSaver.save(bank, BANK_PATH)
	if err != OK:
		push_error("Failed to save bank (error %d)" % err)
		return

	EditorInterface.get_resource_filesystem().scan()
	print("Imported %d sentences into %s" % [built.size(), BANK_PATH])


func _load_json(path: String) -> Array:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Can't open %s" % path)
		return []
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed == null or not parsed is Array:
		push_error("%s must contain a JSON array" % path)
		return []
	return parsed


func _validate(d: Variant) -> Array[String]:
	var errors: Array[String] = []
	if not d is Dictionary:
		errors.append("not an object")
		return errors

	if not (d.get("sentence") is String) or not "__" in d["sentence"]:
		errors.append("'sentence' missing or has no blank (__)")

	var answers = d.get("answers")
	if not answers is Array or answers.is_empty():
		errors.append("'answers' must be a non-empty array")
	else:
		for a in answers:
			if not a is String:
				errors.append("answer %s is not a string" % str(a))
			elif _letter_count(a) > GRID_SIZE:
				errors.append("answer '%s' doesn't fit the grid" % a)

	if not d.get("classification") in SentenceData.ClauseType.keys():
		errors.append("invalid 'classification': %s" % str(d.get("classification")))

	var diff = d.get("difficulty", 1)
	if not (diff is float or diff is int) or diff < 1 or diff > 5:
		errors.append("'difficulty' must be 1-5")

	return errors


func _build(d: Dictionary) -> SentenceData:
	var s := SentenceData.new()
	s.sentence = d["sentence"]
	s.answers.assign(d["answers"])
	s.classification = SentenceData.ClauseType[d["classification"]]
	s.difficulty = int(d.get("difficulty", 1))
	return s


func _letter_count(word: String) -> int:
	return SentenceData._normalize(word).replace(" ", "").length()
