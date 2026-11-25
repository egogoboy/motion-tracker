extends Control

@onready var main_buttons: Control = $Background/PanelContainer/MarginContainer/MainContainer/MainButtons
@onready var choose_buttons: Control = $Background/PanelContainer/MarginContainer/MainContainer/ChooseButtons

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
	get_tree().quit()


func _on_back_button_pressed() -> void:
	$ButtonPressedPlayer.play()
	show_screen(main_buttons)
