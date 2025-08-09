# COPY THIS CODE TO YOUR BACKEND app.py FILE
# Add this endpoint to d:\VSCODE\speech_translation_backend\app.py

@app.route('/translate', methods=['POST'])
def translate_text_endpoint():
    """
    Endpoint to translate text without audio processing
    Accepts: {"text": "Hello", "target_language": "es", "source_language": "en"}
    Returns: {"original_text": "Hello", "translated_text": "Hola", "source_language": "en", "target_language": "es", "status": "success"}
    """
    try:
        print("=== TRANSLATE ENDPOINT CALLED ===")
        
        # Get JSON data
        data = request.json
        if not data:
            print("ERROR: No JSON data provided")
            return jsonify({'error': 'No JSON data provided'}), 400
            
        text = data.get('text')
        target_language = data.get('target_language', 'en')
        source_language = data.get('source_language')
        
        print(f"Received data: {data}")
        print(f"Text to translate: {text}")
        print(f"Target language: {target_language}")
        print(f"Source language: {source_language}")
        
        if not text:
            print("ERROR: No text provided")
            return jsonify({'error': 'No text provided'}), 400
            
        # Use the existing translate_text function in your app.py
        # (This function should already exist in your backend)
        if target_language != (source_language or 'en'):
            print(f"Calling translate_text function...")
            translated_text, detected_lang = translate_text(text, source_language or 'auto', target_language)
            print(f"Translation result: {translated_text}")
            print(f"Detected language: {detected_lang}")
        else:
            print("No translation needed - same language")
            translated_text = text  # No translation needed
            detected_lang = source_language or 'en'
            
        response = {
            'original_text': text,
            'translated_text': translated_text,
            'source_language': detected_lang or source_language or 'auto',
            'target_language': target_language,
            'status': 'success'
        }
        
        print(f"Sending response: {response}")
        return jsonify(response)
        
    except Exception as e:
        error_msg = f"Translation error: {str(e)}"
        print(f"ERROR: {error_msg}")
        return jsonify({'error': error_msg}), 500

# INSTRUCTIONS:
# 1. Open d:\VSCODE\speech_translation_backend\app.py
# 2. Copy the above code (the @app.route part)
# 3. Paste it at the end of your app.py file (before the if __name__ == '__main__': line)
# 4. Save the file
# 5. Restart your backend server (Ctrl+C then python app.py)
# 6. Test with: curl -X POST http://localhost:5000/translate -H "Content-Type: application/json" -d '{"text": "Hello", "target_language": "es"}'
