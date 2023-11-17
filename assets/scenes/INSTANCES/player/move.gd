extends Node2D
var rng = RandomNumberGenerator.new()

var amountMove = -1

@export var playerId = 1
var playing = false
@export var moveSpd = 1.0
var moving = false
var diceSet = []


@onready var hud = $HUD

@onready var board = $"../../The/"
@onready var tiles = board.get_node("Tiles")
@onready var at = board.get_node("Plate")


func _process(delta):
	rng.randomize()
	if playing:
		if Input.is_action_pressed("fire2") and not moving:
			moving = true
			amountMove = _diceRoll()
			
			if hud.simRolling: await hud.simRoll(diceSet)
			await goTo()
			board.get_parent().nextTurn()


func _diceRoll():
	diceSet = []
	var newRoll = 6
	while newRoll == 6:
		newRoll = rng.randi_range(1,6)
		diceSet.append(newRoll)
	var add = 0
	for iterate in diceSet:
		add += iterate
	$Label.text = str(add)
	return add


func goTo():
	while amountMove != 0:
		$Label.text = str(amountMove)
		if at == board.get_node("Plate"): at = tiles.get_node("start")
		else:
			
			var a = at.goTo if sign(amountMove) == 1 else at.goBack
			match a.size():
				0: break
				1: at = at.get_node_or_null(a[0])
				_: print("WHAT")
			if at == null: break
		Special.doTweenKillId(self, "global_position",
		global_position, at.global_position, moveSpd,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, "john")
		await get_tree().create_timer(moveSpd - get_process_delta_time()).timeout
		if at.myType == BoardSettings.type.Skip: continue #if none, keep going
		amountMove -= sign(amountMove)
		if amountMove != 0: await tiles.effect(self)
	moving = false
	await tiles.effect(self, true)
	
