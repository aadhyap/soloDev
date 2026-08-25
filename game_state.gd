extends Node

var team_members: Array[TeamMember] = [
	preload("res://membersData/drippzy.tres"),
	preload("res://membersData/risa.tres"),
	preload("res://membersData/rimbo.tres"),
	preload("res://membersData/jamal.tres")
]

var tasks: Array[GameTask] = [
	preload("res://gameTasks/drawing1.tres"),
	preload("res://gameTasks/drawing2.tres"),
	preload("res://gameTasks/writing1.tres"),
	preload("res://gameTasks/writing2.tres"),
	preload("res://gameTasks/programming1.tres")
]

var current_task: GameTask = null
var last_helped_member_id: String = ""


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
