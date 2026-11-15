#!/bin/zsh
# cut_all.sh — tight cuts: motion starts ~0.5 s in, ends ~0.6 s after the last action. Raw is VFR, so fps=24 before trim.
set -eu
S=/private/tmp/claude-501/-Users-jericho-StudioProjects-Trainr/c7efe0bd-083b-4b4a-b1a2-e87729cca221/scratchpad; OUT=~/StudioProjects/jerichomagallanes.github.io/Trainr/assets/clips
enc() { ffmpeg -v error -y -i "$1" -filter_complex "$2" -map "[v]" -an -c:v libx264 -preset slow -crf 27 -pix_fmt yuv420p -movflags +faststart "$3"; }
poster() { ffmpeg -v error -y -ss "$2" -i "$1" -frames:v 1 -vf "scale=660:-2" "$S/clips/_poster.png"; python3 -c "from PIL import Image; Image.open('$S/clips/_poster.png').save('$3', quality=82)"; }
m() { awk -v t0=$(cat $S/clips/$1.t0) -v k="$2" '$1=="MARK" && $2==k {printf "%.2f", $3 - t0}' $S/clips/$1.log; }
# head offset per clip: the plan test swipes the list up and down before the tap (3.0–6.0 s after the mark), which the clip skips.
for pair in plan:plan:7.0 setup:setup:0.8 session:session:0.8 progress2:progress:0.8; do
  c=${pair%%:*}; r=${pair#*:}; n=${r%%:*}; head=${r##*:}; s=$(python3 -c "print(round($(m $c start)+$head,2))"); e=$(python3 -c "print(round($(m $c end)-0.9,2))"); d=$(python3 -c "print(round($e-$s,2))")
  enc $S/clips/$c.raw.mp4 "[0:v]fps=24,trim=start=$s:duration=$d,setpts=PTS-STARTPTS,scale=660:-2:flags=lanczos[v]" $OUT/$n.mp4; poster $S/clips/$c.raw.mp4 $s $OUT/$n-poster.webp
  printf "  %-9s %5ss→%5ss (%4ss) %s\n" $n $s $e $d "$(du -h $OUT/$n.mp4 | cut -f1)"
done
c=adjust27; s=$(python3 -c "print(round($(m $c start)+0.8,2))"); u=$(python3 -c "print(round($(m $c useNote)+3.8,2))"); r=$(python3 -c "print(round($(m $c read)-0.4,2))"); e=$(python3 -c "print(round($(m $c end)-1.3,2))")
d1=$(python3 -c "print(round($u-$s,2))"); d2=$(python3 -c "print(round($e-$r,2))")
enc $S/clips/$c.raw.mp4 "[0:v]fps=24,split=2[x][y];[x]trim=start=$s:duration=$d1,setpts=(PTS-STARTPTS)/1.35,fps=24[a];[y]trim=start=$r:duration=$d2,setpts=PTS-STARTPTS[b];[a][b]concat=n=2:v=1:a=0,scale=660:-2:flags=lanczos[v]" $OUT/adjust.mp4; poster $S/clips/$c.raw.mp4 $s $OUT/adjust-poster.webp
printf "  %-9s %5ss→%5ss + %5ss→%5ss (%4ss) %s\n" adjust $s $u $r $e $(python3 -c "print(round($d1+$d2,1))") "$(du -h $OUT/adjust.mp4 | cut -f1)"
