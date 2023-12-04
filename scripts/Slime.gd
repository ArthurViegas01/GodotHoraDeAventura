extends KinematicBody2D

onready var animation: AnimationPlayer = get_node("Animation")
onready var sprite: Sprite = get_node("Sprite")


var health = 100
var player_inattack_zone = false
var can_take_damage = true

var player_ref = null
var velocity: Vector2

var is_dying = false

export(int) var speed

func _physics_process(_delta: float) -> void:
	move()
	animate()
	verify_direction()
	deal_with_damage()
	update_health()




func move() -> void:
	if player_ref != null:
		var distance: Vector2 = player_ref.global_position - global_position
		var direction: Vector2 = distance.normalized()
		var distance_length: float = distance.length()
		
		if distance_length <= 5:
			velocity = Vector2.ZERO
		else:
			velocity = speed * direction
	else:
		velocity = Vector2.ZERO
	velocity = move_and_slide(velocity)


func animate() -> void:
	if is_dying:
		return
	if velocity != Vector2.ZERO:
		animation.play("Walk")
	else:
		animation.play("Idle")


func verify_direction() -> void:
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_ref = body




func _on_body_exited(body):
	if body.is_in_group("player"):
		player_ref = null



func deal_with_damage():
	if player_inattack_zone and Global.player_currently_attacking == true:
		if can_take_damage == true:
			health = health - 40
			print("VIDA DO SLIME: ", health)
			$take_damage_cooldown.start()
			can_take_damage = false
			if health <= 0:
				is_dying = true
				animation.play("Death")
				var player = $Player
				Global.player.add_experience(20)
				self.queue_free()


func enemy():
	pass


func _on_take_damage_cooldown_timeout():
	can_take_damage = true


func _on_Area2D_body_entered(body):
	if body.has_method("player"):
		player_inattack_zone = true


func _on_Area2D_body_exited(body):
	if body.has_method("player"):
		player_inattack_zone = false


func update_health():
	var healthbar = $Healthbar
	
	healthbar.value = health
	
	if health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true
