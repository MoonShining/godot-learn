extends CharacterBody2D


@onready var body: AnimatedSprite2D = $Body
@onready var weapon: Sprite2D = $Weapon

func _ready():
	# 确保一开始进度是 0
	set_shader_progress(0.0)
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		die()

# 假设这个函数在玩家血量归零时调用
func die():
	## 1. 播放死亡动画（假设动画名叫 "death"）
	#play("death")
#
	## 2. 等待死亡动画播放完毕
	#await animation_finished

	# 或者如果你不想播放动画，而是立刻在当前帧碎裂，可以注销上面两行，直接执行下面。

	# 3. 开始爆炸消散效果
	explode_effect()

func explode_effect():
	# 创建一个补间动画 (Tween)
	var tween = create_tween()

	# 用 1.0 秒的时间，将 shader 里的 progress 从 0.0 变到 1.0
	tween.tween_method(set_shader_progress, 0.0, 1.0, 1.0).set_trans(Tween.TRANS_SINE)

	# 爆炸效果结束后，销毁这个节点（或者整个角色实例）
	tween.tween_callback(queue_free)

# Tween 调用的回调函数，用于更新 Shader 的值
func set_shader_progress(value: float):
	body.material.set_shader_parameter("progress", value)
	weapon.material.set_shader_parameter("progress", value)
