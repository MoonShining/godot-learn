extends CharacterBody2D

class_name BaseCharacter

var level = 1
var hit_rate = 2

@onready var body: AnimatedSprite2D = $Body
@onready var weapon: AnimatedSprite2D = $"Body/Weapon"

func _ready():
	# 确保一开始进度是 0
	# GlobalConfig.hello(GlobalConfig.Gravity)
	set_shader_progress(0.0)
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		die()

# 假设这个函数在玩家血量归零时调用
func die():
	explode_effect()

func explode_effect():
	var tween = create_tween()
	# 用 1.0 秒的时间，将 shader 里的 progress 从 0.0 变到 1.0
	tween.tween_method(set_shader_progress, 0.0, 1.0, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(queue_free)

# Tween 调用的回调函数，用于更新 Shader 的值
func set_shader_progress(value: float):
	body.material.set_shader_parameter("progress", value)
	weapon.material.set_shader_parameter("progress", value)
