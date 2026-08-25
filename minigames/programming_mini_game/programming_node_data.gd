class_name ProgrammingNodeData
extends Resource

@export var id: String = ""
@export var title: String = ""
@export var start_position: Vector2 = Vector2.ZERO

@export var inputs: Array[ProgrammingPortData] = []
@export var outputs: Array[ProgrammingPortData] = []
