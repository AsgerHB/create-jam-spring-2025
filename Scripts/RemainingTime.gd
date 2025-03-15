extends RichTextLabel

func set_time(time: float):
	time = max(time, 0)
	var minutes: int = floor(time/60)
	time -= minutes*60
	var seconds: int = floor(time)
	time -= seconds
	var milliseconds: int = round(time*1e3)
	time -= milliseconds
	text = str(minutes) + ":" + str(seconds) + "." + str(milliseconds)
