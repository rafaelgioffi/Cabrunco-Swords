extends Node2D

@export var creatures: Array[PackedScene]
@export var frequency_mob_lv1: float = 60
@export var frequency_mob_lv2: float = 30
@export var frequency_mob_lv3: float = 5

@onready var path_follow_2d: PathFollow2D = %PathFollow2D

var cooldown: float = 0

func _process(delta: float):
	#temporizador
	cooldown -= delta
	if cooldown > 0:
		return

	# gerando criatura aleatória
	var creature_selected: int = randi_range(0, creatures.size() - 1)
	
	# Intervalo
	var interval
	if creature_selected == 0:
		interval = 60 / frequency_mob_lv1
	elif creature_selected == 1:
		interval = 60 / frequency_mob_lv2
	elif creature_selected == 2:
		interval = 60 / frequency_mob_lv3
	print('Spawned creature level ', creature_selected + 1)
	cooldown = interval

	var creature_scene = creatures[creature_selected]
	var creature = creature_scene.instantiate()
	creature.global_position = get_point()
	get_parent().add_child(creature)

func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.position

