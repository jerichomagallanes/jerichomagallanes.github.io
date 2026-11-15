#!/bin/zsh
# record.sh <testName> <clip>  — records the visible simulator while one UI test drives it
set -u
UDID=${UDID:-788AD21D-FA6A-4E94-8327-85F40ED8AFDE}; S=/private/tmp/claude-501/-Users-jericho-StudioProjects-Trainr/c7efe0bd-083b-4b4a-b1a2-e87729cca221/scratchpad
cd ~/StudioProjects/Trainr-iOS
xcrun simctl io $UDID recordVideo --codec h264 --force "$S/clips/$2.raw.mp4" > /dev/null 2>&1 &
REC=$!; sleep 1.5; date +%s.%N > "$S/clips/$2.t0"
TRAINR_MODEL="$S/model/lfm25-q4km.gguf" xcodebuild test-without-building -project Trainr.xcodeproj -scheme Trainr -destination "platform=iOS Simulator,id=$UDID" -parallel-testing-enabled NO -only-testing:"TrainrUITests/OnboardingFlowTests/$1" 2>&1 | grep -E "MARK |passed|failed|error:" | grep -v "exit code 0" > "$S/clips/$2.log"
sleep 1; kill -INT $REC; wait $REC 2>/dev/null; echo "$2: $(grep -cE "' passed" "$S/clips/$2.log") passed, $(grep -c MARK "$S/clips/$2.log") marks, $(du -h "$S/clips/$2.raw.mp4" | cut -f1)"
