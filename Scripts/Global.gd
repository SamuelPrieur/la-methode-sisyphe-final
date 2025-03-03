extends Node

var player_number = 1

var score: int = 0
var level: int = 6
var lightState: String = "Hold"
var current_task: Dictionary
var last_completed_task: String
var error_counter: int = 0

var reactorState = "Éteint"
var ventilateur = "off"


var leader_board = {}

func add_score(player_name: String, score: int) -> void:
	leader_board[player_name] = score
	_sort_leaderboard()

#Global.add_score("Samuel", 1500)
#Global.add_score("Alex", 1800)


func _sort_leaderboard() -> void:
	var sorted_entries = leader_board.keys()
	sorted_entries.sort_custom(func(a, b): return leader_board[a] > leader_board[b])
	
	var new_leader_board = {}
	for key in sorted_entries:
		new_leader_board[key] = leader_board[key]
	
	leader_board = new_leader_board
	save_leaderboard()
	

func get_sorted_leaderboard() -> Array:
	var sorted_entries = []
	for key in leader_board.keys():
		sorted_entries.append([key, leader_board[key]])
	
	sorted_entries.sort_custom(func(a, b): return a[1] > b[1])
	return sorted_entries

func save_leaderboard():
	var file = FileAccess.open("res://leaderboard.save", FileAccess.WRITE)
	file.store_var(leader_board)
	file.close()

func load_leaderboard():
	if FileAccess.file_exists("res://leaderboard.save"):
		var file = FileAccess.open("res://leaderboard.save", FileAccess.READ)
		leader_board = file.get_var()
		file.close()
		_sort_leaderboard()
