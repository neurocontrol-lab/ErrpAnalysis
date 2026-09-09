"""Read-only audit of the two available subjects' EEG triggers and saved labels."""
from pathlib import Path
import csv
import json
import numpy as np
from scipy.io import loadmat

ROOT = Path(__file__).resolve().parent
OUT = ROOT / 'output' / 'event_audit'
OUT.mkdir(parents=True, exist_ok=True)
summaries, trials = [], []
for subject in ['spe30', 'mle01']:
    for p in sorted((ROOT / 'data' / subject).glob('*.easy')):
        if '_run' not in p.name:
            continue
        a = np.loadtxt(p, usecols=(11, 12), dtype=np.int64)
        ix = np.flatnonzero(a[:, 0])
        codes = a[ix, 0]
        starts = np.flatnonzero(codes == 100)
        runtrials = []
        for j, start in enumerate(starts):
            end = starts[j+1] if j+1 < len(starts) else len(codes)
            ci, si = codes[start:end], ix[start:end]
            if 400 not in ci:
                continue
            pos = {int(c): int(si[np.flatnonzero(ci == c)[0]]) for c in [100,200,300,400,500] if c in ci}
            r = dict(subject=subject, file=p.name, trial=j+1,
                     sequence=' '.join(map(str, ci)), label=2 if 500 in ci else 1,
                     movement_sample_1based=pos[400]+1,
                     displacement_sample_1based=pos.get(500,-1)+1,
                     movement_to_displacement_ms=int(a[pos[500],1]-a[pos[400],1]) if 500 in pos else None,
                     target_to_movement_ms=int(a[pos[400],1]-a[pos[300],1]) if 300 in pos else None)
            runtrials.append(r)
        matpath = ROOT / 'cleanErrPotData' / subject / (p.stem+'.mat')
        info = dict(subject=subject,file=p.name,samples=len(a),
                    event_counts={str(c):int(np.sum(codes==c)) for c in np.unique(codes)},
                    extracted_movement_trials=len(runtrials),
                    timestamp_steps_ms={str(c):int(n) for c,n in zip(*np.unique(np.diff(a[:,1]),return_counts=True))})
        if matpath.exists():
            m = loadmat(matpath,simplify_cells=True)['RunResults']
            labels = np.asarray(m['Labels']).reshape(-1)
            info.update(saved_trials_shape=list(m['CleanTrials'].shape),
                        saved_label_counts={str(c):int(np.sum(labels==c)) for c in np.unique(labels)},
                        labels_match=bool(np.array_equal(labels,[r['label'] for r in runtrials])))
        summaries.append(info)
        trials.extend(runtrials)
        print(subject,p.name,len(runtrials),info.get('labels_match'),flush=True)
with (OUT/'trials.csv').open('w',newline='') as f:
    w=csv.DictWriter(f,fieldnames=list(trials[0])); w.writeheader(); w.writerows(trials)
(OUT/'runs.json').write_text(json.dumps(summaries,indent=2))
for subject in ['spe30','mle01']:
    rs=[r for r in trials if r['subject']==subject]
    ds=[r['movement_to_displacement_ms'] for r in rs if r['label']==2]
    print('SUMMARY',subject,'runs',sum(s['subject']==subject for s in summaries),'trials',len(rs),
          'correct',sum(r['label']==1 for r in rs),'error',len(ds),'delay min/median/max',np.percentile(ds,[0,50,100]),
          'task_sequences',sorted(set(' '.join(c for c in r['sequence'].split() if c in ['100','200','300','400','500']) for r in rs)))
