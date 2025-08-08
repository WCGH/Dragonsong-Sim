# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

const TANKS = ["Tank 1", "Tank 2"]
const HEALERS = ["Healer 1", "Healer 2"]
const MELEE = ["Melee 1", "Melee 2"]
const RANGED = ["Ranged", "Caster"]
const SUPPORT = TANKS + HEALERS
const DPS = MELEE + RANGED
const ALL_ROLES = SUPPORT + DPS
const ROLE_GROUP_NAMES = {"Tank": TANKS, "Healer": HEALERS, "DPS": DPS}
const ROLE_KEYS = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
const ROLE_NAMES = {"t1": TANKS[0], "t2": TANKS[1],
	"h1": HEALERS[0], "h2": HEALERS[1],
	"m1": MELEE[0], "m2": MELEE[1],
	"r1": RANGED[0], "r2": RANGED[1]}

# General
var debug := false
var deathwall_active := true
var player_role_key : String
var selected_role_index := 4
var selected_sequence_index := 0
# Launcher
var checked_update := false
var launcher_pck_path := ""
var main_menu_path := "res://scenes/encounters/dsr/main_menu.tscn"
# P5
var player_puddles := false
var rare_death_pattern := false
var default_lineup := ["r1", "t1", "r2", "m1", "h2", "t2", "m2", "h1"]
var mana_lineup := ["t1","t2","m1","m2","r1","r2","h1","h2"]
# P6
var hide_bots := false
var vow_target_key := ""

#enum Role {Tank1 = 0, Tank2, Healer1, Healer2, Melee1, Melee2, Ranged, Caster}
#enum Role_Category {Tank, Healer, DPS}
