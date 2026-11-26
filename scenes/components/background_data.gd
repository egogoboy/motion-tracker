class_name BackgroundData
extends Resource

enum BgType {
	DEFAULT_GRAY, # Текущий серый фон
	SCENE_3D,     # Готовая 3D-сцена (комната, улица)
	PANORAMA,     # 360° HDRI-картинка
	CAMERA_FEED   # Захват камеры (на будущее)
}

@export var title: String = "Новый фон"
@export var icon: Texture2D # Превью для кнопки в меню
@export var type: BgType = BgType.DEFAULT_GRAY

# Заполняется только для SCENE_3D
@export var scene_3d: PackedScene 

# Заполняется только для PANORAMA
@export var panorama_texture: Texture2D 
