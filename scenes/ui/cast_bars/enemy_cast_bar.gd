# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CanvasLayer
class_name EnemyCastBar

@onready var timer1 : Timer = $Timer1
@onready var timer2 : Timer = $Timer2
@onready var timer3 : Timer = $Timer3
@onready var label1: Label = $MarginContainer/CastBarContainer/CastBar1/Label
@onready var label2: Label = $MarginContainer/CastBarContainer/CastBar2/Label
@onready var label3: Label = $MarginContainer/CastBarContainer/CastBar3/Label
@onready var progress_bar1 : ProgressBar = $MarginContainer/CastBarContainer/CastBar1/ProgressBar
@onready var progress_bar2 : ProgressBar = $MarginContainer/CastBarContainer/CastBar2/ProgressBar
@onready var progress_bar3 : ProgressBar = $MarginContainer/CastBarContainer/CastBar3/ProgressBar
@onready var cast_bar_1 : BoxContainer = $MarginContainer/CastBarContainer/CastBar1
@onready var cast_bar_2 : BoxContainer = $MarginContainer/CastBarContainer/CastBar2
@onready var cast_bar_3 : BoxContainer = $MarginContainer/CastBarContainer/CastBar3

var casting1 := false
var casting2 := false
var casting3 := false


func _process(_delta : float) -> void:
	if (casting1 or casting2 or casting3) and !visible:
		visible = true
	elif not (casting1 or casting2 or casting3) and visible:
		visible = false
	if casting1:
		progress_bar1.value = 1 - (timer1.time_left / timer1.wait_time)
	if casting2:
		progress_bar2.value = 1 - (timer2.time_left / timer2.wait_time)
	if casting3:
		progress_bar3.value = 1 - (timer3.time_left / timer3.wait_time)


func start_cast_bar_1(cast_name : String, cast_time : float) -> void:
	if casting1:
		print("CastBar1 Error: Simultaneous casts.")
		return
	label1.text = cast_name
	progress_bar1.value = 0
	timer1.start(cast_time)
	casting1 = true
	cast_bar_1.visible = true


func start_cast_bar_2(cast_name : String, cast_time : float) -> void:
	if casting2:
		print("CastBar2 Error: Simultaneous casts.")
		return
	label2.text = cast_name
	progress_bar2.value = 0
	timer2.start(cast_time)
	casting2 = true
	cast_bar_2.visible = true


func start_cast_bar_3(cast_name : String, cast_time : float) -> void:
	if casting3:
		print("CastBar3 Error: Simultaneous casts.")
		return
	label3.text = cast_name
	progress_bar3.value = 0
	timer3.start(cast_time)
	casting3 = true
	cast_bar_3.visible = true


func _on_timer_1_timeout() -> void:
	cast_bar_1.visible = false
	casting1 = false


func _on_timer_2_timeout() -> void:
	cast_bar_2.visible = false
	casting2 = false


func _on_timer_3_timeout() -> void:
	cast_bar_3.visible = false
	casting3 = false


func clear_casts() -> void:
	cast_bar_1.visible = false
	casting1 = false
	cast_bar_2.visible = false
	casting2 = false
	cast_bar_3.visible = false
	casting3 = false
