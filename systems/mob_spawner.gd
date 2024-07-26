class_name MobSpawner
extends Node2D

@export var creatures: Array[PackedScene]
@export var mobs_per_minute: float = 60.0
#var frequency_mob_lv1: float = 60.0
#var frequency_mob_lv2: float = 30.0
#var frequency_mob_lv3: float = 5.0

@onready var path_follow_2d: PathFollow2D = %PathFollow2D

var cooldown: float = 0.0

func _process(delta: float):
	if GameManager.is_game_over: return
	
	#temporizador
	cooldown -= delta
	if cooldown > 0:
		return

	# gerando criatura aleatória
	var creature_selected: int = randi_range(0, creatures.size() - 1)
	
	# Intervalo
	var interval
	interval = 60.0 / mobs_per_minute
	#if creature_selected == 0:
		#interval = 60.0 / frequency_mob_lv1
	#elif creature_selected == 1:
		#interval = 60.0 / frequency_mob_lv2
	#elif creature_selected == 2:
		#interval = 60.0 / frequency_mob_lv3
	print('Spawned creature level ', creature_selected + 1)
	cooldown = interval

	# Checar se o ponto é válido...
	var point = get_point()
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	parameters.collision_mask = 0b1000
	var max_results = 1
	var result: Array = world_state.intersect_point(parameters, max_results)
	if not result.is_empty(): return
	
	var creature_scene = creatures[creature_selected]
	var creature = creature_scene.instantiate()
	creature.global_position = get_point()
	get_parent().add_child(creature)

func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.position

