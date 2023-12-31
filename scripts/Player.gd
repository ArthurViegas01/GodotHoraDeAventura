extends KinematicBody2D

onready var animation: AnimationPlayer = get_node("Animation")
onready var sprite: Sprite = get_node("Sprite")

var velocity: Vector2

var enemy_inattack_range = false
var enemy_attack_cooldown = true

var health = 100
var player_alive = true

var attack_ip = false

export (int) var speed = 120


func _physics_process(_delta: float) -> void:
	
	verify_direction()
	attack()
	animate()
	enemy_attack()
	update_health()
	
	
	if health <= 0:
		player_alive = false
		health = 0
	else:
		move()

func _ready():
	Global.player = self


func move() -> void:
	var direction_vector: Vector2 = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	velocity = direction_vector * speed

	velocity = move_and_slide(velocity)

func animate() -> void:
	if attack_ip:
		return
		
		
	if not player_alive:
		if animation.current_animation != "Death":
			animation.play("Death")
			yield(get_tree().create_timer(0.8), "timeout")
			self.queue_free()
		return
	else:
		if velocity != Vector2.ZERO:
			animation.play("Run")
		else:
			animation.play("Idle")
		


func verify_direction() -> void:
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true


func player():
	pass


func _on_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_inattack_range = true


func _on_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemy_inattack_range = false

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true:
		health = health - 5
		enemy_attack_cooldown = false
		$AttackCooldown.start()


func _on_AttackCooldown_timeout():
	enemy_attack_cooldown = true


func attack():
	if Input.is_action_just_pressed("attack"):
		Global.player_currently_attacking = true
		attack_ip = true
		animation.play("Attack")
		$deal_attack_timer.start()


func _on_deal_attack_timer_timeout():
	$deal_attack_timer.stop()
	Global.player_currently_attacking = false
	attack_ip = false
	
	
	
func update_health():
	var healthbar = $Healthbar
	healthbar.max_value = 100
	healthbar.value = health
	
	
func add_experience(amount):
	var xpbar = $ExperienceBar
	xpbar.value += amount
	if xpbar.value >= 40:
		speed = 240
		
	if xpbar.value >= 30:
		$deal_attack_timer.wait_time = 0
	


func _on_regen_timer_timeout():
	if health < 100:
		health = health + 10
		if health > 100:
			health = 100
	if health <= 0:
		health = 0
