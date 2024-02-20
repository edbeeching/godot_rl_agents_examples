extends Node3D

var contacts := []

func _on_timer_timeout():
	explode()
	$powerupBomb.visible = false
	$Sparks.set_emitting(true)
	$Flash.set_emitting(true)

	await $Sparks.finished
	queue_free()

func explode():
	for contact in contacts:
		if contact is Player:
			contact.hit_by_bomb()

func _on_damage_radius_body_exited(body:Node3D):
	contacts.erase(body)

func _on_damage_radius_body_entered(body:Node3D):
	contacts.append(body)

