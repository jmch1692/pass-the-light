extends Node

#TODO: Refactor all signals to use the SignalBus

# System signals
signal increase_level()

#NPC signals
signal npc_saved()
signal npc_lost()

#Maze Signals
signal spawn_points_ready(free_points, start_point, finish_point)

#Traps signals
signal trap_activated(trap)
