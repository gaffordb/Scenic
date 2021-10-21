param map = localPath('maps/cubetown.xodr')
param lgsvl_map = 'CubeTown'
param apolloHDMap = 'cubetown'
param time_step = 1

model scenic.simulators.lgsvl.model

egoStartPos = OrientedPoint on road
egoDestination = follow roadDirection from egoStartPos for 100
require egoDestination in road

ego = ApolloCar at egoStartPos,
             with behavior DriveTo(egoDestination)

npc = NPCCar at egoStartPos offset by 3.5 @ 0,
             with behavior FollowWaypoints([Waypoint at egoDestination, with speed Range(6,10)])

require abs(relative heading of npc) <= 20 deg