
param map = localPath('maps/borregasave.xodr')
param lgsvl_map = 'BorregasAve'
param apolloHDMap = 'borregas_ave'
param time_step = 1

model scenic.simulators.lgsvl.model

fourWayIntersection = filter(lambda i: i, network.intersections)

intersec = Uniform(*fourWayIntersection)
ego_startLane = Uniform(*intersec.incomingLanes)

ego_maneuvers = filter(lambda i: i.type == ManeuverType.LEFT_TURN, ego_startLane.maneuvers)
ego_maneuver = Uniform(*ego_maneuvers)
#ego_maneuver = Uniform(*ego_startLane.maneuvers)
ego_trajectory = [ego_maneuver.startLane, ego_maneuver.connectingLane, ego_maneuver.endLane]

egoStartPos = OrientedPoint on ego_maneuver.startLane.centerline

egoDestination = OrientedPoint on ego_maneuver.endLane
require egoDestination in road

ego = ApolloCar at egoStartPos,
             with behavior DriveTo(egoDestination)

