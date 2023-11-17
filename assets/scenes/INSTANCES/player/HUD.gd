extends CanvasLayer

var dice = preload("dice/dice.tscn")
var nice = preload("goodRoll/Nice!!.tscn")
@export var simLimit = 1.0

var rng = RandomNumberGenerator.new()
var simRolling = false
func _ready():
	$simRoll.pressed.connect(simR)

func simR():
	simRolling = $simRoll.button_pressed

func simRoll(dices):
	$Label.text = str(dices)
	for i in $DICE.get_children():
		i.queue_free()
	for i in dices.size():
		var newDice = dice.instantiate()
		$DICE.add_child(newDice)
		newDice.position = Vector2(i * -64, 0)
		var simTimer = get_tree().create_timer(simLimit)
		while simTimer.time_left > 0:
			rng.randomize()
			newDice.get_node("Sprite2D").frame = rng.randi_range(0, 5)
			await get_tree().process_frame
		newDice.get_node("Sprite2D").frame = dices[i] - 1
		if dices[i] == 6:
			var nices = nice.instantiate()
			add_child(nices)
			nices.get_node("AnimationPlayer").play("Bounce")
			await nices.get_node("AnimationPlayer").animation_finished
			nices.queue_free()
