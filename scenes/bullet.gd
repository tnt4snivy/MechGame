extends Node3D

const SPEED=20

func _process(delta):
	position+= transform.basis * Vector3(0,0, -SPEED) *delta


func _on_delete_tiner_timeout():
	queue_free()


func _on_hitbox_body_entered(body):
	if body.name!="Player":
		queue_free()
