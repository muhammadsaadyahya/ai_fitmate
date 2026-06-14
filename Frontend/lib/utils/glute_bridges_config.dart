class GluteBridgesConfig {
  final int movingAvgWindow;
  final int streakFramesRequired;
  final double angleTrendThreshold;

  // Rep rules
  final double upMin; // 160 degrees
  final double hyperextendMax; // 185 degrees
  final double downMax; // 125 degrees
  final double leaveFloorMin; // 130 degrees
  final double dropDownMax; // 150 degrees

  // Foot position rules
  final double footTooFarAngle; // 110 degrees
  final double footTooCloseAngle; // 70 degrees

  const GluteBridgesConfig({
    this.movingAvgWindow = 5,
    this.streakFramesRequired = 3,
    this.angleTrendThreshold = 1.0,
    this.upMin = 160,
    this.hyperextendMax = 185,
    this.downMax = 125,
    this.leaveFloorMin = 130,
    this.dropDownMax = 150,
    this.footTooFarAngle = 110,
    this.footTooCloseAngle = 70,
  });
}
