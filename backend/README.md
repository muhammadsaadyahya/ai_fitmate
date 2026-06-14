# FYP_AI_FIT_MATE

## Project layout

- `Exercises/Saad_Working`: Saad exercise notebooks.
- `Exercises/Talha_Working`: Talha exercise notebooks and video assets.

## One-time setup

```bash
cd /home/talha/Desktop/Ai_Fitmate_FYP/FYP_AI_FIT_MATE
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pip install -r Exercises/Talha_Working/requirements.txt
```

Optional Linux dependency (used by voice features in some notebooks):

```bash
sudo apt update && sudo apt install -y espeak
```

## Daily run

```bash
cd /home/talha/Desktop/Ai_Fitmate_FYP/FYP_AI_FIT_MATE
source .venv/bin/activate
code .
```

Open and run notebooks from:

- `Exercises/Talha_Working/Plank_Counter_Pose_Corrector.ipynb`
- `Exercises/Talha_Working/both_shoulder.ipynb`

## Notes

- Use the `.venv` kernel in Jupyter notebooks.
- Video files for Talha notebooks are stored in `Exercises/Talha_Working/Plank_vids` and `Exercises/Talha_Working/Shoulder_Vids`.
