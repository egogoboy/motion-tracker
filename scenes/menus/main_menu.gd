extends Control

@onready var main_container: Control = $Background/PanelContainer/MarginContainer/MainContainer
@onready var main_buttons: Control = $Background/PanelContainer/MarginContainer/MainContainer/MainButtons
@onready var choose_buttons: Control = $Background/PanelContainer/MarginContainer/MainContainer/ChooseButtons

@onready var panel: PanelContainer = $Background/PanelContainer
@onready var camera: Camera3D = $SubViewportContainer/SubViewport/WorldEnvironment/Camera3D
@onready var characters_grid: VBoxContainer = $Background/PanelContainer/MarginContainer/CharacterContainer
@onready var backgrounds_grid: VBoxContainer = $Background/PanelContainer/MarginContainer/BackgroundContainer

@onready var actual_cards_grid: GridContainer = $Background/PanelContainer/MarginContainer/CharacterContainer/CharacterGridContainer
@onready var character_holder: Node3D = $SubViewportContainer/SubViewport/WorldEnvironment/CharacterHolder

@export var character_models: Array[PackedScene] = []

const IDLE_LIB: AnimationLibrary = preload("res://assets/animations/Idle.fbx")

const CAM_POS_NORMAL := Vector3(0.75, 1.7, 1.15)
const CAM_ROT_NORMAL := Vector3(-20.0, 45.0, 0.0)

const CAM_POS_CHOOSING := Vector3(2.3, 1.4, 2.4)
const CAM_ROT_CHOOSING := Vector3(-10.0, 45.0, 0.0)

const PANEL_WIDTH_NORMAL := 244.0
const PANEL_WIDTH_WIDE := 350.0


func _ready() -> void:
	var cards := actual_cards_grid.get_children()
	for i in cards.size():
		if cards[i] is BaseButton:
			cards[i].pressed.connect(_on_character_selected.bind(i))
			
	var new_char := character_models[0].instantiate()
	character_holder.add_child(new_char)
	
	play_animation(new_char)
	

func play_animation(new_char: Node3D) -> void:
	var anim_player := new_char.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if not anim_player:
		anim_player = AnimationPlayer.new()
		new_char.add_child(anim_player)
		
	anim_player.root_node = anim_player.get_path_to(new_char)
	
	# 2. Добавляем загруженную библиотеку напрямую
	if anim_player.has_animation_library("custom"):
		anim_player.remove_animation_library("custom")
	anim_player.add_animation_library("custom", IDLE_LIB)
	
	# 3. Запускаем первую анимацию из этой библиотеки (обычно она называется "mixamo_com" или так, как вы её переименовали при импорте)
	var anim_name := IDLE_LIB.get_animation_list()[0]
	anim_player.play("custom/" + anim_name)	


func open_selection(is_character_mode: bool) -> void:
	main_container.hide()
	
	var active_grid := characters_grid if is_character_mode else backgrounds_grid
	characters_grid.hide()
	backgrounds_grid.hide()
	
	active_grid.modulate.a = 0.0
	active_grid.show()
	
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "custom_minimum_size:x", PANEL_WIDTH_WIDE, 0.4)
	tween.tween_property(camera, "position", CAM_POS_CHOOSING, 0.45)
	tween.tween_property(camera, "rotation_degrees", CAM_ROT_CHOOSING, 0.45)
	tween.tween_property(active_grid, "modulate:a", 1.0, 0.3).set_delay(0.15)


func close_selection() -> void:
	var active_grid := characters_grid if characters_grid.visible else backgrounds_grid
	
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(active_grid, "modulate:a", 0.0, 0.15)
	tween.tween_property(panel, "custom_minimum_size:x", PANEL_WIDTH_NORMAL, 0.4)
	tween.tween_property(camera, "position", CAM_POS_NORMAL, 0.45)
	tween.tween_property(camera, "rotation_degrees", CAM_ROT_NORMAL, 0.45)
	
	tween.chain().tween_callback(func():
		characters_grid.hide()
		backgrounds_grid.hide()
		choose_buttons.show()
	)
	
	main_container.show()


func print_tre(node: Node, indent: int = 0) -> void:
	print(" ".repeat(indent) + node.name + " [" + node.get_class() + "]")

	for child in node.get_children():
		print_tre(child, indent + 2)


func _on_character_selected(index: int) -> void:
	$ButtonPressedPlayer.play()
	
	if index < 0 or index >= character_models.size() or not character_models[index]:
		print("Для кнопки №", index, " не назначена 3D-модель в массиве character_models!")
		return
		
	# 1. Удаляем старую модель из CharacterHolder
	for child in character_holder.get_children():
		child.queue_free()
		
	# 2. Создаём новую модель по индексу кнопки
	var new_char := character_models[index].instantiate()
	character_holder.add_child(new_char)
	
	play_animation(new_char)


func show_screen(target: Control) -> void:
	main_buttons.hide()
	choose_buttons.hide()
	target.show()


func _on_start_button_pressed() -> void:
	$ButtonPressedPlayer.play()
	show_screen(choose_buttons)


func _on_settings_button_pressed() -> void:
	$ButtonPressedPlayer.play()


func _on_about_button_pressed() -> void:
	$ButtonPressedPlayer.play()


func _on_exit_button_pressed() -> void:
	$ButtonPressedPlayer.play()
	await $ButtonPressedPlayer.finished
	get_tree().quit()


func _on_start_tracking_button_pressed() -> void:
	$ButtonPressedPlayer.play()


func _on_back_button_pressed() -> void:
	$ButtonPressedPlayer.play()
	show_screen(main_buttons)


func _on_character_button_pressed() -> void:
	$ButtonPressedPlayer.play()
	open_selection(true)


func _on_background_button_pressed() -> void:
	$ButtonPressedPlayer.play()
	open_selection(false)


func _on_characters_back_button_pressed() -> void:
	$ButtonPressedPlayer.play()
	close_selection()


func _on_backgrounds_back_button_pressed() -> void:
	$ButtonPressedPlayer.play()
	close_selection()
