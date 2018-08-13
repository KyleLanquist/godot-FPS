extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

#Camera
var cameraAngle = 0
var mouseSenitivity = 0.3
var camera_change = Vector2()

var velocity = Vector3()
var direction = Vector3()

#fly
const FlySpeed = 20
const FlyAccel = 40
var isFlying = false

#walk
var gravity = -9.8 * 3
const MaxSpeed = 20
const MaxRunningSpeed = 30
const Accel = 2
const DeAccel = 5

#jump
var jumpHeight = 50
var hasContact = false


#slope
const MaxSlope = 35

#stair
const MaxStairSlope = 20
const StairJumpHeight = 6


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
		
	
func _physics_process(delta):
	aim()
	
	if isFlying:
		fly(delta)
	else:
		walk(delta)
	
	
	
func _input(event):
	if event is InputEventMouseMotion:
		camera_change = event.relative
		
	
		
		
func walk(delta):
	direction = Vector3()
	
	#get the camera rotation
	#REPLACE THIS WITH CORRECT PROGRAMMING PATTERN - TODO
	var point = $Head/Camera.get_global_transform().basis
	
	if Input.is_action_pressed("move_forward"):
		direction -= point.z
	if Input.is_action_pressed("move_backward"):
		direction += point.z
	if Input.is_action_pressed("move_left"):
		direction -= point.x
	if Input.is_action_pressed("move_right"):
		direction += point.x
		
	direction.y = 0
	direction = direction.normalized()
	
	if (is_on_floor()):
		hasContact = true
		var n = $Tail.get_collision_normal()
		var floorAngle =  rad2deg(acos(n.dot(Vector3(0,1,0))))
		if floorAngle > MaxSlope:
			velocity.y += gravity * delta
		
	else:
		if (!$Tail.is_colliding()):
			hasContact = false;
			velocity.y += gravity * delta
			
	if (hasContact and !is_on_floor()):
		move_and_collide(Vector3(0,-1,0))
		
		
	if (direction.length() > 0 && $stairCatcher.is_colliding()):
		var stairNormal = $stairCatcher.get_collision_normal()
		var stairAngle = rad2deg(acos(stairNormal.dot(Vector3(0,1,0))))
		
		if stairAngle < MaxStairSlope:
			velocity.y = StairJumpHeight
			hasContact = false
	
	
	
	
	var tempVelocity = velocity
	tempVelocity.y = 0
	
	var speed
	if Input.is_action_pressed("move_sprint"):
		speed = MaxRunningSpeed
	else:
		speed = MaxSpeed
	
	
	#where whould player go at max speed
	var target = direction * FlySpeed
	
	var acceleration
	if direction.dot(tempVelocity) > 0:
		acceleration = Accel
	else:
		acceleration = DeAccel
	
	#calculate a portion of the distacne to go
	tempVelocity = tempVelocity.linear_interpolate(target, acceleration * delta)
	
	velocity.x=tempVelocity.x
	velocity.z=tempVelocity.z
	
	if hasContact && Input.is_action_just_pressed("jump"):
		velocity.y = jumpHeight
		hasContact = false
	
	velocity = move_and_slide(velocity, Vector3(0,1,0))
	
	$stairCatcher.translation.x=direction.x
	$stairCatcher.translation.z=direction.z
	
	
		
func fly(delta):

	direction = Vector3()
	
	#get the camera rotation
	#REPLACE THIS WITH CORRECT PROGRAMMING PATTERN - TODO
	var point = $Head/Camera.get_global_transform().basis
	
	if Input.is_action_pressed("move_forward"):
		direction -= point.z
	if Input.is_action_pressed("move_backward"):
		direction += point.z
	if Input.is_action_pressed("move_left"):
		direction -= point.x
	if Input.is_action_pressed("move_right"):
		direction += point.x
		
	direction = direction.normalized()
	
	#where whould player go at max speed
	var target = direction * FlySpeed
	
	#calculate a portion of the distacne to go
	velocity = velocity.linear_interpolate(target, FlyAccel * delta)
	
	move_and_slide(velocity)
	
func aim():
	
	if camera_change.length() > 0:
	
		$Head.rotate_y(deg2rad(-camera_change.x * mouseSenitivity))
		
		var change = -camera_change.y * mouseSenitivity 
		if change + cameraAngle < 90 and change + cameraAngle > -90:
			$Head/Camera.rotate_x(deg2rad(change))
			cameraAngle += change
		camera_change = Vector2()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Area_body_shape_entered(body_id, body, body_shape, area_shape):
	if body.name == "Player":
		isFlying = true;


func _on_Area_body_exited(body):
	if body.name == "Player":
		isFlying = false;
