extends RichTextLabel

func set_time(time: float):
	time = max(time, 0)
	var minutes: int = floor(time/60)
	time -= minutes*60
	var seconds: int = floor(time)
	time -= seconds
	var milliseconds: int = round(time*1e3)
	time -= milliseconds
	text = ("[color=blue]" + 
		"%02.0f" % minutes + ":" + 
		"%02.0f" % seconds + "." + 
		"%03.0f" % milliseconds + 
	"[/color]")
