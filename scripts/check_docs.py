#!/usr/bin/env python3
"""Check SDD references and localization parity. Run from any directory.
Input: repository docs/ and App/Resources/. Output: stdout, exit 1 on errors.
Fix the named missing file, ID or translation before retrying.
"""
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
errors = []

def require(condition, message):
    if not condition:
        errors.append(message)


def exists(path):
    target = (ROOT / path).resolve()
    return target.is_relative_to(ROOT) and target.exists()


def main():
    for file in ['README.md', 'README.en.md', 'AGENTS.md', 'LICENSE',
                 'docs/README.md', 'docs/specs/product.md', 'docs/specs/state-model.md']:
        require(exists(file), f'Missing {file}')
    rows = json.loads((ROOT / 'docs/specs/requirements.json').read_text())
    ids = [row['id'] for row in rows]
    require(len(ids) == len(set(ids)), 'Duplicate requirement ID')
    product = (ROOT / 'docs/specs/product.md').read_text()
    for row in rows:
        rid = row['id']
        require(re.fullmatch(r'FB-\d{3}', rid), f'Invalid ID: {rid}')
        require(rid in product, f'{rid}: absent in specification')
        require(row['status'] in ['planned', 'partial', 'implemented', 'deferred'], f'{rid}: invalid status')
        require(exists(row['spec']), f'{rid}: missing spec')
        require(exists(f"docs/iterations/{row['iteration']}/manifest.json"), f'{rid}: missing iteration')
        if row['status'] in ['partial', 'implemented']:
            require(row['implementation'] and row['verification'], f'{rid}: needs implementation and verification')
        for path in row['implementation'] + row['verification']:
            require(exists(path), f'{rid}: missing {path}')
    manifests = list((ROOT / 'docs/iterations').glob('*/manifest.json'))
    require(bool(manifests), 'No iteration manifests')
    for path in manifests:
        data = json.loads(path.read_text())
        require(data['id'] == path.parent.name, f'{path}: ID mismatch')
        require(data['status'] in ['planned', 'active', 'completed', 'blocked'], f'{path}: invalid status')
        for rid in data['requirements']:
            require(rid in ids, f'{path}: unknown requirement {rid}')
        for link in data['decisions']:
            require(exists(link), f'{path}: missing ADR {link}')
        for link in ['plan.md', 'tasks.md', 'verification.md'] + data['artifacts']:
            require(exists(path.parent.relative_to(ROOT) / link), f'{path}: missing artifact {link}')
    # Validate local Markdown file references, not external URLs or headings.
    for path in list((ROOT / 'docs').rglob('*.md')) + [ROOT / 'README.md', ROOT / 'README.en.md', ROOT / 'CONTRIBUTING.md']:
        for link in re.findall(r'\]\(([^)]+)\)', path.read_text()):
            if '://' in link or link.startswith('#'):
                continue
            require((path.parent / link.split('#')[0]).exists(), f'{path}: broken link {link}')
    keysets = []
    for lang in ['en', 'zh-Hans']:
        path = ROOT / f'App/Resources/{lang}.lproj/Localizable.strings'
        keys = re.findall(r'^"([^"]+)"\s*=', path.read_text(), re.M)
        require(len(keys) == len(set(keys)), f'{lang}: duplicate localization keys')
        keysets.append(set(keys))
    require(keysets[0] == keysets[1], 'English/Chinese localization keys differ')
    used = set()
    for path in (ROOT / 'App').glob('*.swift'):
        used.update(re.findall(r'(?:text|duration)\("([^"]+)"', path.read_text()))
    require(used <= keysets[0], f'Missing UI keys: {sorted(used - keysets[0])}')
    if errors:
        print('\n'.join(errors), file=sys.stderr)
        return 1
    print(f'SDD references OK: {len(rows)} requirements, {len(manifests)} iteration(s); {len(keysets[0])} bilingual keys.')
    return 0

if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f'Document validation failed: {error}', file=sys.stderr)
        sys.exit(1)
