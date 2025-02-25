extends Sprite2D

@onready var task_description_label = $TaskDescription
@onready var task_manager = $"../TaskManager"
@onready var light_tv = $LightTV

var accumulated_time = 0.0
var next_change_time = 0.0

func _ready():
	task_manager.new_task_started.connect(_on_new_task_started)
	set_process(true)
	_generate_next_change_time()

func _on_new_task_started(description: String):
	task_description_label.text = description

func _process(delta):
	accumulated_time += delta
	if accumulated_time >= next_change_time:
		accumulated_time = 0.0  
		_generate_next_change_time()  
		light_tv.energy = randf_range(4,5)  

func _generate_next_change_time():
	# Générer un intervalle aléatoire entre 0.1 et 0.2 seconde
	next_change_time = randf_range(0.1, 0.2)
