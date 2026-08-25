class_name ArtTaskData
extends Resource

@export var grid_width: int = 5
@export var grid_height: int = 5

# Write the drawing visually using 0 and 1
@export_multiline var pattern: String = """
01010
11111
11111
01110
00100
"""
