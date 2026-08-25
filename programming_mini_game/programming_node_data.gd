class_name ProgrammingNodeData
extends Resource

@export var id: String = ""
@export var title: String = ""

# Where this block STARTS in the puzzle.
# This lets you scatter blocks differently per level.
@export var start_position: Vector2 = Vector2.ZERO

# Examples:
# ["blue"]
# ["blue", "green"]
# ["purple", "yellow"]
@export var input_colors: Array[String] = []
@export var output_colors: Array[String] = []
