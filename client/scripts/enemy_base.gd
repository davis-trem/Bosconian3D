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


func _ready():
	core.has_died.connect(_die)
	
	orbs = [orb, orb_2, orb_3, orb_4, orb_5, orb_6]
	for o in orbs:
		o.has_died.connect(_handle_orb_died)
	animation_player.play('open_shields')


func _process(delta):
	pass


func _handle_orb_died():
	if orbs.all(func(o): return o.is_dead):
		_die()


func _die():
	Util.explode(self)
	queue_free()
