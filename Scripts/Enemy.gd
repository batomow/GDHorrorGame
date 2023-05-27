extends CharacterBody3D

enum States { 
	patrol, 
	chasing, 
	hunting, 
	waiting
}

@export var chase_speed := 3.0
@export var patrol_speed := 2.0

@onready var waypoints: Array = get_tree().get_nodes_in_group("Enemy Waypoint")
@onready var navigation_agent :NavigationAgent3D = $NavigationAgent3D
@onready var patrol_timer: Timer = $PatrolTimer
@onready var player:CharacterBody3D = get_tree().get_nodes_in_group("Player")[0]
@onready var current_state:States = States.patrol

var waypoint_index: int
var player_in_earshot_far := false
var player_in_earshot_close := false
var player_in_sight_far := false
var player_in_sight_close := false

func _ready(): 
	(navigation_agent as NavigationAgent3D).target_position = (waypoints[0].global_position)

func _process(delta): 
	match current_state: 
		States.patrol: 
			if navigation_agent.is_navigation_finished(): 
				current_state = States.waiting
				patrol_timer.start()
				return
			move_towards_point(delta, patrol_speed)
				
		States.chasing: 
			if navigation_agent.is_navigation_finished(): 
				patrol_timer.start() 
				current_state = States.waiting
			navigation_agent.target_position = player.global_position
			move_towards_point(delta, chase_speed)
		States.hunting: 
			if navigation_agent.is_navigation_finished(): 
				patrol_timer.start() 
				current_state = States.waiting
			move_towards_point(delta, patrol_speed)
		States.waiting: 
			pass

func move_towards_point(delta, speed):
	var target_position = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(target_position)
	face_direction(target_position)
	velocity = direction * speed
	move_and_slide()
	if player_in_earshot_far: 
		check_for_player()

func check_for_player(): 
	var space_state = get_world_3d().direct_space_state
	var result:Dictionary = space_state.intersect_ray(PhysicsRayQueryParameters3D.create($Head.global_position, player.get_node("Camera3D").global_position, 1, [self]))
	if result.size() > 0: 
		if result["collider"].is_in_group("Player"):
			
			if player_in_earshot_close:
				if player.crouched == false: 
					current_state = States.chasing
					
			if player_in_earshot_far:
				if player.crouched == false: 
					current_state = States.hunting
					
			if player_in_sight_close:
				if player.light_level > 0.3:
					current_state = States.chasing
					
			if player_in_sight_far:
				if player.crouched == false and player.light_level > .6: 
					current_state = States.hunting
					navigation_agent.target_position = player.global_position
				if player.crouched == true and player.light_level > .7: 
					current_state = States.hunting
					navigation_agent.target_position = player.global_position

func face_direction(direction:Vector3): 
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)

func _on_patrol_timer_timeout():
	current_state = States.patrol
	waypoint_index = (waypoint_index + 1) % waypoints.size()
	navigation_agent.target_position = waypoints[waypoint_index].global_position


func _on_hearing_far_body_entered(body):
	if body.is_in_group("Player"): 
		player_in_earshot_far = true
		print("Player is in far earshot")


func _on_hearing_far_body_exited(body):
	if body.is_in_group("Player"): 
		player_in_earshot_far = false
		print("Player has left far earshot")


func _on_hearing_close_body_entered(body):
	if body.is_in_group("Player"):
		player_in_earshot_close = true
		print("Player is close in earshot")


func _on_hearing_close_body_exited(body):
	if body.is_in_group("Player"): 
		player_in_earshot_close = false
		print("Player has left close earshot")

func _on_sight_far_body_entered(body):
	if body.is_in_group("Player"): 
		player_in_sight_far = true
		print("Player has entered far sight")


func _on_sight_far_body_exited(body):
	if body.is_in_group("Player"): 
		player_in_sight_far = false
		print("Player has left far sight")


func _on_sight_close_body_entered(body):
	if body.is_in_group("Player"): 
		player_in_sight_close = true
		print("Player has entered close sight")


func _on_sight_close_body_exited(body):
	if body.is_in_group("Player"): 
		player_in_sight_close = false
		print("Player has left close sight")
