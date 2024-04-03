# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CanvasLayer
class_name CloneCastBar

@onready var timer: Timer = $Timer
@onready var label1: Label = $MarginContainer/CastBarContainer/CastBar1/Label
@onready var label2: Label = $MarginContainer/CastBarContainer/CastBar2/Label
@onready var label3: Label = $MarginContainer/CastBarContainer/CastBar3/Label
@onready var progress_bar1: ProgressBar = $MarginContainer/CastBarContainer/CastBar1/ProgressBar
@onready var progress_bar2: ProgressBar = $MarginContainer/CastBarContainer/CastBar2/ProgressBar
@onready var progress_bar3: ProgressBar = $MarginContainer/CastBarContainer/CastBar3/ProgressBar

var casting := false


func _process(_delta: float) -> void:
	if casting:
		progress_bar1.value = 1 - (timer.time_left / timer.wait_time)
		progress_bar2.value = 1 - (timer.time_left / timer.wait_time)
		progress_bar3.value = 1 - (timer.time_left / timer.wait_time)


func cast_clone(cast_name : String, cast_time : float) -> void:
	if casting:
		print("CastBar Error: Simultaneous casts.")
		return
	label1.text = cast_name
	label2.text = cast_name
	label3.text = cast_name
	progress_bar1.value = 0
	progress_bar2.value = 0
	progress_bar3.value = 0
	timer.start(cast_time)
	casting = true
	visible = true


func _on_timer_timeout() -> void:
	visible = false
	casting = false

