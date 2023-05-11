extends Node3D

@onready var joystick = $UI/Joystick
@onready var isometric_character: CharacterBody3D = $IsometricCharacter

func _ready() -> void:
	#isometric_character.input.connect(press_buttons)
	isometric_character.interact.connect(interact)

func interact(area: Area3D) -> void:
	# Show UI interact button
	print(area)
