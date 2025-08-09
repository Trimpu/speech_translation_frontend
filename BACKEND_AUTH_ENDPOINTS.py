# Backend Authentication Endpoints
# Add these endpoints to your d:\VSCODE\speech_translation_backend\app.py file

import jwt
import datetime
from werkzeug.security import generate_password_hash, check_password_hash

# In-memory user storage (in production, use a proper database)
users_db = {}
SECRET_KEY = "your_jwt_secret_key_here"  # Change this to a secure secret key

@app.route('/auth/register', methods=['POST'])
def register():
    try:
        print("=== REGISTER ENDPOINT CALLED ===")
        
        # Get JSON data
        data = request.json
        if not data:
            print("ERROR: No JSON data provided")
            return jsonify({'error': 'No JSON data provided'}), 400
            
        email = data.get('email')
        password = data.get('password')
        name = data.get('name')
        
        print(f"Registration attempt: {email}, {name}")
        
        if not email or not password or not name:
            return jsonify({'error': 'Email, password, and name are required'}), 400
            
        # Check if user already exists
        if email in users_db:
            return jsonify({'error': 'User already exists'}), 400
            
        # Store user (in production, hash the password properly)
        users_db[email] = {
            'email': email,
            'password': password,  # Password is already hashed from frontend
            'name': name,
            'created_at': datetime.datetime.utcnow().isoformat()
        }
        
        # Generate JWT token
        token = jwt.encode({
            'email': email,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(days=30)
        }, SECRET_KEY, algorithm='HS256')
        
        response = {
            'status': 'success',
            'message': 'User registered successfully',
            'user': {
                'email': email,
                'name': name
            },
            'token': token
        }
        
        print(f"Registration successful: {email}")
        return jsonify(response)
        
    except Exception as e:
        print(f"Registration error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/auth/login', methods=['POST'])
def login():
    try:
        print("=== LOGIN ENDPOINT CALLED ===")
        
        # Get JSON data
        data = request.json
        if not data:
            print("ERROR: No JSON data provided")
            return jsonify({'error': 'No JSON data provided'}), 400
            
        email = data.get('email')
        password = data.get('password')
        
        print(f"Login attempt: {email}")
        
        if not email or not password:
            return jsonify({'error': 'Email and password are required'}), 400
            
        # Check if user exists
        if email not in users_db:
            return jsonify({'error': 'Invalid email or password'}), 401
            
        user = users_db[email]
        
        # Check password (comparing hashed passwords)
        if user['password'] != password:
            return jsonify({'error': 'Invalid email or password'}), 401
            
        # Generate JWT token
        token = jwt.encode({
            'email': email,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(days=30)
        }, SECRET_KEY, algorithm='HS256')
        
        response = {
            'status': 'success',
            'message': 'Login successful',
            'user': {
                'email': user['email'],
                'name': user['name']
            },
            'token': token
        }
        
        print(f"Login successful: {email}")
        return jsonify(response)
        
    except Exception as e:
        print(f"Login error: {str(e)}")
        return jsonify({'error': str(e)}), 500

# Helper function to verify JWT token
def verify_token(token):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        email = payload['email']
        if email in users_db:
            return users_db[email]
        return None
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None

# Middleware to protect routes (optional)
def require_auth():
    auth_header = request.headers.get('Authorization')
    if not auth_header or not auth_header.startswith('Bearer '):
        return jsonify({'error': 'No authorization token provided'}), 401
        
    token = auth_header.split(' ')[1]
    user = verify_token(token)
    if not user:
        return jsonify({'error': 'Invalid or expired token'}), 401
        
    return user

# INSTRUCTIONS:
# 1. Add the above code to your d:\VSCODE\speech_translation_backend\app.py file
# 2. Install required packages: pip install PyJWT
# 3. Import at the top of your app.py: import jwt, datetime
# 4. Restart your backend server
# 5. Test login/register functionality in your Flutter app

# Optional: Add authentication requirement to existing endpoints
# Example for /transcribe endpoint:
# @app.route('/transcribe', methods=['POST'])
# def transcribe_audio():
#     # Uncomment to require authentication:
#     # auth_result = require_auth()
#     # if isinstance(auth_result, tuple):  # Error response
#     #     return auth_result
#     
#     # Your existing transcribe code here...
