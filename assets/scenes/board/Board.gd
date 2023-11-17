extends Node2D
var players = 2
var playerInst = preload("res://assets/scenes/INSTANCES/player/player.tscn")
var currentP = 0
func _ready():
	for p in $Players.get_children():
		p.queue_free()
	for i in players:
		var new = playerInst.instantiate()
		new.playerId = i
		$Players.add_child(new)
	await get_tree().process_frame
	$Players.get_child(currentP).playing = true
	updateHud()

func nextTurn():
	$Players.get_child(currentP).playing = false
	currentP = wrapi(currentP+1, 0, players)
	$Players.get_child(currentP).playing = true
	updateHud()

func updateHud():
	$GameHud/CurrentPlayer.text = "Current Player: "+str(currentP+1)
