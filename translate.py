import json
import sys
from deep_translator import GoogleTranslator

file_path = r'd:\APP-Project\Allah_99_Name\allah_name\assets\data\names.json'

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

translator = GoogleTranslator(source='en', target='am')
names = data['names']
total = len(names)

changes = 0
for i, item in enumerate(names):
    if 'explanation_am' not in item or not item['explanation_am']:
        explanation = item.get('explanation', '')
        if explanation:
            try:
                translated = translator.translate(explanation)
                item['explanation_am'] = translated
                print(f"Translated {item['id']} / {total}", flush=True)
                changes += 1
            except Exception as e:
                print(f"Error on {item['id']}: {e}", flush=True)

if changes > 0:
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump({"names": names}, f, ensure_ascii=False, indent=2)
    print(f"Saved {changes} translations!", flush=True)
else:
    print("Everything already translated!", flush=True)
