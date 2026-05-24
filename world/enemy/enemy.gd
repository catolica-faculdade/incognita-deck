extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("enemies")

func lock():
	print("LOCKED")

func unlock():
	print("UNLOCKED")
