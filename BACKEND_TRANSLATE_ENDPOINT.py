# INSTRUCTIONS: Add Translate Endpoint to Backend
# 
# This file contains the code that needs to be ADDED to your existing
# d:\VSCODE\speech_translation_backend\app.py file
#
# DO NOT RUN THIS FILE DIRECTLY - Copy the code below and add it to app.py

"""
ADD THE FOLLOWING CODE TO YOUR app.py FILE:

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
        
        # Use the existing translate_text function in your app.py
        if target_language != (source_language or 'en'):
            translated_text, detected_lang = translate_text(text, source_language or 'auto', target_language)
        else:
            translated_text = text  # No translation needed
            detected_lang = source_language or 'en'
            
        response = {
            'original_text': text,
            'translated_text': translated_text,
            'source_language': detected_lang,
            'target_language': target_language,
            'status': 'success'
        }
        
        print(f"Translation successful: {translated_text[:100]}...")
        return jsonify(response)
        
    except Exception as e:
        print(f"Translation error: {str(e)}")
        return jsonify({'error': str(e)}), 500

STEPS TO ADD THIS:
1. Open d:\VSCODE\speech_translation_backend\app.py
2. Add the above code at the end of the file (before if __name__ == '__main__':)
3. Save the file
4. Restart your backend server
5. Test with: curl -X POST http://localhost:5000/translate -H "Content-Type: application/json" -d '{"text": "Hello", "target_language": "es"}'
"""
