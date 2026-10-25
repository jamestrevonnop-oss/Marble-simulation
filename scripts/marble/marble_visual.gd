extends Node2D

var marble: RigidBody2D

func _process(_delta: float) -> void:
    queue_redraw()

func _draw() -> void:
    if not is_instance_valid(marble):
        return
    var radius: float = marble.stats.radius
    draw_circle(Vector2(2, 3), radius + 2.0, Color(0, 0, 0, 0.3))
    draw_circle(Vector2.ZERO, radius, marble.marble_color)
    draw_circle(Vector2(-radius * 0.28, -radius * 0.28), radius * 0.22, Color.WHITE)
    var ratio: float = clampf(marble.stats.health / marble.stats.max_health, 0.0, 1.0)
    draw_rect(Rect2(-17, -radius - 10, 34, 4), Color("#282d38"))
    draw_rect(Rect2(-17, -radius - 10, 34 * ratio, 4), Color("#71e0a2") if ratio > 0.35 else Color("#f36b6b"))
