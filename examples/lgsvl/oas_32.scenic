# Ego does something at an intersection (left/right/straight)
# cubetown
# original file broken, looked like it was trying to do this
# TODO: define behavior of other car

param map = localPath('maps/cubetown.xodr')
param lgsvl_map = 'CubeTown'
param apolloHDMap = 'cubetown'
param time_step = 1.0

model scenic.simulators.lgsvl.model

fourWayIntersection = filter(lambda i: i, network.intersections)

intersec = Uniform(*fourWayIntersection)

#### ----- Ego Vehicle Spec ----- ####
ego_startLane = Uniform(*intersec.incomingLanes)

ego_maneuvers = ego_startLane.maneuvers
ego_maneuver = Uniform(*ego_maneuvers)
#ego_maneuver = Uniform(*ego_startLane.maneuvers)
ego_trajectory = [ego_maneuver.startLane, ego_maneuver.connectingLane, ego_maneuver.endLane]

egoStartPos = OrientedPoint on ego_maneuver.startLane.centerline

# Constraint to force this stuff to work
# Note: Precedence for > is tighter than `distance from`?
require (distance from egoStartPos to ego_maneuver.startLane.centerline[-1]) > 5
require (distance from egoStartPos to ego_maneuver.startLane.centerline[-1]) < 10


egoDestination = OrientedPoint on ego_maneuver.endLane
require egoDestination in road

ego = ApolloCar at egoStartPos,
             with behavior DriveTo(egoDestination)

#### ----- NPC Vehicle Spec ----- ####
npc_startLane = Uniform(*intersec.incomingLanes)

npc_maneuvers = npc_startLane.maneuvers
npc_maneuver = Uniform(*npc_maneuvers)
npc_trajectory = [npc_maneuver.startLane, npc_maneuver.connectingLane, npc_maneuver.endLane]

npcStartPos = OrientedPoint on npc_maneuver.startLane.centerline

# Constraint to force this stuff to work
# Note: Precedence for > is tighter than `distance from`?
require (distance from npcStartPos to npc_maneuver.startLane.centerline[-1]) > 5
require (distance from npcStartPos to npc_maneuver.startLane.centerline[-1]) < 10

npcDestination = OrientedPoint on npc_maneuver.endLane
require npcDestination in road

#other = Car on npc_maneuver.startLane.centerline,
#		with behavior FollowTrajectoryBehavior(target_speed=15, trajectory=npc_trajectory)

other = Car on npc_maneuver.startLane.centerline,
		with behavior FollowLaneBehavior(target_speed=15)

behavior ApproachAndTurnLeft():
    try:
        do FollowLaneBehavior()
    interrupt when (distance from self to intersection) < 10:
        abort    # cancel lane following
    do WaitForTrafficLightBehavior()
    do TurnLeftBehavior()

#npc = NPCCar at npcStartPos,
#          with behavior FollowWaypoints(waypoints)