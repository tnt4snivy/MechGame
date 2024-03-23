extends CharacterBody3D

enum State{
	IDLE,
	COMBAT
}

@onready var player=get_parent().get_node("Player")
var bullet=load("res://scenes/bullet.tscn")

var bullet_instance

@onready var gun=$blockbench_export/Node/gun
@onready var end_of_gun=$blockbench_export/Node/gun/EndOfGun
@onready var nav = $NavigationAgent3D


@export var health=20
@export var speed=3.5

var current_state=State.IDLE
var whatHitMe
var accel=20

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	var direction=Vector3()
	if not is_on_floor():
		velocity.y -= gravity*delta
	match  current_state:
		State.IDLE:
			idle()
		State.COMBAT:
			combat()
			nav.target_position=player.global_position
			direction=nav.get_next_path_position()-global_position
			direction=direction.normalized()
			velocity=velocity.lerp(direction*speed, accel*delta)
	move_and_slide()



func idle():
	#gun.rotation=Vector3(0,0,0)
	$ShootTimer.stop()

func combat():
	self.look_at(player.global_position)
	self.rotation.x=0
	gun.look_at(player.global_position, Vector3.UP)
	gun.rotation.x-=deg_to_rad(90)
	#gun.rotation.z=0
	if $ShootTimer.is_stopped():
		shoot()
		$ShootTimer.start()
	


func _on_player_detector_body_entered(body):
	if body.is_in_group("Player"):
		current_state=State.COMBAT


func _on_player_detector_body_exited(body):
	if body.is_in_group("Player"):
		current_state=State.IDLE

func shoot():
	bullet_instance=bullet.instantiate()
	bullet_instance.position=end_of_gun.global_position
	bullet_instance.transform.basis=end_of_gun.global_transform.basis
	get_parent().add_child(bullet_instance)

func _on_shoot_timer_timeout():
	shoot()


func _on_hurtbox_area_entered(area):
	whatHitMe=area.get_parent()
	if whatHitMe.is_in_group("Projectiles") and whatHitMe!=self:
		health-=whatHitMe.damage
		print("ow")
	if health==0:
		queue_free()
