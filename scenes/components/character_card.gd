extends Button

signal card_selected(character_scene: PackedScene)

@export var character_name: String = "Персонаж"
@export var avatar_texture: Texture2D
@export var character_3d_scene: PackedScene

@onready var avatar_rect: TextureRect = $VBoxContainer/AvatarRect
@onready var name_label: Label = $VBoxContainer/NameLabel

func _ready() -> void:
	name_label.text = character_name
	if avatar_texture:
		avatar_rect.texture = avatar_texture


func _pressed() -> void:
	card_selected.emit(character_3d_scene)
