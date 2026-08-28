extends Node

var team_members: Array[TeamMember] = [
	preload("res://membersData/drippzy.tres"),
	preload("res://membersData/rizza.tres"),
	preload("res://membersData/rimbo.tres"),
	preload("res://membersData/jamal.tres")
]

var tasks: Array[GameTask] = [

	preload("res://gameTasks/drawing1.tres"),
	preload("res://gameTasks/drawing2.tres"),
	preload("res://gameTasks/drawing3.tres"),
	preload("res://gameTasks/writing1.tres"),
	preload("res://gameTasks/writing2.tres"),
	preload("res://gameTasks/writing3.tres"),
	preload("res://gameTasks/writing4.tres"),
	preload("res://gameTasks/programming1.tres"),
	preload("res://gameTasks/programming2.tres"),
	preload("res://gameTasks/programmingA.tres")
]

var current_task: GameTask = null
var last_helped_member_id: String = ""
var pending_dialogue: String = ""
var seen_dialogues: Dictionary = {}


func has_seen_dialogue(dialogue_id: String) -> bool:
	return seen_dialogues.get(dialogue_id, false)


func mark_dialogue_seen(dialogue_id: String) -> void:
	seen_dialogues[dialogue_id] = true


func get_next_task_for_member(member_id: String) -> GameTask:
	for task in tasks:
		if task.assigned_member_id == member_id and not task.complete:
			return task

	return null


func get_remaining_task_count() -> int:
	var count := 0

	for task in tasks:
		if not task.complete:
			count += 1

	return count

func get_member_progress(member_id: String) -> float:
	var total_tasks := 0
	var completed_tasks := 0

	for task in tasks:
		if task.assigned_member_id == member_id:
			total_tasks += 1

			if task.complete:
				completed_tasks += 1

	if total_tasks == 0:
		return 0.0

	return (
		float(completed_tasks)
		/ float(total_tasks)
	) * 100.0


func can_help_member(member_id: String) -> bool:
	# Near the end, don't trap the player if only one person has work left.
	if get_remaining_task_count() <= 3:
		return true

	return member_id != last_helped_member_id


func complete_current_task():
	if current_task == null:
		return

	current_task.complete = true
	current_task.progress = 100.0

	last_helped_member_id = current_task.assigned_member_id
