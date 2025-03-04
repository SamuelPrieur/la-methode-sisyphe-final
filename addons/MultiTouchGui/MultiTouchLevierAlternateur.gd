extends Button
class_name MultiTouchLevierAlternateur
 
signal multitouch_pressed
 
@export var icon_normal: Texture
@export var icon_pressed: Texture

func _ready():
	if icon_normal and not icon:
		icon = icon_normal


func _gui_input(event):
	var event_pos_adjusted = event.position + global_position
	var inside = event_pos_adjusted.x > position.x and event_pos_adjusted.y > position.y and event_pos_adjusted.x < position.x + size.x and event_pos_adjusted.y < position.y + size.y
	if event is InputEventScreenTouch and event.pressed and event.index!=0:
		
		if toggle_mode:
			toggled.emit()
			button_pressed = true
		else:
			multitouch_pressed.emit()
			button_down.emit()
			print(Global.alternateur)
			if Global.alternateur == "on":
				Global.alternateur = "off"
				icon = icon_normal
			else:
				Global.alternateur = "on"
				icon = icon_pressed


	elif (event is InputEventScreenTouch and inside) or (event is InputEventScreenTouch and !event.pressed and !inside):
		button_up.emit()
		button_pressed = false
