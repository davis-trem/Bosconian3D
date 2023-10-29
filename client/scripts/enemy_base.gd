extends StaticBody3D


const Util = preload('res://scripts/util.gd')

@onready var animation_player = $AnimationPlayer
@onready var core = $Core
@onready var orb = $Orb
@onready var orb_3 = $Orb3
@onready var orb_2 = $Orb2
@onready var orb_4 = $Orb4
@onready var orb_5 = $Orb5
@onready var orb_6 = $Orb6

var orbs = []
var shooting_wait_time = 0
var time_since_last_shoot = 0


func _ready():
	core.has_died.connect(_die)
	
	orbs = [orb, orb_2, orb_3, orb_4, orb_5, orb_6]
	for o in orbs:
		o.has_died.connect(_on_orb_died)
		o.fired_shot.connect(_on_orb_fired_shot)
	
	animation_player.play('open_shields')
	
	shooting_wait_time = randi_range(5, 8)


func _process(delta):
	if orbs.all(func(o): return not o.can_shoot):
		time_since_last_shoot += delta
	
	if time_since_last_shoot >= shooting_wait_time:
		for o in orbs:
			o.can_shoot = true


func _on_orb_fired_shot():
	for o in orbs:
		o.can_shoot = false
	shooting_wait_time = randi_range(5, 8)
	time_since_last_shoot = 0


func _on_orb_died():
	if orbs.all(func(o): return o.is_dead):
		_die()


func _die():
	Util.explode(self)
	queue_free()
