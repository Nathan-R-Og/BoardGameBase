extends Node2D
class_name BoardSettings
enum type {
	Skip = -1,
	Normal,
	Bad,
	Shop,
	Battle,
	Event,
	Chance
}

func _ready():
	for i in get_children():
		var notLast = i.get_index() < get_child_count() - 1
		if i.goTo.size() == 0 and notLast:
			var next = get_child(i.get_index()+1)
			print("added "+str(next.name)+" to "+str(i.name)+" in Tiles")
			i.goTo.append(next.get_path())
		var notFirst = i.get_index() > 0
		if i.goBack.size() == 0 and notFirst:
			var previous = get_child(i.get_index()-1)
			print("added "+str(previous.name)+" to "+str(i.name)+" in Tiles")
			i.goBack.append(previous.get_path())
		if i.get_node_or_null("namer") == null:
			var namer = Label.new()
			namer.name = "namer"
			i.add_child(namer)
			namer.text = type.keys()[i.myType+1]
		if i.myType == type.Bad: i.self_modulate=Color.RED

func effect(who, landedOn = false):
	var space:Space=who.at
	match space.myType:
		type.Bad:
			if landedOn:
				print("sent to eternal torment")
				who.amountMove = -999
				who.moving = true
				await who.goTo()
			else:
				print("troll toll :imP:")
				await get_tree().create_timer(2).timeout
				print("ok you can go")

