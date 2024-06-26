class_name Enemy
extends Node2D

@export var health: int = 10
@export var death_prefab: PackedScene
@export var level: int = 1

@onready var healthbar: ProgressBar = $HealthBar
@onready var enemyHud: Label = $EnemyHUD

func _ready():
	healthbar.value = health
	enemyHud.text = str(health)
	
func damage(amount: float):
	health -= amount
	print("Enemy received ", amount, " damage hit. Total health: ", health)
	healthbar.value = health
	enemyHud.text = str(health)
	
	# Piscar o inimigo ao receber dano...
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	if health <= 0:
		die()

func die():
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	queue_free()
