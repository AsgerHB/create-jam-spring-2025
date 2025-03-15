extends RichTextLabel

var max_time: float = 0.0

func set_max_time(time: float):
	max_time = time

func set_time(time: float):
	var _time = time
	time = max(time, 0)
	var minutes: int = floor(time/60)
	time -= minutes*60
	var seconds: int = floor(time)
	time -= seconds
	var milliseconds: int = round(time*1e3)
	time -= milliseconds

	var lerp_factor = ((max_time - _time) / max_time) ** 2
	var color = Color.BLUE.lerp(Color.RED, lerp_factor)
	add_theme_font_size_override("normal_font_size", lerpf(70, 140, lerp_factor))
	text = ("[color=" + color.to_html() + "]" + 
		"%02.0f" % minutes + ":" + 
		"%02.0f" % seconds + "." + 
		"%03.0f" % milliseconds + 
	"[/color]")
