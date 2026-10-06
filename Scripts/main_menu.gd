extends Control

@onready var Start: Button = %Start
@onready var HowToPlay: Button = %HowToPlay
@onready var HowToPlayText: Label = %HowToPlayText
var Board: PackedScene = preload("res://Scenes/board.tscn")

func _ready() -> void:
	Start.pressed.connect(_on_start_pressed)
	HowToPlay.pressed.connect(_on_how_to_play_pressed)
	HowToPlayText.visible = false

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(Board)

func _on_how_to_play_pressed() -> void:
	HowToPlayText.visible = not HowToPlayText.visible
