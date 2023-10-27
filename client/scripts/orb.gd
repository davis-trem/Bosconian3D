extends StaticBody3D

const Util = preload('res://scripts/util.gd')

@onready var body_mesh = $BodyMesh
@onready var projectile = $Projectile


var is_dead = false
var initial_look_direction = 0


func _ready():
	initial_look_direction = rotation.y


func _process(delta):
	if is_dead:
		return
	
	var closest_player = Util.get_closest_node(
		self,
		get_tree().get_nodes_in_group('player')
	)
	if closest_player == null:
		return
	var player_pos = Util.get_closest_position(self, closest_player)
	
	var direction_to = global_position.direction_to(player_pos)
	
	rotation.y = clamp(
		Vector2(-direction_to.z, -direction_to.x).angle(),
		initial_look_direction - PI/4,
		initial_look_direction + PI/4
	) #-45° to 45°


func die():
	if is_dead:
		return
	Util.explode(self)
	is_dead = true
	(body_mesh.mesh as SphereMesh).is_hemisphere = true
	(body_mesh.mesh as SphereMesh).height = (body_mesh.mesh as SphereMesh).radius
	body_mesh.rotation.z = PI
