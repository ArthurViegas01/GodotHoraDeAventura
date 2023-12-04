extends Control



func _on_play_pressed():
	get_tree().change_scene("res://scenes/Level.tscn")


func _on_options_pressed():
	pass # Replace with function body.


func _on_sair_pressed():
	get_tree().quit()
