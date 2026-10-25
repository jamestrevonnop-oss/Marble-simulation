extends Node2D

const MarbleScript = preload("res://scripts/marble/marble_controller.gd")
const StatsScript = preload("res://scripts/marble/marble_stats.gd")
const PhysicsScript = preload("res://scripts/physics/physics_config.gd")

var physics_config = PhysicsScript.new()
var arena := Rect2(42.0, 42.0, 1196.0, 636.0)
var marbles: Array = []
var paused := false
var count_label: Label

func _ready() -> void:
    randomize()
    make_walls()
    make_ui()
    reset_arena()

func _draw() -> void:
    draw_rect(arena, Color("#101927"))
    draw_rect(arena, Color("#4b7894"), false, 4.0)
    for x in range(82, 1240, 40):
        draw_line(Vector2(x, 44), Vector2(x, 676), Color(0.2, 0.29, 0.38, 0.4))
    for y in range(82, 680, 40):
        draw_line(Vector2(44, y), Vector2(1236, y), Color(0.2, 0.29, 0.38, 0.4))

func make_walls() -> void:
    add_wall(Rect2(42, 28, 1196, 14))
    add_wall(Rect2(42, 678, 1196, 14))
    add_wall(Rect2(28, 42, 14, 636))
    add_wall(Rect2(1238, 42, 14, 636))

func add_wall(rect: Rect2) -> void:
    var body := StaticBody2D.new()
    body.position = rect.position + rect.size / 2.0
    var collision := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = rect.size
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func make_ui() -> void:
    var layer := CanvasLayer.new()
    layer.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(layer)

    var panel := PanelContainer.new()
    panel.position = Vector2(12, 12)
    layer.add_child(panel)

    var column := VBoxContainer.new()
    panel.add_child(column)

    var title := Label.new()
    title.text = "MARBLE KINGDOMS"
    column.add_child(title)

    count_label = Label.new()
    column.add_child(count_label)

    var row := HBoxContainer.new()
    column.add_child(row)
    add_button(row, "Pause", toggle_pause)
    add_button(row, "Reset", reset_arena)
    add_button(row, "+ Marble", add_marble)
    add_button(row, "- Marble", remove_marble)

    var speed_label := Label.new()
    speed_label.text = "Movement speed"
    column.add_child(speed_label)
    var speed := HSlider.new()
    speed.min_value = 70
    speed.max_value = 260
    speed.value = physics_config.move_speed
    speed.value_changed.connect(func(value: float): physics_config.move_speed = value)
    column.add_child(speed)

    var bounce_label := Label.new()
    bounce_label.text = "Wall bounce"
    column.add_child(bounce_label)
    var bounce := HSlider.new()
    bounce.min_value = 0.5
    bounce.max_value = 1.2
    bounce.step = 0.05
    bounce.value = physics_config.bounce
    bounce.value_changed.connect(func(value: float):
        physics_config.bounce = value
        for marble in marbles:
            if is_instance_valid(marble) and marble.physics_material_override:
                marble.physics_material_override.bounce = value
    )
    column.add_child(bounce)

func add_button(parent: Node, label_text: String, action: Callable) -> void:
    var button := Button.new()
    button.text = label_text
    button.pressed.connect(action)
    parent.add_child(button)

func reset_arena() -> void:
    for marble in marbles:
        if is_instance_valid(marble):
            marble.eliminated = true
            marble.remove_from_group("marbles")
            marble.queue_free()
    marbles.clear()
    paused = false
    get_tree().paused = false
    for i in range(8):
        add_marble()
    update_status()

func add_marble() -> void:
    if marbles.size() >= 24:
        return
    var marble = MarbleScript.new()
    marble.stats = StatsScript.new()
    marble.physics_config = physics_config
    marble.arena = arena
    marble.marble_color = [
        Color("#ef6c65"), Color("#f4b942"), Color("#68c7a2"),
        Color("#6aa8ff"), Color("#c18aff"), Color("#f28fca")
    ][randi_range(0, 5)]
    marble.position = Vector2(randf_range(90, 1190), randf_range(90, 630))
    add_child(marble)
    marble.initialize()
    marbles.append(marble)
    update_status()

func remove_marble() -> void:
    if marbles.size() <= 2:
        return
    var marble = marbles.pop_back()
    marble.eliminated = true
    marble.remove_from_group("marbles")
    marble.queue_free()
    update_status()

func toggle_pause() -> void:
    paused = not paused
    get_tree().paused = paused
    update_status()

func update_status() -> void:
    if not is_instance_valid(count_label):
        return
    var active := 0
    for marble in marbles:
        if is_instance_valid(marble) and not marble.eliminated:
            active += 1
    count_label.text = "%s | %d/%d active" % ["PAUSED" if paused else "RUNNING", active, marbles.size()]

func _process(_delta: float) -> void:
    update_status()
    queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE:
            toggle_pause()
        elif event.keycode == KEY_R:
            reset_arena()
