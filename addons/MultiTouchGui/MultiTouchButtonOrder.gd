extends Button
class_name MultiTouchButtonOrder
 
signal multitouch_pressed
 
@export var icon_normal: Texture
@export var icon_pressed: Texture
 
 
func _ready():
	var main_game = get_node_or_null("/root/Panel/TaskManager")
	main_game.order_minigame_selected.connect(update_icon_state)
	
	icon = icon_normal
	update_icon_state()
 
func _gui_input(event):
	var event_pos_adjusted = event.position + global_position
	var inside = event_pos_adjusted.x > position.x and event_pos_adjusted.y > position.y and event_pos_adjusted.x < position.x + size.x and event_pos_adjusted.y < position.y + size.y
 
	if event is InputEventScreenTouch and event.pressed and event.index != 0:
		icon = icon_pressed if icon == icon_normal else icon_normal
		if toggle_mode:
			toggled.emit()
		else:
			multitouch_pressed.emit()
			button_down.emit()
 
	elif (event is InputEventScreenTouch and inside) or (event is InputEventScreenTouch and !event.pressed and !inside):
		button_up.emit()
		button_pressed = false
 
func update_icon_state():
	icon = icon_pressed if Global.reactorState == "Allumé" else icon_normal
