class_name TeamMember
extends Resource

@export var id: String
@export var display_name: String
@export var role_name: String
@export var blurb: String
@export var profile_picture: Texture2D

@export var claimed_progress: float = 0.0
@export var actual_complete: bool = false
