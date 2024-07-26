class_name Enemy
extends Node2D

@export_category("Life")
@export var health: int = 10
@export var death_prefab: PackedScene
@export var level: int = 1
var damage_digit_prefab: PackedScene

#@onready var healthbar: ProgressBar = $HealthBar
#@onready var enemyHud: Label = $EnemyHUD
@onready var damage_digit_marker = $"DamageDigitMarker"

@export_category("Drops")
@export var drop_chance: float = 0.05
@export var drop_items: Array[PackedScene]
@export var drop_chances: Array[float]

func _ready():
	damage_digit_prefab = preload("res://misc/damage_digit.tscn")
	#healthbar.value = health
	#enemyHud.text = str(health)
	
func damage(amount: float):
	health -= amount
	print("Enemy received ", amount, " damage hit. Total health: ", health)
	#healthbar.value = health
	#enemyHud.text = str(health)
	
	# Piscar o inimigo ao receber dano...
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

	# Knockback do enemy...
	if GameManager.flip_player == 0:
		global_position.x += 30
	elif GameManager.flip_player == 1:
		global_position.x -= 30
	
	# Criar Damage
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
	get_parent().add_child(damage_digit)
	
	if health <= 0:
		die()

func die():
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	#Drop
	if (randf() <= drop_chance):
		drop_item()
	queue_free()
	
	# Incrementar contador de inimigos mortos...
	GameManager.monsters_defeated_counter += 1

func drop_item():
	var drop = get_random_drop_item().instantiate()
	drop.position = position
	get_parent().add_child(drop)

func get_random_drop_item() -> PackedScene:
	if drop_items.size() == 1:
		return drop_items[0]
	#Calcular chance máxima
	var max_chance: float = 0.0
	for drop_chance in drop_chances:
		max_chance += drop_chance
	#Jogar dado...
	var random_value = randf() * max_chance
	var needle: float = 0.0
	for drop in drop_items.size():
		var drop_item = drop_items[drop]
		var drop_chance = drop_chances[drop] if drop < drop_chances.size() else 1
		if random_value <= drop_chance + needle: 
			return drop_item
		needle += drop_chance
	
	return drop_items[0]
