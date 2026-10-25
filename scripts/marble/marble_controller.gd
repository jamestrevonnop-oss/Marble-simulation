extends RigidBody2D

var stats
var physics_config
var arena: Rect2
var marble_color := Color("#ef6c65")
var target: Node2D
var attack_timer := 0.0
var eliminated := false

func initialize() -> void:
    gravity_scale = 0.0
    lock_rotation = true
    linear_damp = physics_config.linear_damp

    var material := PhysicsMaterial.new()
    material.bounce = physics_config.bounce
    material.friction = 0.0
    physics_material_override = material

    var collision := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = stats.radius
    collision.shape = circle
    add_child(collision)

    var visual := Node2D.new()
    visual.set_script(load("res://scripts/marble/marble_visual.gd"))
    visual.marble = self
    add_child(visual)

    linear_velocity = Vector2.RIGHT.rotated(randf() * TAU) * 80.0
    add_to_group("marbles")

func _physics_process(delta: float) -> void:
    if eliminated:
        return

    attack_timer = maxf(0.0, attack_timer - delta)
    choose_target()

    if is_instance_valid(target) and not target.eliminated:
        var offset: Vector2 = target.global_position - global_position
        if offset.length() > stats.attack_range:
            var desired: Vector2 = offset.normalized() * physics_config.move_speed
            apply_central_force((desired - linear_velocity) * 5.0)
        elif attack_timer <= 0.0 and offset.length() <= stats.attack_range + target.stats.radius:
            target.receive_damage(stats.attack_damage)
            target.apply_central_impulse(offset.normalized() * 90.0)
            attack_timer = stats.attack_cooldown

    var max_speed: float = physics_config.move_speed * 1.35
    if linear_velocity.length() > max_speed:
        linear_velocity = linear_velocity.normalized() * max_speed

    var r: float = stats.radius
    if global_position.x < arena.position.x + r:
        global_position.x = arena.position.x + r
        linear_velocity.x = absf(linear_velocity.x) * physics_config.bounce
    elif global_position.x > arena.end.x - r:
        global_position.x = arena.end.x - r
        linear_velocity.x = -absf(linear_velocity.x) * physics_config.bounce

    if global_position.y < arena.position.y + r:
        global_position.y = arena.position.y + r
        linear_velocity.y = absf(linear_velocity.y) * physics_config.bounce
    elif global_position.y > arena.end.y - r:
        global_position.y = arena.end.y - r
        linear_velocity.y = -absf(linear_velocity.y) * physics_config.bounce

func choose_target() -> void:
    var closest := INF
    target = null
    for candidate in get_tree().get_nodes_in_group("marbles"):
        if candidate == self or candidate.eliminated:
            continue
        var distance: float = global_position.distance_squared_to(candidate.global_position)
        if distance < closest:
            closest = distance
            target = candidate

func receive_damage(amount: float) -> void:
    if eliminated:
        return
    if stats.take_damage(amount):
        eliminated = true
        remove_from_group("marbles")
        collision_layer = 0
        collision_mask = 0
        linear_velocity = Vector2.ZERO
