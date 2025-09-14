# Main.gd
extends Node

@export var mob_scene: PackedScene

@onready var timer: Timer = $MobTimer
@onready var follow: PathFollow3D = $SpawnPath/SpawnLocation
@onready var player: Node3D = $Player

func _ready() -> void:
	$UserInterface/Retry.hide()
	randomize()
	if mob_scene == null:
		push_warning("Assign mob_scene in the Inspector.")
	if not timer.timeout.is_connected(_on_mob_timer_timeout):
		timer.timeout.connect(_on_mob_timer_timeout)
	if timer.is_stopped():
		timer.start()

func _on_mob_timer_timeout() -> void:
	if mob_scene == null: return

	# สุ่มตำแหน่งบน Path
	follow.progress_ratio = randf()
	var spawn_pos: Vector3 = follow.global_position
	var player_pos: Vector3 = player.global_position   # ใช้พิกัดโลก

	# สร้าง + ใส่ซีน + ตั้งค่า
	var mob := mob_scene.instantiate()
	add_child(mob)
	mob.initialize(spawn_pos, player_pos)
	#mob.initialize(spawn_pos, Vector3.ZERO)
	# (ดีบัก) ดูว่า timeout ถูกเรียกจริงไหม
	#print("spawn at:", spawn_pos, " t=", Time.get_ticks_msec())
	mob.squashed.connect($UserInterface/ScoreLabel._on_mob_squashed.bind())
	

func _on_player_hit() -> void:
	$MobTimer.stop()
	$UserInterface/Retry.show()
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		# This restarts the current scene.
		get_tree().reload_current_scene()
