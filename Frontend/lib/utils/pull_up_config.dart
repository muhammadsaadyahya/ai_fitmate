class PullUpConfig {
  const PullUpConfig({
    this.movingAvgWindow = 5,
    this.streakFramesRequired = 3,
    this.elbowBottomMin = 160.0,
    this.elbowHalfMin = 155.0,
    this.elbowTopMax = 60.0,
    this.hipStraightMin = 165.0,
    this.ankleSwingRatio = 0.08,
    this.unevenDiffThreshold = 20.0,
    this.unevenStreakRequired = 4,
  });

  final int movingAvgWindow;
  final int streakFramesRequired;
  final double elbowBottomMin;
  final double elbowHalfMin;
  final double elbowTopMax;
  final double hipStraightMin;
  final double ankleSwingRatio;
  final double unevenDiffThreshold;
  final int unevenStreakRequired;
}
