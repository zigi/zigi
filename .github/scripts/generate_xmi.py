import shutil
from pathlib import Path
from xmi import create_xmi
import os

# What tag are we on (e.g. v3r29 -> V3R29 for DSN use)
tag = os.environ.get('RELEASE_TAG', 'UNKNOWN')
version = tag.upper()

outputfile = Path('ZIGI.XMIT')

# Create placeholder folder
Path('temp').mkdir(exist_ok=True)

# Start with empty release body - header is prepended below
Path('RELEASE.md').write_text('')

# Prepend a direct download link and installation instructions
repo = os.environ.get('GITHUB_REPOSITORY', '')
if repo and tag != 'UNKNOWN':
    xmit_url = f'https://github.com/{repo}/releases/download/{tag}/ZIGI.XMIT'
    header = (
        f'**Download ZIGI.XMIT:** [{tag}]({xmit_url})\n\n'
        '### Installation\n\n'
        '1. Transfer `ZIGI.XMIT` to z/OS in **binary** mode\n'
        '2. Receive it: `RECEIVE INDSNAME(your.hlq.ZIGI.XMIT)`\n'
        '3. Execute the `$INSTALL` member from the received PDS\n\n'
    )
    release_md = Path('RELEASE.md')
    release_md.write_text(header + release_md.read_text())

# Copy license file into temp
shutil.copy('ZIGI.GPLLIC', 'temp/GPLLIC')

# Create XMI for EXEC
create_xmi(Path('ZIGI.EXEC'),
           output_file=Path('temp/EXEC'),
           dsn=f'ZIGI.{version}.EXEC',
           from_user="ZIGI",
           from_node="GITHUB")

# Create XMI for PANELS
create_xmi(Path('ZIGI.PANELS'),
           output_file=Path('temp/PANELS'),
           dsn=f'ZIGI.{version}.PANELS',
           from_user="ZIGI",
           from_node="GITHUB")

# Create XMI for SAMPLES
create_xmi(Path('ZIGI.SAMPLES'),
           output_file=Path('temp/SAMPLES'),
           dsn=f'ZIGI.{version}.SAMPLES',
           from_user="ZIGI",
           from_node="GITHUB")

# Add other repo files (LIC, STARTER, RELEASE, README, installer) into dist-XMI
shutil.copy('ZIGI.SAMPLES/STARTZIG', 'temp/STUB')
shutil.copy('ZIGI.RELEASE', 'temp/RELEASE')
shutil.copy('ZIGI.README', 'temp/$README')
shutil.copy('ZIGI.GPLLIC', 'temp/GPLLIC')
shutil.copy('ZIGI.EXEC/XMITINST', 'temp/$INSTALL')

# Mash all together into release artefact
create_xmi(Path('temp'),
           output_file=outputfile,
           dsn='ZIGI.XMI',
           from_user="ZIGI",
           from_node="GITHUB",
           message=f"ZIGI {tag} Distribution XMIT, made with xmi-reader")
