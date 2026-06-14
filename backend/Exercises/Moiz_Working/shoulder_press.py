import cv2
import mediapipe as mp
import numpy as np
import time
import os
from pathlib import Path
from typing import Tuple, List

# --- CONFIGURATION ---
BASE_DIR = Path(__file__).resolve().parent

# ⚠️ SWITCH BETWEEN WEBCAM AND VIDEO HERE:
# For WEBCAM: Uncomment the line below
VIDEO_SOURCE = 0

# For VIDEO FILE: Uncomment the line below and place your video in "Shoulder_Press_Vids" folder
#VIDEO_SOURCE = str(BASE_DIR / "sh_vid" / "press1.mp4")

WINDOW_NAME = "Shoulder Press: Form & Rep Counter"
SMOOTHING_FACTOR = 0.5  # Higher = smoother but slower response (0.3-0.7 recommended)
MIN_VISIBILITY = 0.6  # Ignore landmarks below this visibility

# --- ANGLE THRESHOLDS ---
# DOWN position: Arms bent, weights at shoulder level (elbow angle ~90°)
STAGE_DOWN_THRESHOLD = 100  # Below this = DOWN position

# UP position: Arms extended overhead (elbow angle ~160°+)
STAGE_UP_THRESHOLD = 150  # Above this = UP position

STREAK_FRAMES_REQUIRED = 3  # Frames required to confirm stage transition (reduces flicker)

# --- FORM THRESHOLDS ---
BACK_ARCH_THRESHOLD = 15  # Degrees: Excessive back arching (lower back angle deviation)
ELBOW_FLARE_MIN = 60  # Minimum shoulder-elbow-hip angle (too narrow = elbows too far forward)
ELBOW_FLARE_MAX = 110  # Maximum shoulder-elbow-hip angle (too wide = elbows flaring out)

# Colors (BGR format)
COLOR_GOOD = (0, 255, 0)  # Green
COLOR_BAD = (0, 0, 255)  # Red
COLOR_WARNING = (0, 255, 255)  # Yellow
COLOR_NEUTRAL = (200, 200, 200)  # Gray

mp_pose = mp.solutions.pose


def calculate_angle(a: List, b: List, c: List) -> float:
    """
    Calculates angle between three points.
    
    Args:
        a: First point [x, y]
        b: Vertex point [x, y]
        c: Third point [x, y]
    
    Returns:
        Angle in degrees (0-180)
    """
    a = np.array(a)
    b = np.array(b)
    c = np.array(c)
    
    radians = np.arctan2(c[1] - b[1], c[0] - b[0]) - np.arctan2(
        a[1] - b[1], a[0] - b[0]
    )
    angle = np.abs(radians * 180.0 / np.pi)
    
    if angle > 180.0:
        angle = 360 - angle
    
    return angle


def landmarks_visible(lm, indices: List[int]) -> bool:
    """
    Return True if all requested landmarks are confidently visible.
    
    Args:
        lm: MediaPipe landmarks object
        indices: List of landmark indices to check
    
    Returns:
        True if all landmarks meet visibility threshold
    """
    return all(lm[i].visibility >= MIN_VISIBILITY for i in indices)


def get_form_status(
    l_elbow_angle: float,
    r_elbow_angle: float,
    l_elbow_alignment: float,
    r_elbow_alignment: float,
    torso_angle: float,
    stage: str
) -> Tuple[str, Tuple[int, int, int]]:
    """
    Determine form status based on angles and stage.
    
    Form Checks:
    1. Back arching (torso angle deviation)
    2. Elbow alignment (not too far forward or flaring out)
    3. Symmetry between left and right arms
    
    Args:
        l_elbow_angle: Left elbow angle
        r_elbow_angle: Right elbow angle
        l_elbow_alignment: Left elbow-shoulder-hip alignment
        r_elbow_alignment: Right elbow-shoulder-hip alignment
        torso_angle: Torso angle (deviation from vertical)
        stage: Current stage ("up" or "down")
    
    Returns:
        Tuple of (feedback_message, color)
    """
    
    # 1. CHECK BACK ARCHING (Critical - always check)
    if 180 - torso_angle > BACK_ARCH_THRESHOLD:
        return "Don't Arch Back! Engage Core", COLOR_BAD
    
    # 2. CHECK ELBOW ALIGNMENT (Only during UP phase when form matters most)
    if stage == "up" or (l_elbow_angle > 120 or r_elbow_angle > 120):
        # Check if elbows are too far forward
        if l_elbow_alignment < ELBOW_FLARE_MIN or r_elbow_alignment < ELBOW_FLARE_MIN:
            return "Keep Elbows Back!", COLOR_WARNING
        
        # Check if elbows are flaring out too much
        if l_elbow_alignment > ELBOW_FLARE_MAX or r_elbow_alignment > ELBOW_FLARE_MAX:
            return "Don't Flare Elbows Out!", COLOR_WARNING
    
    # 3. CHECK SYMMETRY (Both arms should be roughly the same angle)
    angle_diff = abs(l_elbow_angle - r_elbow_angle)
    if angle_diff > 25:  # More than 25° difference
        return "Uneven Arms! Balance Weight", COLOR_WARNING
    
    # 4. GOOD FORM
    return "Perfect Form", COLOR_GOOD


def main() -> None:
    """Main function to run shoulder press detection."""
    
    # Validate video source
    if VIDEO_SOURCE != 0 and not os.path.exists(VIDEO_SOURCE):
        print(f"⚠️ Warning: Video file not found at {VIDEO_SOURCE}")
        print(f"Attempting to use webcam instead...")
        cap = cv2.VideoCapture(0)
    else:
        cap = cv2.VideoCapture(VIDEO_SOURCE)
    
    if not cap.isOpened():
        print("❌ Error: Cannot open video source.")
        return
    
    # Calculate FPS for proper delay
    fps = cap.get(cv2.CAP_PROP_FPS)
    if fps == 0 or fps > 120:
        fps = 30  # Default to 30fps
    delay = int(1000 / fps)
    
    # --- REP COUNTER VARIABLES ---
    reps = 0
    stage = "down"  # Start in down position
    
    # --- SMOOTHING VARIABLES ---
    prev_l_elbow = 0
    prev_r_elbow = 0
    prev_l_alignment = 90
    prev_r_alignment = 90
    prev_torso = 180
    
    # --- STATE VARIABLES ---
    l_elbow_angle = r_elbow_angle = 0.0
    l_elbow_alignment = r_elbow_alignment = 90.0
    torso_angle = 180.0
    
    # --- DEBOUNCING VARIABLES (Prevents flickering) ---
    up_streak = 0
    down_streak = 0
    
    print(f"🎥 Video Source: {VIDEO_SOURCE}")
    print(f"📊 FPS: {fps}")
    print(f"⌨️  Press 'q' to quit\n")
    
    with mp_pose.Pose(
        min_detection_confidence=0.6,
        min_tracking_confidence=0.6
    ) as pose:
        
        while cap.isOpened():
            ret, frame = cap.read()
            
            if not ret:
                # If video ends, loop it (comment out for webcam to just break)
                if VIDEO_SOURCE != 0:
                    cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
                    continue
                else:
                    break
            
            # --- RESIZE FRAME ---
            frame = cv2.resize(frame, (900, 600))
            
            # --- CREATE UI CANVAS (Frame + Stats Panel) ---
            final_image = np.zeros((600, 1300, 3), dtype=np.uint8)
            final_image[0:600, 0:900] = frame
            
            # --- PROCESS FRAME ---
            h, w, _ = frame.shape
            rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = pose.process(rgb)
            
            feedback = "Stand in frame..."
            color_status = COLOR_NEUTRAL
            
            if results.pose_landmarks:
                lm = results.pose_landmarks.landmark
                
                # Check if key landmarks are visible
                # Landmarks: 11=L_SHOULDER, 12=R_SHOULDER, 13=L_ELBOW, 14=R_ELBOW, 
                #            15=L_WRIST, 16=R_WRIST, 23=L_HIP, 24=R_HIP
                visibility_ok = landmarks_visible(lm, [11, 12, 13, 14, 15, 16, 23, 24])
                
                if visibility_ok:
                    # --- 1. EXTRACT LANDMARK COORDINATES ---
                    l_shoulder = [lm[11].x * w, lm[11].y * h]
                    l_elbow = [lm[13].x * w, lm[13].y * h]
                    l_wrist = [lm[15].x * w, lm[15].y * h]
                    l_hip = [lm[23].x * w, lm[23].y * h]
                    
                    r_shoulder = [lm[12].x * w, lm[12].y * h]
                    r_elbow = [lm[14].x * w, lm[14].y * h]
                    r_wrist = [lm[16].x * w, lm[16].y * h]
                    r_hip = [lm[24].x * w, lm[24].y * h]
                    
                    # --- 2. CALCULATE RAW ANGLES ---
                    
                    # ELBOW ANGLES (Primary metric for rep counting)
                    # Shoulder -> Elbow -> Wrist
                    raw_l_elbow = calculate_angle(l_shoulder, l_elbow, l_wrist)
                    raw_r_elbow = calculate_angle(r_shoulder, r_elbow, r_wrist)
                    
                    # ELBOW ALIGNMENT (Form check: elbow position relative to body)
                    # Hip -> Shoulder -> Elbow
                    raw_l_alignment = calculate_angle(l_hip, l_shoulder, l_elbow)
                    raw_r_alignment = calculate_angle(r_hip, r_shoulder, r_elbow)
                    
                    # TORSO ANGLE (Back arching check)
                    mid_hip = [
                        (l_hip[0] + r_hip[0]) / 2,
                        (l_hip[1] + r_hip[1]) / 2,
                    ]
                    mid_shoulder = [
                        (l_shoulder[0] + r_shoulder[0]) / 2,
                        (l_shoulder[1] + r_shoulder[1]) / 2,
                    ]
                    vertical_point = [mid_hip[0], mid_hip[1] + 100]  # Point below hip
                    raw_torso = calculate_angle(mid_shoulder, mid_hip, vertical_point)
                    
                    # --- 3. APPLY SMOOTHING (Reduces jitter) ---
                    if prev_l_elbow == 0:  # First frame initialization
                        prev_l_elbow = raw_l_elbow
                        prev_r_elbow = raw_r_elbow
                        prev_l_alignment = raw_l_alignment
                        prev_r_alignment = raw_r_alignment
                        prev_torso = raw_torso
                    
                    l_elbow_angle = (prev_l_elbow * (1 - SMOOTHING_FACTOR)) + (
                        raw_l_elbow * SMOOTHING_FACTOR
                    )
                    r_elbow_angle = (prev_r_elbow * (1 - SMOOTHING_FACTOR)) + (
                        raw_r_elbow * SMOOTHING_FACTOR
                    )
                    l_elbow_alignment = (prev_l_alignment * (1 - SMOOTHING_FACTOR)) + (
                        raw_l_alignment * SMOOTHING_FACTOR
                    )
                    r_elbow_alignment = (prev_r_alignment * (1 - SMOOTHING_FACTOR)) + (
                        raw_r_alignment * SMOOTHING_FACTOR
                    )
                    torso_angle = (prev_torso * (1 - SMOOTHING_FACTOR)) + (
                        raw_torso * SMOOTHING_FACTOR
                    )
                    
                    # Update previous values
                    prev_l_elbow = l_elbow_angle
                    prev_r_elbow = r_elbow_angle
                    prev_l_alignment = l_elbow_alignment
                    prev_r_alignment = r_elbow_alignment
                    prev_torso = torso_angle
                    
                    # --- 4. CHECK FORM ---
                    feedback, color_status = get_form_status(
                        l_elbow_angle,
                        r_elbow_angle,
                        l_elbow_alignment,
                        r_elbow_alignment,
                        torso_angle,
                        stage
                    )
                    
                    # --- 5. REP COUNTING WITH DEBOUNCING ---
                    # Average of both elbows for more stable counting
                    avg_elbow = (l_elbow_angle + r_elbow_angle) / 2
                    
                    # Check for UP position
                    if avg_elbow > STAGE_UP_THRESHOLD:
                        up_streak += 1
                        down_streak = 0
                        if stage == "down" and up_streak >= STREAK_FRAMES_REQUIRED:
                            stage = "up"
                    
                    # Check for DOWN position
                    elif avg_elbow < STAGE_DOWN_THRESHOLD:
                        down_streak += 1
                        up_streak = 0
                        if stage == "up" and down_streak >= STREAK_FRAMES_REQUIRED:
                            stage = "down"
                            reps += 1  # Rep counted when returning to down position
                    
                    # In between (transition zone)
                    else:
                        # Don't reset streaks completely, just don't increment
                        pass
                    
                    # --- 6. DRAW SKELETON ON FRAME ---
                    # Draw lines connecting joints
                    connections = [
                        (l_shoulder, l_hip),
                        (r_shoulder, r_hip),
                        (l_shoulder, l_elbow),
                        (l_elbow, l_wrist),
                        (r_shoulder, r_elbow),
                        (r_elbow, r_wrist),
                        (l_shoulder, r_shoulder),  # Shoulder line
                        (l_hip, r_hip),  # Hip line
                    ]
                    
                    for p1, p2 in connections:
                        cv2.line(
                            final_image,
                            tuple(np.array(p1, int)),
                            tuple(np.array(p2, int)),
                            (255, 255, 255),
                            2,
                        )
                    
                    # Draw joint circles (color-coded by form status)
                    joint_points = [l_elbow, r_elbow, l_shoulder, r_shoulder, l_wrist, r_wrist]
                    for pt in joint_points:
                        cv2.circle(
                            final_image,
                            tuple(np.array(pt, int)),
                            6,
                            color_status,
                            -1,
                        )
                    
                else:
                    feedback = "Move fully into frame"
                    color_status = COLOR_WARNING
            
            # --- 7. DRAW STATS PANEL ---
            panel_x = 930
            
            # Rep Counter (Large and prominent)
            cv2.putText(
                final_image,
                "REPS:",
                (panel_x, 60),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.8,
                (255, 255, 255),
                2,
            )
            cv2.putText(
                final_image,
                str(reps),
                (panel_x, 120),
                cv2.FONT_HERSHEY_SIMPLEX,
                2.0,
                color_status,
                3,
            )
            
            # Stage Indicator
            cv2.putText(
                final_image,
                f"STAGE: {stage.upper()}",
                (panel_x, 170),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.7,
                (255, 255, 255),
                2,
            )
            
            # Angle Metrics (for debugging/monitoring)
            cv2.putText(
                final_image,
                "ANGLES:",
                (panel_x, 240),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.6,
                (255, 255, 255),
                1,
            )
            cv2.putText(
                final_image,
                f"L ELBOW: {int(l_elbow_angle)}°",
                (panel_x, 280),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.6,
                (255, 255, 255),
                1,
            )
            cv2.putText(
                final_image,
                f"R ELBOW: {int(r_elbow_angle)}°",
                (panel_x, 310),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.6,
                (255, 255, 255),
                1,
            )
            cv2.putText(
                final_image,
                f"AVG: {int((l_elbow_angle + r_elbow_angle) / 2)}°",
                (panel_x, 340),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.6,
                (180, 180, 180),
                1,
            )
            
            # Alignment metrics
            cv2.putText(
                final_image,
                f"L ALIGN: {int(l_elbow_alignment)}°",
                (panel_x, 380),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.5,
                (150, 150, 150),
                1,
            )
            cv2.putText(
                final_image,
                f"R ALIGN: {int(r_elbow_alignment)}°",
                (panel_x, 405),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.5,
                (150, 150, 150),
                1,
            )
            
            # Form Feedback (Large and colored)
            cv2.putText(
                final_image,
                "FEEDBACK:",
                (panel_x, 480),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.7,
                (255, 255, 255),
                2,
            )
            
            # Word wrap feedback if too long
            feedback_lines = [feedback[i:i+18] for i in range(0, len(feedback), 18)]
            for i, line in enumerate(feedback_lines[:2]):  # Max 2 lines
                cv2.putText(
                    final_image,
                    line,
                    (panel_x - 5, 530 + i * 30),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.7,
                    color_status,
                    2,
                )
            
            # --- 8. DISPLAY FRAME ---
            cv2.imshow(WINDOW_NAME, final_image)
            
            # Exit on 'q' press
            if cv2.waitKey(delay) & 0xFF == ord("q"):
                break
    
    # Cleanup
    cap.release()
    cv2.destroyAllWindows()
    
    print(f"\n✅ Session Complete!")
    print(f"📊 Total Reps: {reps}")


if __name__ == "__main__":
    main()