# TODO NOTE: Pedestrian stuff is kinda junked up

param map = localPath('maps/borregasave.xodr')
param lgsvl_map = 'BorregasAve'
param apolloHDMap = 'borregas_ave'
param time_step = 1

model scenic.simulators.lgsvl.model

PEDESTRIAN_MIN_SPEED = 1
THRESHOLD = 17
fourWayIntersection = filter(lambda i: i, network.intersections)

behavior PedestrianBehavior(min_speed=1, threshold=10, waypoints=[]):
    #do CrossingBehavior(ego, min_speed, threshold)
    take FollowWaypointsAction(waypoints)

intersec = Uniform(*fourWayIntersection)
ego_startLane = Uniform(*intersec.incomingLanes)

ego_maneuvers = filter(lambda i: i.type == ManeuverType.RIGHT_TURN, ego_startLane.maneuvers)
ego_maneuver = Uniform(*ego_maneuvers)
#ego_maneuver = Uniform(*ego_startLane.maneuvers)
ego_trajectory = [ego_maneuver.startLane, ego_maneuver.connectingLane, ego_maneuver.endLane]

egoStartPos = OrientedPoint on ego_maneuver.startLane.centerline

# Constraint to force this stuff to work
# Note: Precedence for > is tighter than `distance from`?
require (distance from egoStartPos to ego_maneuver.startLane.centerline[-1]) > 5

egoDestination = OrientedPoint on ego_maneuver.endLane
require egoDestination in road

ped_start = OrientedPoint on ego_maneuver.endLane

require (distance from ped_start to ego_maneuver.endLane.centerline[1]) < 2

ped_head =  (90 deg) relative to egoDestination.heading
wayp = [Waypoint following roadDirection from ped_start for 1, with speed(Range(5,8))]

ego = ApolloCar at egoStartPos,
             with behavior DriveTo(egoDestination)
ped = Pedestrian at ped_start,
    with regionContainedIn ego_maneuver.endLane,
    with heading ped_head,
    with behavior FollowWaypoints(wayp)
