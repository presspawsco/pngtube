extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

const PIVOT_MODE = [
	CORNER_TOP_LEFT,
	CORNER_TOP_RIGHT,
	CORNER_BOTTOM_LEFT,
	CORNER_BOTTOM_RIGHT
]

@onready var puppet_sprite = $PuppetSprite
@onready var grab_box = $PuppetSprite/GrabBox

@export_range(0.10, 2.00, 0.05) var sprite_scale : float = 1
@export var enable_bounds : bool
@export var mic_threshold_talk : float = -23.5
@export var mic_threshold_yell : float = -8.5
@export var mic_shake_intensity : int = 15
@export var bounce_curve : Curve
@export_range(0.5, 3, 0.5) var bounce_factor : float = 1

var idx
var power

var puppet_width
var puppet_height
var puppet_held = false
var mouse_offset := Vector2.ZERO
var time : float = 0
var bounce = false
var effect

var sprite_location
var sprite_idle 
var sprite_talk
var sprite_yell

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	sprite_location = global_position
	sprite_idle = preload("res://assets/idle.png")
	sprite_talk = preload("res://assets/talk.png")
	sprite_yell = preload("res://assets/yell.png")
	
	print(AudioServer.get_input_device_list())
	puppet_width = puppet_sprite.texture.get_width()
	puppet_height = puppet_sprite.texture.get_height()
	$PuppetSprite/GrabBox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	#custom_minimum_size = Vector2(puppet_width, puppet_height)


func _physics_process(delta):
	# Add the gravity.
	#if not is_on_floor():
		#velocity.y += gravity * delta
	scale = Vector2(sprite_scale, sprite_scale)

	#if enable_bounds == true:
		#grab_box.add_theme_stylebox_override("normal", StyleBoxFlat)
		#grab_box.add_theme_stylebox_override("hover", StyleBoxFlat)
	#elif enable_bounds == false:
		#grab_box.add_theme_stylebox_override("normal", StyleBoxEmpty)
		#grab_box.add_theme_stylebox_override("hover", StyleBoxEmpty)

	if global_position != sprite_location and not puppet_held:
		global_position = sprite_location

	if puppet_held:
		global_position = get_global_mouse_position() - mouse_offset
		sprite_location = global_position
	
	move_and_slide()

func _process(delta):
	idx = AudioServer.get_bus_index("Mic Input")
	power = AudioServer.get_bus_peak_volume_left_db(idx, 0)
	#print(power)
	if power >= mic_threshold_talk and power < mic_threshold_yell:
		threshold_pass_talk()
	elif power >= mic_threshold_yell:
		threshold_pass_yell()
	else:
		threshold_pass_fail()

func threshold_pass_talk():
	puppet_sprite.set_texture(sprite_talk)
	pass
	
func threshold_pass_yell():
	puppet_sprite.set_texture(sprite_yell)
	shake()

func threshold_pass_fail():
	puppet_sprite.set_texture(sprite_idle)

func shake():
	global_position = sprite_location + Vector2(randf_range(-mic_shake_intensity, mic_shake_intensity), randf_range(-mic_shake_intensity, mic_shake_intensity))

func _on_grabbed():
	mouse_offset = get_global_mouse_position() - global_position
	puppet_held = true

func _on_ungrabbed():
	mouse_offset = get_global_mouse_position() - global_position
	sprite_location = global_position
	puppet_held = false
