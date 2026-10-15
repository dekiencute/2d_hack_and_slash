extends CanvasLayer

@onready var hp_bar: ProgressBar = $TopLeft/VBox/HPBar
@onready var hp_label: Label = $TopLeft/VBox/HPLabel
@onready var style_label: Label = $TopLeft/VBox/Style
@onready var score_label: Label = $TopLeft/VBox/Score
@onready var wave_label: Label = $TopRight/VBox/Wave
@onready var enemy_label: Label = $TopRight/VBox/Enemies
@onready var message_label: Label = $CenterMessage

func _ready() -> void:
	var style := get_tree().get_first_node_in_group("style_system")
	if style:
		style.style_changed.connect(_on_style_changed)
		_on_style_changed(style.get_rank(), style.score)

func set_player_hp(current: float, maximum: float) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current
	hp_label.text = "HP  %d / %d" % [int(ceil(current)), int(maximum)]

func set_wave(current: int, total: int) -> void:
	wave_label.text = "WAVE  %d / %d" % [current, total]

func set_enemies(count: int) -> void:
	enemy_label.text = "ENEMIES  %d" % count

func set_message(text: String) -> void:
	message_label.text = text
	message_label.visible = not text.is_empty()

func _on_style_changed(rank: String, score: float) -> void:
	style_label.text = "STYLE  %s" % rank
	score_label.text = "Score: %04d" % int(score)
