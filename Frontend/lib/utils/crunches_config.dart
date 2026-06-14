class CrunchesConfig {
  final int movingAvgWindow;
  final int streakFramesRequired;
  final double angleTrendThreshold;

  // Rep rules
  final double topCrunchMax; // 85 degrees
  final double topCrunchTarget; // 60 degrees
  final double bottomFlatMin; // 115 degrees
  final double bottomFlatTarget; // 140 degrees

  // Neck checking
  final double neckPullThreshold; // 0.65 of baseline

  const CrunchesConfig({
    this.movingAvgWindow = 5,
    this.streakFramesRequired = 3,
    this.angleTrendThreshold = 2.0,
    this.topCrunchMax = 85,
    this.topCrunchTarget = 60,
    this.bottomFlatMin = 115,
    this.bottomFlatTarget = 140,
    this.neckPullThreshold = 0.65,
  });
}
