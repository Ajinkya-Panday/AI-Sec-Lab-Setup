#!/usr/bin/env bash
# CISF AI Lab - readiness check. Run:  bash ~/CISF_AI_Lab/verify.sh
LAB="$HOME/CISF_AI_Lab"; D="$LAB/data"
have() { [ "$1" = 0 ]; }
chk() { "$@" >/dev/null 2>&1 && echo 0 || echo 1; }
PY=$(chk python3 -c "import csv,json,urllib.request")
FILES=0; for f in emails.csv urls.csv access_log.csv login_features.csv alerts.csv sop_terminal2.txt phishing_samples.txt personal_note.txt agent_inbox/03_vendor_newsletter.txt badge_images/train/valid/valid_01.png; do [ -f "$D/$f" ] || { FILES=1; echo "  missing file: $D/$f"; }; done
OLL=$(chk curl -s --max-time 5 localhost:11434/api/tags)
TAGS=$(curl -s --max-time 5 localhost:11434/api/tags 2>/dev/null)
echo "$TAGS" | grep -q 'qwen2.5:1.5b' && MAIN=0 || MAIN=1
echo "$TAGS" | grep -q 'qwen2.5:0.5b' && SMALL=0 || SMALL=1
ANYM=1; { have $MAIN || have $SMALL; } && ANYM=0
ORA=$(chk "$LAB/orange-venv/bin/python" -c "import Orange, AnyQt")
BR=$(chk command -v firefox); NET=$(chk wget -q --spider --timeout=10 https://playground.tensorflow.org)
row() { local n="$1" t="$2"; shift 2; local s=READY; for v in "$@"; do have "$v" || s="NOT READY"; done; printf "  Lab %-3s %-44s %s\n" "$n" "$t" "$s"; }
echo; echo "================ CISF AI LAB READINESS ================"
echo "  Python: $( have $PY && echo OK || echo MISSING)   Data files: $( have $FILES && echo OK || echo MISSING)   AI engine: $( have $OLL && echo RUNNING || echo 'NOT RUNNING')"
echo "  Main model qwen2.5:1.5b: $( have $MAIN && echo OK || echo 'not yet')   Small model qwen2.5:0.5b: $( have $SMALL && echo OK || echo 'not yet')"
echo "  Orange: $( have $ORA && echo OK || echo 'not yet')   Browser: $( have $BR && echo OK || echo MISSING)   Internet: $( have $NET && echo OK || echo 'NO')"
echo "-------------------------------------------------------"
row 1  "Rules vs Machine Learning"            $PY $FILES
row 2  "Orange: phishing URL classifier"      $ORA $FILES
row 3  "TensorFlow Playground (browser)"      $BR $NET
row 4  "Prompting a local AI"                 $OLL $ANYM
row 5  "Hallucination and RAG"                $PY $OLL $ANYM $FILES
row 6  "UEBA anomaly finder"                  $PY $FILES
row 7  "Orange: clustering"                   $ORA $FILES
row 8  "Orange: outlier detection"            $ORA $FILES
row 9  "AI agent and prompt injection"        $PY $OLL $ANYM $FILES
row 10 "Gandalf prompt-injection game"        $BR $NET
row 11 "Reinforcement learning patrol"        $PY
row 12 "AI phishing and deepfake awareness"   $OLL $ANYM $FILES
row 13 "Supply chain: poisoned model file"    $PY
row 14 "Privacy: redact before you ask"       $PY $FILES
row 15 "SOC alert triage"                     $PY $OLL $ANYM $FILES
row 16 "Teachable Machine (browser)"          $BR $NET $FILES
echo "======================================================="
have $MAIN || echo "  Note: if only the small model is ready, AI labs still run but answers are weaker."
