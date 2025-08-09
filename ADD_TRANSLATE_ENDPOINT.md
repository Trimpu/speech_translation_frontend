# Add Translate Endpoint to Backend

## Instructions

Add this endpoint to your `d:\VSCODE\speech_translation_backend\app.py` file:

```python
@app.route('/translate', methods=['POST'])
def translate_text_endpoint():
    try:
        # Get JSON data
        data = request.json
        if not data:
            return jsonify({'error': 'No JSON data provided'}), 400
            
        text = data.get('text')
        target_language = data.get('target_language', 'en')
        source_language = data.get('source_language')
        
        if not text:
            return jsonify({'error': 'No text provided'}), 400
            
        print(f"Translating text: {text[:100]}...")
        print(f"Target language: {target_language}")
        print(f"Source language: {source_language}")
        
        # Use the existing translate_text function
        if target_language != source_language:
            translated_text, detected_lang = translate_text(text, source_language or 'auto', target_language)
        else:
            translated_text = text  # No translation needed
            detected_lang = source_language
            
        response = {
            'original_text': text,
            'translated_text': translated_text,
            'source_language': detected_lang or source_language or 'auto-detected',
            'target_language': target_language,
            'status': 'success'
        }
        
        print(f"Translation successful: {translated_text[:100]}...")
        return jsonify(response)
        
    except Exception as e:
        print(f"Translation error: {str(e)}")
        return jsonify({'error': str(e)}), 500
```

## What this does:
1. Creates a `/translate` POST endpoint
2. Accepts JSON with `text`, `target_language`, and optional `source_language`
3. Uses the existing `translate_text()` function in your backend
4. Returns the original text, translated text, and language info
5. Handles errors gracefully

## After adding this endpoint:
1. Restart your backend server
2. The retranslate button in the Flutter app will work perfectly!

## Test the endpoint:
```bash
curl -X POST http://localhost:5000/translate \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello world", "target_language": "es"}'
```

Expected response:
```json
{
  "original_text": "Hello world",
  "translated_text": "Hola mundo",
  "source_language": "en",
  "target_language": "es",
  "status": "success"
}
```
