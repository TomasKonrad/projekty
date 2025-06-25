import re
import json

# Načtení dat
with open("xkonrad3_jazyky.json", "r", encoding="utf-8") as f:
    raw = f.read()

# Najít všechny objekty typu xzunt_knihy
# regex odpovídá: "xzunt_knihy": { ... }
blocks = re.findall(r'"xkonrad3_jazyky"\s*:\s*{[^}]*}', raw)

cleaned_books = []

for block in blocks:
    # Extrahuj tělo objektu
    body = re.search(r'{(.*)}', block, re.DOTALL)
    if not body:
        continue

    obj_raw = body.group(1).strip()

    # Opravit každou řádku (atribut: hodnota)
    lines = obj_raw.split("\n")
    cleaned = {}
    for line in lines:
        line = line.strip().rstrip(",")
        if not line:
            continue

        parts = line.split(":", 1)
        if len(parts) != 2:
            continue

        key = parts[0].strip().strip('"')
        val = parts[1].strip()

        # Opravit hodnotu:
        if not val.startswith('"'):
            val = f'"{val}"'
        cleaned[key] = val.strip('"')

    cleaned_books.append(cleaned)

# Uložit jako validní JSON
with open("xkonrad3_jazyky.json", "w", encoding="utf-8") as f:
    json.dump(cleaned_books, f, ensure_ascii=False, indent=2)

print(f"Opraveno {len(cleaned_books)} záznamů.")
