extends Control

#region Константы
const IDLE_LIB: AnimationLibrary = preload("res://assets/animations/Idle.fbx")

const CAM_POS_NORMAL := Vector3(0.75, 1.7, 1.15)
const CAM_ROT_NORMAL := Vector3(-20.0, 45.0, 0.0)

const CAM_POS_CHOOSING := Vector3(2.3, 1.4, 2.4)
const CAM_ROT_CHOOSING := Vector3(-10.0, 45.0, 0.0)

const PANEL_WIDTH_NORMAL := 244.0
const PANEL_WIDTH_WIDE := 350.0

# Индексы специальных кнопок фона
const BG_INDEX_GRAY := 0
const BG_INDEX_CAMERA := 1
#endregion

#region Настройки инспектора и узлы
@export var character_models: Array[PackedScene] = []
# --- ФОНЫ: Массив на 6 элементов (0 - серый, 1..4 - glb сцены, 5 - камера) ---
@export var background_scenes: Array[PackedScene] = []

@onready var button_sound: AudioStreamPlayer = $ButtonPressedPlayer
@onready var panel: PanelContainer = $Background/PanelContainer

@onready var main_container: Control = $Background/PanelContainer/MarginContainer/MainContainer
@onready var main_buttons: Control = $Background/PanelContainer/MarginContainer/MainContainer/MainButtons
@onready var choose_buttons: Control = $Background/PanelContainer/MarginContainer/MainContainer/ChooseButtons

@onready var characters_grid: VBoxContainer = $Background/PanelContainer/MarginContainer/CharacterContainer
@onready var actual_cards_grid: GridContainer = $Background/PanelContainer/MarginContainer/CharacterContainer/CharacterGridContainer

@onready var backgrounds_grid: VBoxContainer = $Background/PanelContainer/MarginContainer/BackgroundContainer
# --- ФОНЫ: Проверьте, что имя GridContainer совпадает с вашим в дереве сцены ---
@onready var actual_bg_cards_grid: GridContainer = $Background/PanelContainer/MarginContainer/BackgroundContainer/BackgroundGridContainer

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var world_env: WorldEnvironment = $SubViewportContainer/SubViewport/WorldEnvironment
@onready var camera: Camera3D = $SubViewportContainer/SubViewport/WorldEnvironment/Camera3D
@onready var character_holder: Node3D = $SubViewportContainer/SubViewport/WorldEnvironment/CharacterHolder
# --- ФОНЫ: Контейнер для 3D-фонов ---
@onready var background_holder: Node3D = $SubViewportContainer/SubViewport/WorldEnvironment/BackgroundHolder
#endregion


func _ready() -> void:
	_setup_character_cards()
	_setup_background_cards()
	
	_spawn_character(0)
	_apply_background(BG_INDEX_GRAY)


#region Логика персонажей и анимаций
func _setup_character_cards() -> void:
	var cards := actual_cards_grid.get_children()
	for i in cards.size():
		if cards[i] is BaseButton:
			cards[i].pressed.connect(_on_character_selected.bind(i))


func _spawn_character(index: int) -> void:
	if index < 0 or index >= character_models.size() or not character_models[index]:
		push_warning("Для индекса %d не назначена 3D-модель в character_models." % index)
		return
		
	for child in character_holder.get_children():
		child.queue_free()
		
	var new_char := character_models[index].instantiate() as Node3D
	character_holder.add_child(new_char)
	_play_idle_animation(new_char)


func _play_idle_animation(character: Node3D) -> void:
	var anim_player := character.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if not anim_player:
		anim_player = AnimationPlayer.new()
		character.add_child(anim_player)
		
	anim_player.root_node = anim_player.get_path_to(character)
	
	if anim_player.has_animation_library("custom"):
		anim_player.remove_animation_library("custom")
	anim_player.add_animation_library("custom", IDLE_LIB)
	
	var anim_list := IDLE_LIB.get_animation_list()
	if not anim_list.is_empty():
		anim_player.play("custom/" + anim_list[0])
#endregion


#region Логика фонов
func _setup_background_cards() -> void:
	var cards := actual_bg_cards_grid.get_children()
	for i in cards.size():
		if cards[i] is BaseButton:
			var btn := cards[i] as BaseButton
			# Блокируем кнопку камеры на будущее
			if i == BG_INDEX_CAMERA:
				btn.disabled = true
				btn.tooltip_text = "Захват камеры (в разработке)"
			else:
				btn.pressed.connect(_on_background_selected.bind(i))


func _apply_background(index: int) -> void:
	# 1. Удаляем предыдущий 3D-фон
	for child in background_holder.get_children():
		child.queue_free()
		
	# 2. Сбрасываем прозрачность вьюпорта (понадобится в будущем для камеры)
	sub_viewport.transparent_bg = false
	
	# 3. Включаем нужный режим
	if index == BG_INDEX_GRAY:
		# Возвращаем стандартный серый цвет
		if world_env and world_env.environment:
			world_env.environment.background_mode = Environment.BG_COLOR
			world_env.environment.background_color = Color(0.3, 0.3, 0.3)
			
	elif index == BG_INDEX_CAMERA:
		# Заготовка под будущее: прозрачный фон вьюпорта, чтобы просвечивала картинка с камеры
		sub_viewport.transparent_bg = true
		
	else:
		# Загружаем одну из 4-х 3D-сцен (.glb)
		if index < 0 or index >= background_scenes.size() or not background_scenes[index]:
			push_warning("Для кнопки фона №%d не назначена 3D-сцена!" % index)
			return
			
		# Переключаем окружение на небо/освещение по умолчанию для 3D-локации
		if world_env and world_env.environment:
			world_env.environment.background_mode = Environment.BG_SKY
			if not world_env.environment.sky:
				var sky := Sky.new()
				sky.sky_material = ProceduralSkyMaterial.new()
				world_env.environment.sky = sky
				
		var new_bg := background_scenes[index].instantiate() as Node3D
		background_holder.add_child(new_bg)
#endregion


#region Анимация и навигация UI
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


func show_screen(target: Control) -> void:
	main_buttons.hide()
	choose_buttons.hide()
	target.show()
#endregion


#region Обработчики сигналов
func _on_character_selected(index: int) -> void:
	button_sound.play()
	_spawn_character(index)


func _on_background_selected(index: int) -> void:
	button_sound.play()
	_apply_background(index)


func _on_start_button_pressed() -> void:
	button_sound.play()
	show_screen(choose_buttons)


func _on_settings_button_pressed() -> void:
	button_sound.play()


func _on_about_button_pressed() -> void:
	button_sound.play()


func _on_exit_button_pressed() -> void:
	button_sound.play()
	await button_sound.finished
	get_tree().quit()


func _on_start_tracking_button_pressed() -> void:
	button_sound.play()


func _on_back_button_pressed() -> void:
	button_sound.play()
	show_screen(main_buttons)


func _on_character_button_pressed() -> void:
	button_sound.play()
	open_selection(true)


func _on_background_button_pressed() -> void:
	button_sound.play()
	open_selection(false)


func _on_characters_back_button_pressed() -> void:
	button_sound.play()
	close_selection()


func _on_backgrounds_back_button_pressed() -> void:
	button_sound.play()
	close_selection()
#endregion
