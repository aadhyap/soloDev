class_name GameRole
extends Resource

@export var id: String
@export var display_name: String
@export var assigned_member: TeamMember
@export var required_roles: Array[GameRole] = []

var complete := false
