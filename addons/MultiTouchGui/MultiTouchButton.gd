extends Button
class_name MultiTouchButton
@export var icon_normal: Texture
@export var icon_pressed: Texture
func _ready():
	if icon_normal and not icon:
		icon = icon_normal
		
func _gui_input(event):
	if event is InputEventScreenTouch and event.pressed:
		icon = icon_pressed
		if not toggle_mode:
			toggled.emit()
			button_pressed = true
	else:
		icon = icon_normal
