# programming_task_data.gd
class_name ProgrammingTaskData
extends Resource

# All blocks that exist in this level
@export var nodes: Array[ProgrammingNodeData] = []

# The wiring that makes this level correct
@export var correct_connections: Array[ProgrammingConnectionData] = []
