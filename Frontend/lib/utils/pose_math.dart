import 'dart:math' as math;
import 'dart:ui';

class PoseMath {
  static double calculateAngle(Offset p1, Offset p2, Offset p3) {
    // p1 = a, p2 = b (vertex), p3 = c
    final radians =
        math.atan2(p3.dy - p2.dy, p3.dx - p2.dx) -
        math.atan2(p1.dy - p2.dy, p1.dx - p2.dx);

    double angle = (radians * 180.0 / math.pi).abs();

    if (angle > 180.0) {
      angle = 360 - angle;
    }

    return angle;
  }

  static double calculateAngle3D(
    double aX,
    double aY,
    double aZ,
    double bX,
    double bY,
    double bZ,
    double cX,
    double cY,
    double cZ,
  ) {
    // ba = a - b
    // bc = c - b
    final baX = aX - bX;
    final baY = aY - bY;
    final baZ = aZ - bZ;

    final bcX = cX - bX;
    final bcY = cY - bY;
    final bcZ = cZ - bZ;

    final dot = baX * bcX + baY * bcY + baZ * bcZ;
    final normBA = math.sqrt(baX * baX + baY * baY + baZ * baZ);
    final normBC = math.sqrt(bcX * bcX + bcY * bcY + bcZ * bcZ);

    if (normBA == 0 || normBC == 0) return 0.0;

    double cosTheta = dot / (normBA * normBC);
    cosTheta = cosTheta.clamp(-1.0, 1.0);

    return (math.acos(cosTheta) * 180.0 / math.pi);
  }
}
