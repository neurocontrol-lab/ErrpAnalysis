from pathlib import Path
import csv
from reportlab.pdfgen import canvas
from reportlab.lib import colors
from reportlab.lib.utils import ImageReader
from reportlab.platypus import Paragraph, Table, TableStyle
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.enums import TA_LEFT

ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
PDF=OUT/'Perdikis_initial_EEG_findings.pdf'
FIG=ROOT/'output/pipeline_v1/figures'
W,H=595.28,841.89
c=canvas.Canvas(str(PDF),pagesize=(W,H))
c.setTitle('Ballistic mouse movements: initial EEG findings')
c.setAuthor('Project analysis report prepared for Prof. Serafeim Perdikis')
navy=colors.HexColor('#17344c'); muted=colors.HexColor('#526675')
body=ParagraphStyle('body',fontName='Helvetica',fontSize=10,leading=14,textColor=navy)
small=ParagraphStyle('small',parent=body,fontSize=8.5,leading=11.5)
page=0
def start(title,kicker='INITIAL EEG ANALYSIS | 10 SEPTEMBER 2026'):
 global page,y
 page+=1
 c.setFillColor(muted); c.setFont('Helvetica',8); c.drawString(38,H-35,kicker)
 c.setFillColor(navy); c.setFont('Helvetica-Bold',20); c.drawString(38,H-67,title)
 c.setStrokeColor(colors.HexColor('#cad5dc')); c.line(38,H-80,W-38,H-80)
 y=H-99
def para(text,style=body,gap=9):
 global y
 p=Paragraph(text,style); _,h=p.wrap(W-76,1000)
 assert y-h>45,(page,text[:60],y,h)
 p.drawOn(c,38,y-h); y-=h+gap
def heading(t):
 global y
 y-=4; c.setFillColor(navy); c.setFont('Helvetica-Bold',12); c.drawString(38,y,t); y-=19
def end():
 c.setFillColor(muted); c.setFont('Helvetica',8)
 c.drawString(38,25,'Ballistic mouse movement EEG | Preliminary analysis')
 c.drawRightString(W-38,25,str(page)); c.showPage()
def table(rows,widths):
 global y
 t=Table(rows,colWidths=widths,hAlign='LEFT'); t.setStyle(TableStyle([
 ('BACKGROUND',(0,0),(-1,0),navy),('TEXTCOLOR',(0,0),(-1,0),colors.white),
 ('FONTNAME',(0,0),(-1,0),'Helvetica-Bold'),('FONTNAME',(0,1),(-1,-1),'Helvetica'),
 ('FONTSIZE',(0,0),(-1,-1),9),('BOTTOMPADDING',(0,0),(-1,-1),8),
 ('TOPPADDING',(0,0),(-1,-1),8),('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.HexColor('#eef3f6'),colors.white]),
 ('LINEBELOW',(0,-1),(-1,-1),.4,colors.HexColor('#cad5dc'))]))
 _,h=t.wrap(W-76,1000); t.drawOn(c,38,y-h); y-=h+14

start('Ballistic mouse movements: EEG findings')
para('<b>Prepared for Prof. Serafeim Perdikis</b><br/>Initial event audit and session-separated analysis of the available dataset.')
heading('Scope and principal findings')
para('A new MATLAB pipeline processed <b>380 run recordings from 25 participants</b>. Pre, post and retest were analysed separately. Event validation retained 35,210 trial sequences; subsequent quality rules retained <b>30,353 two-second epochs</b>. Twenty-three runs had no validated trials. S1 denotes spe30 and S2 denotes mle01.')
para('<b>A confirmed label discrepancy was recovered.</b> In mle01 retest run 3 (13 November 2018), trials 76 and 78 contain displacement marker 500 and a 400-pixel leftward target jump in the mouse log, but their legacy labels are 1 (non-displaced). Their raw EEG segments match the saved epochs. The new metadata labels both as 2 (displaced); both are excluded from averaging because of data-loss overlap.')
para('<b>The derived event parser missed nonzero-to-nonzero transitions.</b> A zero-to-nonzero rule reproduces all 398 legacy event-list entries for that run, explaining omission of 255-to-500 transitions. The original generating source was not found. Code 255 denotes data loss; the displacement markers themselves survive in the raw and saved trigger vectors.')
para('<b>Recorded event timing warrants clarification.</b> The earlier S1/S2 EEG audit found median 400-to-500 marker intervals of 84 ms and 70 ms, respectively, exceeding the short paper\'s stated maximum 6 ms. Mouse logs corroborate nonzero intervals. These are software-marker intervals, not independent measurements of physical movement or screen onset.')
heading('Accepted epochs contributing to figures')
table([['Dataset','Pre','Post','Retest'],['S1 / spe30','496','498','393'],['S2 / mle01','475','335','374'],['All participants','9,691','10,600','10,062']],[190,107,107,115])
para('<b>Group inference remains preliminary.</b> All 25 participants contribute to each session average, with equal participant weights. No group channel-time comparison survives the specified Bonferroni correction (0.05/8,000) in any session. This does not establish absence of an effect, but these results do not yet support a statistically significant group ErrP claim under this test.',small)
end()

start('How the figures were produced')
for title,text in [
 ('1 | Identify events and validate conditions','Raw EEG: 500 Hz, eight channels; column 12 contains markers. Task codes: 100 new trial/preparation; 200 likely fixation cue (exact display action provisional); 300 initial target; 400 movement onset; 500 target displacement. Recognize changes of marker value, including 255-to-500, and collapse repeated samples of the same marker. Match same-day mouse logs and validate event order, timing and target jumps. Keep ambiguous/incomplete trials flagged.'),
 ('2 | Filter and extract two-second epochs','Convert EEG from nV to microvolts. Split continuous data at 255 flags, nonfinite samples and timestamp gaps. Apply a fourth-order Butterworth 1-20 Hz bandpass forward/backward within each valid segment. Extract movement-locked epochs from -1.000 to +0.998 s (1,000 samples). Subtract each channel\'s -200 to 0 ms mean. Reject absolute amplitudes above 100 microvolts and epochs within a two-second guard of segment edges/gaps. Preserve rejected rows and reasons.'),
 ('3 | Average separately by participant and session','For each participant/session, average accepted non-displaced and displaced trials separately; calculate displaced minus non-displaced. Individual significance uses two-sided equal-variance unpaired trial-level t-tests, with Bonferroni across 8 channels x 1,000 samples within that participant/session. Recording date and run remain in metadata; repeated dates of a session type are combined.'),
 ('4 | Combine participant means','Average the 25 participant-level condition means with equal weights, separately for pre, post and retest. Paired tests operate on participant mean differences; correction is across 8,000 comparisons within each session, not across the three sessions. Grey shading is +/-1 SEM of participant differences. At least two trials per condition are required; two pre contributors have only 10 and 11 total accepted trials (rle13 and vco27).')]:
 heading(title); para(text,small,7)
heading('Interpretation and next checks')
para('This is a new baseline analysis, not an exact reproduction: FORCe/ICA was not applied; baseline, absolute-amplitude rejection and gap guards differ from the legacy workflow. The guard is a conservative heuristic. Class labels describe displacement, not task failure or demonstrated ErrP presence. Assess sensitivity to low-count participants, recover missing/ambiguous logs and original cleaning settings, and clarify 400/500 timing before classification or stimulation-effect claims.',small)
para('<b>Sources:</b> GBCIC2024_paper_97.pdf; raw .easy/.info and mouse CSV files; legacy RunResults and trialextraction.m; new Code/config.m and stages 01-04. Code 255: Neuroelectrics NIC manual, section VII, <link href="https://www.neuroelectrics.com/api/downloads/NE_P3_UM004_EN_NIC2.1.0_1.pdf" color="#176b8f">NIC file formats</link>. Outputs: output/pipeline_v1. Meeting audio was not used. No original recordings or legacy label files were changed.',small)
end()

counts=list(csv.DictReader((FIG/'by_session/session_counts.csv').open()))
groups=list(csv.DictReader((FIG/'group_sessions/group_counts.csv').open()))
for subject,label in [('spe30','S1 / spe30'),('mle01','S2 / mle01'),(None,'All participants')]:
 for session in ['pre','post','retest']:
  start(f'{label} | {session.capitalize()}')
  if subject:
   r=next(r for r in counts if r['subject']==subject and r['session']==session)
   file=FIG/'by_session'/f'{subject}_{session}_averages.png'
   caption=f"Accepted trials: {r['nonDisplaced']} non-displaced; {r['displaced']} displaced. Gold markers indicate trial-level Bonferroni significance."
  else:
   r=next(r for r in groups if r['session']==session)
   file=FIG/'group_sessions'/f'{session}_group_average.png'
   caption=f"N={r['subjects']} equally weighted participants; {r['nonDisplacedTrials']} non-displaced and {r['displacedTrials']} displaced trials in total. Grey: +/-1 SEM of participant differences. No paired comparison survives Bonferroni correction."
  para(caption,small)
  image=ImageReader(str(file)); iw,ih=image.getSize(); avail=y-96
  scale=min((W-76)/iw,avail/ih); dw,dh=iw*scale,ih*scale
  c.drawImage(image,(W-dw)/2,y-dh,width=dw,height=dh,mask='auto'); y-=dh+10
  para('Blue: non-displaced. Red: displaced. Black: displaced minus non-displaced. Time zero is movement marker 400; the green reference line marks +0.5 s. Amplitudes are in microvolts.',small)
  end()
c.save()
print(PDF)
