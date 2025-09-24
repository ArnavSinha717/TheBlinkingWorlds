import cv2
import mediapipe as mp
import numpy as np
import pyautogui   # <-- for simulating space press

# Initialize MediaPipe FaceMesh
mp_face_mesh = mp.solutions.face_mesh
face_mesh = mp_face_mesh.FaceMesh(refine_landmarks=True, max_num_faces=1)

# Eye landmark indices (from MediaPipe FaceMesh)
LEFT_EYE = [33, 160, 158, 133, 153, 144]
RIGHT_EYE = [362, 385, 387, 263, 373, 380]

def euclidean_distance(p1, p2):
    return np.linalg.norm(np.array(p1) - np.array(p2))

def eye_aspect_ratio(landmarks, eye_indices, image_w, image_h):
    coords = [(int(landmarks[i].x * image_w), int(landmarks[i].y * image_h)) for i in eye_indices]

    # vertical distances
    v1 = euclidean_distance(coords[1], coords[5])
    v2 = euclidean_distance(coords[2], coords[4])
    # horizontal distance
    h = euclidean_distance(coords[0], coords[3])

    ear = (v1 + v2) / (2.0 * h)
    return ear

# Blink detection parameters
EAR_THRESHOLD = 0.22   # Lower EAR → eyes closed
CONSEC_FRAMES = 3      # Minimum frames for a valid blink

blink_count = 0
frame_counter = 0

# Start webcam (0 = default camera on Windows laptop)
cap = cv2.VideoCapture(0)

while cap.isOpened():
    success, frame = cap.read()
    if not success:
        break

    h, w, _ = frame.shape
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = face_mesh.process(rgb_frame)

    if results.multi_face_landmarks:
        for face_landmarks in results.multi_face_landmarks:
            # Calculate EAR for both eyes
            left_ear = eye_aspect_ratio(face_landmarks.landmark, LEFT_EYE, w, h)
            right_ear = eye_aspect_ratio(face_landmarks.landmark, RIGHT_EYE, w, h)
            ear = (left_ear + right_ear) / 2.0

            # Blink logic
            if ear < EAR_THRESHOLD:
                frame_counter += 1
            else:
                if frame_counter >= CONSEC_FRAMES:
                    blink_count += 1
                    pyautogui.press("space")   # <-- Trigger Spacebar press
                frame_counter = 0

            # Display info on screen
            cv2.putText(frame, f"Blinks: {blink_count}", (30, 60),
                        cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 255), 2)
            cv2.putText(frame, f"EAR: {ear:.2f}", (30, 120),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)

    cv2.imshow('Blink Detection - Laptop Camera', frame)

    if cv2.waitKey(1) & 0xFF == 27:  # ESC key to exit
        break

cap.release()
cv2.destroyAllWindows()
