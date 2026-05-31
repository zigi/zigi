import re
import shutil
from pathlib import Path
from xmi import create_xmi
import os

# What tag are we on
tag = os.environ.get('RELEASE_TAG', 'UNKNOWN')
# this is a vx.y but we want VxRy
version = tag.upper().replace('.','R')


def convert_release_to_markdown(input_path, output_path):
    lines = Path(input_path).read_text().splitlines()
    out = []
    in_latest = False

    for line in lines:
        stripped = line.strip()

        # Box drawing borders — skip
        if re.match(r'^\*[-\s*]+\*$', stripped):
            continue

        # Box content lines: | content |
        if stripped.startswith('|') and stripped.endswith('|'):
            content = stripped[1:-1].strip()
            if content:
                out.append(f'> {content}')
            continue

        # Separator lines (all = or all -): stop once inside the latest version
        if stripped and (all(c == '=' for c in stripped) or all(c == '-' for c in stripped)):
            if in_latest:
                break
            continue

        # "ZIGI Release Notes" — marks entry into the latest version section
        if stripped == 'ZIGI Release Notes':
            in_latest = True
            out.append(f'\n## {stripped}')
            continue

        # "Version X.XX"
        if re.match(r'^Version \d+\.\d+$', stripped):
            out.append(f'### {stripped}')
            continue

        # Section headers
        if stripped.rstrip(':') in ('New Features and Functions',
                                     'Bug Fixes and Other Updates'):
            out.append(f'\n### {stripped.rstrip(":")}')
            continue

        # "Key changes:     - first item"
        m = re.match(r'^Key changes:\s+-\s+(.+)$', stripped)
        if m:
            out.append(f'\n**Key changes:**\n- {m.group(1)}')
            continue

        # Component bullet: "* name   - description"
        if stripped.startswith('* ') or stripped.startswith('*\t'):
            content = stripped[1:].strip()
            m = re.match(r'^(\S+)\s+-\s+(.+)$', content)
            if m:
                out.append(f'- **{m.group(1)}** — {m.group(2)}')
            else:
                out.append(f'- {content}')
            continue

        # Continuation lines starting with - (indented in source)
        if line.startswith(' ') and stripped.startswith('- '):
            out.append(f'  {stripped}')
            continue

        # Numbered items
        if re.match(r'^\d+[.)]\s+', stripped):
            out.append(f'- {stripped}')
            continue

        # Empty
        if not stripped:
            out.append('')
            continue

        # Everything else verbatim
        out.append(stripped)

    # Collapse runs of 3+ blank lines to 2
    result = re.sub(r'\n{3,}', '\n\n', '\n'.join(out))
    Path(output_path).write_text(result)


outputfile = Path('ZIGI.XMIT')

# Create placeholder folder
Path('temp').mkdir(exist_ok=True)

# Convert release notes to markdown for the GitHub release body
convert_release_to_markdown('ZIGI.RELEASE', 'RELEASE.md')

# Prepend a direct download link to the XMI artifact
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

# Add other repo files (LIC,STARTER and RELEASE, installer) into dist-XMI
shutil.copy('ZIGI.SAMPLES/STARTZIG', 'temp/STUB')
shutil.copy('ZIGI.RELEASE', 'temp/RELEASE')
shutil.copy('ZIGI.GPLLIC', 'temp/GPLLIC')
shutil.copy('ZIGI.EXEC/XMITINST', 'temp/$INSTALL')

# Mash all together into release artefact
create_xmi(Path('temp'),
           output_file=outputfile,
           dsn='ZIGI.XMI',
           from_user="ZIGI",
           from_node="GITHUB",
           message="ZIGI Distribution XMIT, made with xmi-reader")
