# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

signal variable_saved(section: String, key: String, value: Variant)
signal party_ready()


func emit_variable_saved(section: String, key: String, value: Variant) -> void:
	variable_saved.emit(section, key, value)


func emit_party_ready() -> void:
	party_ready.emit()
