class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 3
@export_category("Sword")
@export var sword_damage: int = 2
@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval_min: float = 15
@export var ritual_interval_max: float = 60
@export var ritual_scene: PackedScene
@export_category("Life")
@export var health: int = 100
@export var max_health: int = 100
@export var death_prefab: PackedScene

@onready var sprite: Sprite2D = $Sprite2D
#@onready var sprite: Sprite2D = $Sprite2D2
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea

@onready var damage_hud: Label = $"DamageHUD"
@onready var player_hud: Label = $"PlayerHUD"
@onready var healthbar: ProgressBar = $"HealthBar"

var input_vector: Vector2 = Vector2(0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0

func _process(delta: float) -> void:
	GameManager.player_position = position
	ready_input()

	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"):
		attack()

	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()

	update_hitbox_detection(delta)

	update_ritual(delta)

func _physics_process(delta: float) -> void:
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05)
	move_and_slide()

func update_attack_cooldown(delta: float) -> void:
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")

func ready_input() -> void:
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var deadzone = 0.15
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0

	was_running = is_running
	is_running = not input_vector.is_zero_approx()

func play_run_idle_animation() -> void:
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")
			
			healthbar.value = health
			player_hud.text = str(health)
			damage_hud.text = ""

func rotate_sprite() -> void:
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true

func attack() -> void:
	if is_attacking:
		return

	var atk = randi_range(0, 1)
	if atk == 0:
		animation_player.play("attack_side_1")
	elif atk == 1:
		animation_player.play("attack_side_2")

	attack_cooldown = 0.6
	is_attacking = true

func deal_damage_to_enemies():
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.3:
				var damage_str = str(sword_damage)
				#print("Dot: ", dot_product)
				damage_hud.text = "%s hit" % str(sword_damage)
				enemy.damage(sword_damage)

func update_hitbox_detection(delta: float):
	#temporizador...
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0:
		return

	hitbox_cooldown = 0.5
	
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)

func damage(amount: int):
	if health <= 0:
		return
		
	health -= amount
	print("Player received ", amount, " damage hit. Total health: ", health)
	healthbar.value = health
	player_hud.text = str(health)
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

func heal(amount: int) -> int:
	health += amount
	print("Player healed! Life now is ", health)
	if health >= max_health:
		health = max_health
		print("Player already have max life!")
	return health

func update_ritual(delta: float):
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	ritual_cooldown = randf_range(ritual_interval_min, ritual_interval_max)
	
	# Criar o tirual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)

