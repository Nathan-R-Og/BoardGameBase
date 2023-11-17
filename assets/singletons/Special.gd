extends Node
## A Singleton used for incredibly specific Godot integrations.
## Contains conversion functions as well as a [Tween]ing through-line.
## Any time anything is [Tween]ed, this will be called.
class_name SpecialFuncs
## Nodes called that were paused.
var pauses = []
## The biggest number representable by Godot. Lol.
const BIGGESTNumber = 9223372036854775807
## All active [Tween]s.
var tweens = []
## [Tween] mode enums.
enum doTweenMode {
	NORMAL = 0, ## Default [Tween]ing mode.
	NO_KILL, ## Async [Tween]ing mode.
	ID, ## [Tween]ing mode that returns a [String] id to be used to cut off a [Tween
	## under the same id.
}
## Manually pause all nodes under a [Node] tree.
## As of Godot 4, this has been usurped by a combination of
## [method SpecialFuncs.efficientPause] and [method SpecialFuncs.pauseTweens].
func pauseTree(node, includeParent = true):
	var the = runThroughTree(node, includeParent)
	var way = false
	if node in pauses:
		way = true
		pauses.remove_at(pauses.find(node))
	else:
		way = false
		pauses.append(node)
	for each in the:
		each.set_process(way)
		if each is AnimatedSprite2D:
			if way:
				each.play()
			else:
				each.pause()
		if each is AnimatedSprite3D:
			if way:
				each.play()
			else:
				each.pause()
	for each in tweens:
		if way:
			each[0].play()
		else:
			each[0].pause()
## A more efficient method of (un)pausing a tree of nodes.
## Godot 4 now has [AnimatedSprite2D]'s follow [member Node.process_mode]
## to dictate whether or not that animation is playing. A vast improvement.
func efficientPause(node, mode = Node.PROCESS_MODE_INHERIT):
	if node.process_mode != Node.PROCESS_MODE_WHEN_PAUSED:
		node.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	else:
		node.process_mode = mode
## (Un)pauses all tweens within [member SpecialFuncs.tweens].
func pauseTweens():
	for each in tweens:
		if each[0].is_running():
			each[0].pause()
		else:
			each[0].play()
## Manually runs through an entire [Node]'s tree.
## There are infinitely better ways of doing this. Pls fix.
func runThroughTree(node, includeParent = true):
	var level = 0
	var layers = [0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	var getNode = node
	var list = [node]
	while level > -1 or layers[0] < node.get_child_count():
		var parented = false
		#(getNode.name)
		while layers[level] < getNode.get_child_count():
			if getNode.get_child_count() > 0:
				var i = 0
				var found = false
				while i < list.size():
					if list[i] == getNode:
						found = true
						break
					i += 1
				if not found and !(getNode == node and not includeParent):
					list.append(getNode)
				
				
				
				getNode = getNode.get_child(layers[level])
				#(getNode.name)
				level += 1
				layers[level] = 0
		if level != 0:
			if getNode.get_child_count() == 0:
				#custom code here
				layers[level] -= 1
				parented = true
				var par = getNode.get_parent()
				list.append(getNode) #custom after function
				getNode = par
			if not parented:
				getNode = getNode.get_parent()
			level -= 1
			layers[level] += 1
		else:
			break
	#print(list)
	return list

## This was deprecated by Godot 4's Time singleton (unix and allat)
## but i am keeping for posterity and flexibility. :>
## (its basically an override kinda)
func toTime(floats, to = null):
	var time = ""
	var seconds = fmod(floats, 60)
	var decibits = floats - (int(floor(seconds)) % 60)
	var minutes = floats / 60.0
	var hours = minutes / 60.0
	var days = hours / 24.0
	var decistring = String(decibits)
	if decistring.find(".") != -1:
		decistring = decistring.replace("0.", "")
	decistring = decistring.pad_zeros(2)
	time = str(int(floor(minutes)) % 60).pad_zeros(2) + ":" + str(int(floor(seconds)) % 60).pad_zeros(2) + "." + decistring
	if to == "minutes":
		return time
	time = str(int(floor(hours)) % 24 ).pad_zeros(2) + ":" + time
	if to == "hours":
		return time
	time = String(days) + ":" + time
	if to == null:
		return time
## Converts imperial feet to metric meters.
func impToMt(length):
	length = length.replace('"', "").split("'")
	var ft = float(length[0])
	var ins = float(length[1])
	ins += ft * 12
	var mt = snapped(0.0254 * ins, 0.01)
	return String(mt) + "m"

## This is also super deprecated in Godot 4 because
## they actually bothered adding hexidecimal int support!!!!!
## cray cray!!!
func hex(way, address):
	#instead of this func use
	"0xff".hex_to_int()
	"ff".hex_to_int()
	#for hex2dec, and
	PackedByteArray([255]).hex_encode()
	#for dec2hex
	match way:
		"hex2dec":
			var runthrough = []
			var total = 0
			for i in address.length():
				runthrough.append("0123456789ABCDEF".find(address[i]))
			for mult in runthrough.size():
				runthrough[mult] = runthrough[mult] * (pow(16, runthrough.size() - (mult + 1)))
			for makeTotal in runthrough:
				total += makeTotal
			return total
		"dec2hex":
			var newString = ""
			var lastQuo = 0
			lastQuo = int(String(address))
			
			while lastQuo >= 0:
				var toAdd = int(lastQuo) % 16
				var do = lastQuo / 16
				var cha = "0123456789ABCDEF"[toAdd]
				newString = cha + newString
				if do <= 0:
					break
				lastQuo = do
			
			return newString
## Runs a temp script under a temp node to effect the [SceneTree].
func eval(code):
	var scode = "func eval():\n" + "\n".join(code)
	scode = "extends Node\n" + scode
	var SCRipt = GDScript.new()
	var ref = Node.new()
	SCRipt.set_source_code(scode)
	SCRipt.reload()
	ref.set_script(SCRipt)
	add_child(ref)
	var augh = ref.eval()
	print(augh)
	ref.queue_free()
## Incredibly outdated.
## Converts [string] to an array by seperating parentheses or brackets.
func strArray(string):
	var stop = false
	var lastStop = 0
	var layer = 0
	var split = ","
	var list = []
	for s in string.length():
		var chas = string[s]
		var start = chas == "[" or chas ==  "("
		var end = chas == "]" or chas ==  ")"
		
		if start:
			stop = true
			layer += 1
		elif end:
			stop = false
			layer -= 1
		
		
		if not stop and layer == 0:
			var giveEnd = s == string.length() - 1
			if chas == split or giveEnd:
				var add = 0
				if giveEnd:
					add = 1
				var bitch = string.substr(lastStop, (s - lastStop) + add)
				
				list.append(bitch)
				lastStop = s + 1
	return list
## Returns a String with use for [RichTextLabel]'s integration of BBCode.
func bb(code:String, string:String)->String:
	return "[" + code + "]" + string + "[/" + code + "]"
## imma be real i completely forgot what this was used for. lol.
func checkStructure(struct1, struct2):
	if typeof(struct1) != TYPE_DICTIONARY:
		return false
	elif typeof(struct2) != TYPE_DICTIONARY:
		return false
	var i = 0
	var k1 = struct1.keys()
	var k2 = struct2.keys()
	if k2.size() != k1.size():
		return false
	while i < k1.size():
		var key = k1[i]
		var key2 = k2[i]
		if key != key2:
			break
		i += 1
	return i == k1.size()
## imma be real i completely forgot what this was used for. lol.
func combArray(array, search, oper = null):
	var finds = 0
	var finds2 = []
	var i = [0]
	var layer = 0
	if oper == null or oper == "amount":
		while i[0] < array.size():
			var inQuestion = array[i[layer]]
			while typeof(inQuestion) == TYPE_ARRAY:
				i.append(0)
				layer += 1
				inQuestion = array[i[layer]]
			if inQuestion == search:
				finds += 1
			var ugh = clamp(layer - 1, 0, INF)
			var parent = array[i[ugh]]
			if typeof(inQuestion) != TYPE_ARRAY and typeof(parent) == TYPE_ARRAY:
				if i[layer] >= parent.size():
					i.remove(layer)
					layer -= 1
			i[layer] += 1
		return finds
	elif oper == "delN":
		while i[0] < array.size():
			var inQuestion = array[i[layer]]
			while typeof(inQuestion) == TYPE_ARRAY:
				i.append(0)
				layer += 1
				inQuestion = array[i[layer]]
			var ugh = clamp(layer - 1, 0, INF)
			var parent = array[i[ugh]]
			if inQuestion == search:
				parent.remove(i[layer])
				break
				return true
			if typeof(inQuestion) != TYPE_ARRAY and typeof(parent) == TYPE_ARRAY:
				if i[layer] >= parent.size():
					i.remove(layer)
					layer -= 1
			i[layer] += 1
		return false
	elif oper == "place":
		while i[0] < array.size():
			var inQuestion = array[i[layer]]
			while typeof(inQuestion) == TYPE_ARRAY:
				i.append(0)
				layer += 1
				inQuestion = array[i[layer]]
			if inQuestion == search:
				finds2.append(i.duplicate(true))
			var ugh = clamp(layer - 1, 0, INF)
			var parent = array[i[ugh]]
			if typeof(inQuestion) != TYPE_ARRAY and typeof(parent) == TYPE_ARRAY:
				if i[layer] >= parent.size():
					i.remove(layer)
					layer -= 1
			i[layer] += 1
		return finds2

## these are deprecated as of godot 4 (thank god)
## keeping these just in case though for compatibility
## ACTUALLY
## while these are still deprecated, as of time of writing
## there is no way to store state/seed or the engine.
## fuck you and go fuck yourself
## [RandomNumberGeneration] supercedes this.
func grandi_range(from, to):
	return wrapi(randi(), from, to + 1)
func grandf_range(from, to):
	var inter = float(randi())
	var floater = float(grandi_range(1, 10000000))
	return wrapf(inter / floater, from, to + 0.0000001)

## same as hex2dec lol
func bin(way, value):
	#instead of this func, use
	"101".bin_to_int()
	"0b101".bin_to_int()
	#for bin2dec, and
	#uh
	#actually i dont think they have a dec2bin yet so this is actually
	#needed lol

	match way:
		"dec2bin":
			var binary_string = "" 
			var bits = 31 # Checking up to 32 bits 
			while(bits >= 0):
				if(value >> bits  & 1):
					binary_string += "1"
				else:
					binary_string += "0"
				bits -= 1
			return str(int(binary_string)) #int conversion to remove padded 0's
		"bin2dec":
			var decimal_value = 0
			var count = 0
			while(value != 0):
				decimal_value += (value % 10) * pow(2, count)
				value /= 10
				count += 1
			return decimal_value
## Removes a [Tween] from [member SpecialFuncs.tweens] after finishing.
func cleanTween(tween):
	tweens.remove_at(tweens.find(tween))
## Does a [Tween] and calls an await, then cleans it up.
func doTween(node, property, from, to, delay, trans, easeType):
	var tween = get_tree().create_tween()
	tween.tween_property(node, property, to, delay).from(from).set_trans(trans).set_ease(easeType)
	var setup = [tween, doTweenMode.NORMAL]
	tweens.append(setup)
	await tween.finished
	tween.kill()
	cleanTween(setup)
## Same as [method SpecialFuncs.doTween], except it is asynchronous.
func doTweenNoKill(node, property, from, to, delay, trans, easeType):
	var tween = get_tree().create_tween()
	tween.tween_property(node, property, to, delay).from(from).set_trans(trans).set_ease(easeType)
	var setup = [tween, doTweenMode.NO_KILL]
	tweens.append(setup)
	tween.connect("finished", cleanTween.bind(setup))
	return tween
## Same as [method SpecialFuncs.doTween], except you can link an id to call
## to check if the [Tween] already exists.
func doTweenKillId(node, property, from, to, delay, trans, easeType, id):
	var i = 0
	while i < tweens.size():
		if tweens[i][1] == doTweenMode.ID:
			if tweens[i][2] == id:
				tweens[i][0].kill()
				tweens.remove_at(i)
				break
		i += 1
	var tween = get_tree().create_tween()
	tween.tween_property(node, property, to, delay).from(from).set_trans(trans).set_ease(easeType)
	var setup = [tween, doTweenMode.ID, id]
	tweens.append(setup)
	tween.connect("finished", cleanTween.bind(setup))
	return tween
## Check if the [Tween] killId already exists.
func getKillId(id):
	var i = 0
	while i < tweens.size():
		if tweens[i][1] == doTweenMode.ID:
			if tweens[i][2] == id:
				return tweens[i][0]
		i += 1
	return false
## An integration of [method SpecialFuncs.eval] without using a seperate node.
## Uses [Expression] instead.
func evaluate(command, variable_names = [], variable_values = []):
	#string expressions
	var expression = Expression.new()
	var error = expression.parse(command, variable_names)
	if error != OK:
		push_error(expression.get_error_text())
		return
	return expression.execute(variable_values, self)
## Returns all files with a specified [param path].
func getFiles(path:String):
	var goods = []
	var dir = DirAccess.open(path)
	var at = 0
	var layers = [0]
	var ass = dir.get_directories().size()
	while layers[0] < ass:
		var s = dir.get_directories()[layers[at]]
		dir.change_dir(s)
		if dir.get_directories().size() > 0:
			at += 1
			layers.resize(at + 1)
			layers[at] = 0
		else:
			#last in a tree
			for i in dir.get_files():
				goods.append(dir.get_current_dir() + "/" + i)
			
			dir.change_dir(dir.get_current_dir().rsplit("/", true, 1)[0])
			layers[at] += 1
			if layers[at] >= dir.get_directories().size():
				at -= 1
				if at < 0:
					at = 0
				layers.resize(at + 1)
				dir.change_dir(dir.get_current_dir().rsplit("/", true, 1)[0])
				layers[at] += 1
	for i in dir.get_files():
		goods.append(dir.get_current_dir() + "/" + i)
	
	#clean
	var i = 0
	while i < goods.size():
		if goods[i].ends_with(".import"):
			goods.pop_at(i)
			continue
		var j = i + 1
		while j < goods.size():
			if goods[i] == goods[j]:
				goods.pop_at(j)
			else:
				j += 1
		i += 1
	
	return goods
## Returns a directio from a given [param vec].
## [param finesse] is used to determine angle snapping,
## [param dominantY] is used to determine which direction gets checked first,
## and [param ways] is how many directions to include in the final output.
func directionFromVec(vec, finesse = 90.0, dominantY = true, ways = 1):
	var angle = round(wrapf(rad_to_deg(atan2(-vec.y, vec.x)), 0, 360) / finesse) * finesse
	var p = PackedStringArray()
	#both get ran, dominantY just determines order
	for i in 2:
		if dominantY:
			if angle >= 45 and angle <= 135:
				p.append("up")
			elif angle >= 225 and angle <= 315:
				p.append("down")
		else:
			if angle <= 45 or angle >= 315:
				p.append("right")
			elif angle >= 135 and angle <= 225:
				p.append("left")
		dominantY = !dominantY
	
	#make first letter of all but first caps (camelCase)
	var i = 1
	while i < len(p):
		p[i][0] = p[i][0].to_upper()
		i += 1
	if ways <= 1:
		return p[0]
	else:
		return "".join(p)
## An 'override' to get_tree().create_timer.
## SceneTreeTimers are not able to be paused without setting get_tree().paused
## to true. This is stupid.
## Pass [ownesr] if you are worried about pausing based on process_modes.
func create_timer(time_float, ownesr=self):
	var newTimer = Timer.new()
	ownesr.add_child(newTimer) #tbis is dumb. i hate this
	newTimer.start(time_float)
	newTimer.one_shot = true
	newTimer.timeout.connect(relieveTimer.bind(newTimer))
	return newTimer
## Function ran after a Special timer runs out.
## Used to rid the timer of its life.
func relieveTimer(timer):
	timer.queue_free()
## Function to retrieve a node's position based on its position relative to the screen.
## Pass a camera if the node is 3D. Otherwise it basically just gets its position.
## Controls have their position added to their size divided by two, as controls are (usually) anchored top left.
func getScreenPos(node):
	if node is Node3D:
		return $Level/Camera.unproject_position(node.transform.origin)
	elif node is Node2D:
		return node.global_position
	elif node is Control:
		return node.global_position + (node.size / 2.0)
