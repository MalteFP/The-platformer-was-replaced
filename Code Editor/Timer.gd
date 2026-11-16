extends Button
var timer = 0
var Minutes
var Seconds
var isTicking = false
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)


func _process(delta: float) -> void:
	
	
	Minutes = str(round_to_dec(int(timer/60),0)).split(".")[0]
	Seconds = str(int(timer)%60)
	
	
	
	if Minutes.length() == 1:
		Minutes = "0" + Minutes
	if Seconds.length() == 1:
		Seconds = "0" + Seconds
		
	text = Minutes + ":" + Seconds
	if isTicking:
		timer += delta
	
	
