extends StaticBody3D

const Util = preload('res://scripts/util.gd')
const bullet_scene = preload('res://scenes/bullet.tscn')

@onready var body_mesh = $BodyMesh
@onready var projectile = $Projectile
@onready var collision_shape = $CollisionShape3D

signal has_died
signal fired_shot

var points = 200
var is_dead = false
var initial_look_direction = 0
var can_shoot = false


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
	
	if can_shoot and global_position.distance_to(player_pos) <= 8:
		fired_shot.emit()
		var bullet = bullet_scene.instantiate()
		bullet.global_transform = projectile.global_transform
		get_tree().current_scene.add_child(bullet)


func die():
	if is_dead:
		return
	is_dead = true
	has_died.emit()
	Util.explode(self)
	(body_mesh.mesh as SphereMesh).is_hemisphere = true
	(body_mesh.mesh as SphereMesh).height = (body_mesh.mesh as SphereMesh).radius
	body_mesh.rotation.z = PI
	(collision_shape.shape as CylinderShape3D).height = (body_mesh.mesh as SphereMesh).radius
	collision_shape.rotation.x = PI / 2
	collision_shape.position.z = (body_mesh.mesh as SphereMesh).radius / 2
	GameProgress.increase_score(points)
	
