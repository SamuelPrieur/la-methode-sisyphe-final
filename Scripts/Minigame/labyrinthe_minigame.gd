extends Node2D

const WALL = 1
const PATH = 0
const START = 2
const END = 3

# Taille fixe pour tous les niveaux
const MAZE_SIZE = Vector2(5, 5)

var player: ColorRect
var current_level = 0
var tile_size = 64  
var player_pos = Vector2.ZERO 

# Définition des 3 niveaux
var levels = [
	{
		"layout": [
			[2,0,0,0,0],
			[1,1,1,1,0],
			[0,0,0,1,0],
			[0,1,0,1,0],
			[3,1,0,0,0],
		]
	},
	{
		"layout": [
			[2,1,1,1,1],
			[0,1,0,0,0],
			[0,1,0,1,0],
			[0,0,0,1,0],
			[1,1,1,3,0],
		]
	},
	{
		"layout": [
			[2,0,0,0,1],
			[1,1,1,0,1],
			[1,0,0,0,1],
			[1,0,1,1,3],
			[1,0,0,0,0],
		]
	}
]

func _ready():
	generate_current_level()

func find_start_position():
	var level_data = levels[current_level].layout
	for y in range(MAZE_SIZE.y):
		for x in range(MAZE_SIZE.x):
			if level_data[y][x] == START:
				return Vector2(x, y)
	return Vector2(1, 1)  

func generate_current_level():
	for child in get_children():
		child.queue_free()
	
	var level_data = levels[current_level].layout
	
	player_pos = find_start_position()
	
	for y in range(MAZE_SIZE.y):
		for x in range(MAZE_SIZE.x):
			var cell = level_data[y][x]
			var rect = ColorRect.new()
			rect.size = Vector2(tile_size, tile_size)
			rect.position = Vector2(x * tile_size, y * tile_size)
			
			match cell:
				WALL:
					rect.color = Color.DARK_GRAY
				PATH:
					rect.color = Color.WHITE
				START:
					rect.color = Color.GREEN
				END:
					rect.color = Color.YELLOW
			
			add_child(rect)
	
	# Créer le joueur
	player = ColorRect.new()
	player.size = Vector2(tile_size * 0.5, tile_size * 0.5)
	player.position = Vector2(player_pos.x * tile_size + tile_size * 0.25, 
							player_pos.y * tile_size + tile_size * 0.25)
	player.color = Color.RED
	player.name = "player"
	add_child(player)

func _input(event):
	if event is InputEventKey and event.pressed:
		var new_pos = player_pos
		
		match event.keycode:
			KEY_UP:
				new_pos.y -= 1
			KEY_DOWN:
				new_pos.y += 1
			KEY_LEFT:
				new_pos.x -= 1
			KEY_RIGHT:
				new_pos.x += 1
		
		# Vérifier si le mouvement est valide
		if is_valid_move(new_pos):
			player_pos = new_pos
			player.position = Vector2(player_pos.x * tile_size + tile_size * 0.25,
									player_pos.y * tile_size + tile_size * 0.25)
			
			# Vérifier si le joueur a atteint l'arrivée
			check_win_condition()

func is_valid_move(pos):
	var level_data = levels[current_level].layout
	
	# Vérifier si la position est dans les limites
	if pos.x < 0 or pos.x >= MAZE_SIZE.x or pos.y < 0 or pos.y >= MAZE_SIZE.y:
		return false
	
	# Vérifier si la cellule n'est pas un mur
	return level_data[pos.y][pos.x] != WALL

func check_win_condition():
	var level_data = levels[current_level].layout
	if level_data[player_pos.y][player_pos.x] == END:
		print("Niveau terminé!")
		# Attendre un peu avant de passer au niveau suivant
		next_level()

func next_level():
	if current_level < levels.size() - 1:
		current_level += 1
		generate_current_level()
	else:
		print("Félicitations! Vous avez terminé tous les niveaux!")
