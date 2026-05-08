extends CharacterBody2D

@export var ghost_spawn_interval: float = 0.1  # 残影生成间隔
@export var ghost_fade_time: float = 0.4  # 残影淡出时间

var ghost_timer: float = ghost_spawn_interval

func _process(delta):
	ghost_timer += delta
	# 移动逻辑（示例）
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * 600
	move_and_slide()

	# 生成残影（只在移动时生成更省性能）
	if ghost_timer >= ghost_spawn_interval and velocity.length() > 10:
		spawn_ghost()
		ghost_timer = 0.0

func spawn_ghost():
	var ghost: AnimatedSprite2D = $AnimatableBody2D.duplicate()

	ghost.global_position = global_position
	ghost.global_rotation = global_rotation
	ghost.z_index -= 1
	# 透明度从1降到0
	ghost.modulate.a = 1.0
	ghost.stop()
	var tween = create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, ghost_fade_time)
	tween.finished.connect(func(): ghost.queue_free())
	get_parent().add_child(ghost)
