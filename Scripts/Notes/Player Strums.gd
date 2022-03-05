extends Node2D

export(bool) var is_player = true

var key_count = GameplaySettings.key_count

onready var game = $"../../"

func _process(_delta):
	if is_player:
		for index in key_count:
			if !Settings.get_data("bot"):
				if Input.is_action_pressed("gameplay_" + str(index)):
					game.bf.timer = 0.0
				if Input.is_action_just_pressed("gameplay_" + str(index)):
					get_child(index).play_animation("press")
					
					var alreadyHit = false
					var time:float = 0
					
					for note in $"../Player Notes".get_children():
						if note.note_data == index and (!alreadyHit or note.strum_time == time):
							if note.strum_time > Conductor.songPosition - Conductor.safeZoneOffset and note.strum_time < Conductor.songPosition + Conductor.safeZoneOffset:
								alreadyHit = true
								game.bf.play_animation("sing" + NoteFunctions.dir_to_animstr(note.direction).to_upper(), true)
								game.combo += 1
								time = note.strum_time
								
								if !note.is_sustain:
									note.queue_free()
								else:
									note.being_pressed = true
								
								get_child(index).play_animation("confirm")
								game.health += 0.035
								
								AudioHandler.get_node("Voices").volume_db = 0
				elif !Input.is_action_pressed("gameplay_" + str(index)):
					get_child(index).play_animation("static")
					
					for note in $"../Player Notes".get_children():
						if note.note_data == index:
							if note.is_sustain and note.sustain_length > Conductor.timeBetweenSteps / 3:
								note.being_pressed = false
			else:
				for note in $"../Player Notes".get_children():
					if note.note_data == index:
						if note.strum_time <= Conductor.songPosition:
							game.bf.timer = 0.0
							game.bf.play_animation("sing" + NoteFunctions.dir_to_animstr(note.direction).to_upper(), true)
							
							if !note.is_sustain:
								note.queue_free()
							else:
								note.being_pressed = true
							
							get_child(index).play_animation("confirm")
							game.health += 0.035
							
							AudioHandler.get_node("Voices").volume_db = 0
