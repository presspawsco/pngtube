extends Node2D

@onready var puppet = $PuppetController

# Called when the node enters the scene tree for the first time.
func _ready():
	TwitchService.setup();
	puppet.global_position = Vector2(1920/2, 1080/2)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_wearable_listener_received(data):
	if data["reward"]["title"] == "party hat":
		print("PARTY HAT!!")
	pass # Replace with function body.
