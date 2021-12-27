extends Node2D

export var maxSpeed := 300.0
export var acceleration := 100.0
export var turnSpeed := 1.0 #radians
export var autoTurnSpeed:= 15.0
export var friction := -30.0
export var initialDirection := Vector2(1, 0)
export var debug := false

signal target_reached

onready var tankBody := $TankBody

var seek := false
var arrive := false
var target := Vector2(0, 0)
var stopWhenArrived := false
var desired := Vector2(0,0)

# total speed of the vehicle (decreases over time to 0)
var velocity := Vector2(0, 0)
# where the vehicle is heading
var direction := initialDirection
# whether the vehicle is moving or stopped
var moving := false

var canMove := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #goto(Vector2(300, 300), true, false, true)
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    
    # input
    if Input.is_action_pressed("ui_up"):
        applyForce(direction * acceleration * delta)
    if Input.is_action_pressed("ui_down"):
        applyForce(-direction * acceleration * delta)
    if Input.is_action_pressed("ui_left"):
        velocity = velocity.rotated(-turnSpeed * delta)
    if Input.is_action_pressed("ui_right"):
        velocity = velocity.rotated(turnSpeed * delta)
    if Input.is_action_just_pressed("ui_accept"):
        canMove = true
    #canMove = false
    
    # steering
    if seek:
        # step through
        
        # calculate vector to reach target
        desired = (target - tankBody.position)
        var desiredMagnitude = desired.length()
        var desiredDirection = desired.normalized()
        var seekSpeed = maxSpeed
        if arrive:
            # within 50 pixels?
            if desiredMagnitude < 100:
                var currentSpeed := velocity.length()
                seekSpeed = range_lerp(desiredMagnitude, 0, 100, currentSpeed / 2.0, maxSpeed)
                #print('speed=', seekSpeed)
        
        var desiredForce = desiredDirection * seekSpeed
        var steeringForce = desiredForce - velocity
        
        # slow down if wen
        var howFarApart = desiredDirection.dot(velocity.normalized())
        #print('dot=', howFarApart)
        
        var turnRate = range_lerp(howFarApart, -1.0, 1.0, 0.1, autoTurnSpeed)
            
        steeringForce = (steeringForce * turnRate)
        
        applyForce(steeringForce * delta)
        # if we've just arrived at the target, stop seeking
        if arrivedAt(target):
            seek = false
            if stopWhenArrived:
                stop()
            print("emitting signal target_reached")
            emit_signal("target_reached", target)
            
    # friction
    if moving:
        applyForce(direction * friction * delta)

    # ----
    # move
    # ----
    if shouldStop():
        if moving:
            stop()
        return
    
    moving = true
    
    # commit
    velocity = velocity.clamped(maxSpeed)
    direction = velocity.normalized()

    tankBody.rotation = initialDirection.angle_to(direction)
    tankBody.move_and_slide(velocity)
    update()
    

    # prepare for next physics cycle
    if shouldStop():
        stop()

func shouldStop() -> bool:
    return velocity.length_squared() < 0.001

func stop() -> void:
    moving = false
    velocity = Vector2(0, 0)
        
func arrivedAt(location:Vector2) -> bool:
    return (location - tankBody.position).length() <= 5

func _draw() -> void:
    if debug:
        draw_line(tankBody.position, (tankBody.position + velocity * 100), Color(0, 0, 255), 3)
        draw_line(tankBody.position, (tankBody.position + desired * 100), Color(255, 255, 255), 3)
        draw_line(tankBody.position, tankBody.position + Vector2(1, 0) * maxSpeed, Color(255, 0, 0), 1)
        draw_line(tankBody.position, tankBody.position + Vector2(0, 1) * maxSpeed, Color(0, 255, 0), 1)
        draw_circle(target, 10, Color(0,0,255))
    
        
# Euler would be proud
func applyForce(force:Vector2) -> void:
    velocity += force
        
func goto(location: Vector2, global:bool = false, arriveSlowly:bool = false, stopOnArrival:bool = false) -> void:
    seek = true
    arrive = arriveSlowly
    stopWhenArrived = stopOnArrival
    # convert to local coordinates
    if global:
        target = location - position
    else:
        target = location

func teleport(location: Vector2) -> void:
    tankBody.position = location - position
    
# This is a hack because I screwed up. The root object never moves, only tankBody, which means that
# external users of this class can't use the .position property to see where the tank is, since it 
# never changes, and in fact it should not change because it'll then break this getPosition() func.
# It's a mess.
func getWorldPosition() -> Vector2:
    return position + tankBody.position
