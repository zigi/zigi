import shutil
from pathlib import Path
from xmi import create_xmi



outputfile = Path('ZIGI.XMIT')

# Create placeholder folder
Path('temp').mkdir(exist_ok=True) 

# Create XMI for EXEC
create_xmi(Path('ZIGI.EXEC'), 
           output_file=Path('temp/EXEC'),
           dsn='LBDYCK.ZIGING.EXEC',
           from_user="ZIGI",
           from_node="GITHUB")

# Create XMI for PANELS
create_xmi(Path('ZIGI.PANELS'), 
           output_file=Path('temp/PANELS'),
           dsn='LBDYCK.ZIGING.PANELS',
           from_user="ZIGI",
           from_node="GITHUB")

# Create XMI for SAMPLES
create_xmi(Path('ZIGI.SAMPLES'), 
           output_file=Path('temp/SAMPLES'),
           dsn='LBDYCK.ZIGING.SAMPLES',
           from_user="ZIGI",
           from_node="GITHUB")

# Add other repo files (LIC,STARTER and RELEASE) into dist-XMI
shutil.copy('ZIGI.GPLLIC', 'temp/GPLLIC')
shutil.copy('ZIGI.SAMPLES/STARTZIG', 'temp/STUB')
shutil.copy('ZIGI.RELEASE', 'temp/RELEASE')

# Mash all together into release artefact
create_xmi(Path('temp'), 
           output_file=outputfile,
           dsn='ZIGI.XMI',
           from_user="ZIGI",
           from_node="GITHUB", 
           message="ZIGI Distribution XMIT, made with xmi-reader")

