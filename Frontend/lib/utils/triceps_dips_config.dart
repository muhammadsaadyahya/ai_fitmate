class TricepsDipsConfig {
  final int movingAvgWindow;
  final int streakFramesRequired;
  final double angleTrendThreshold;

  // Rep rules
  final double topLockoutMin; // 160 degrees
  final double topLockoutSoft; // 150 degrees
  final double bottomTargetMax; // 100 degrees
  final double bottomTargetMin; // 80 degrees
  final double bottomStartUp; // 120 degrees

  const TricepsDipsConfig({
    this.movingAvgWindow = 5,
    this.streakFramesRequired = 3,
    this.angleTrendThreshold = 2.0,
    this.topLockoutMin = 160,
    this.topLockoutSoft = 150,
    this.bottomTargetMax = 100,
    this.bottomTargetMin = 80,
    this.bottomStartUp = 120,
  });
}
