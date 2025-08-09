# Complete Backend Authentication Setup
# Add this to your d:\VSCODE\speech_translation_backend\app.py

# ================================
# STEP 1: ADD IMPORTS (at the top of app.py)
# ================================

import jwt
import datetime
from werkzeug.security import generate_password_hash, check_password_hash

# ================================
# STEP 2: ADD USER STORAGE (after other variables)
# ================================

# In-memory user storage (in production, use a proper database)
users_db = {}
SECRET_KEY = "speech_translator_secret_key_2025"  # Change this in production

# ================================
# STEP 3: ADD AUTHENTICATION ENDPOINTS (before if __name__ == '__main__':)
# ================================

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
            
        # Validate email format
        if '@' not in email or '.' not in email:
            return jsonify({'error': 'Invalid email format'}), 400
            
        # Check if user already exists
        if email in users_db:
            return jsonify({'error': 'User already exists with this email'}), 400
            
        # Store user (password is already hashed from frontend)
        users_db[email] = {
            'email': email,
            'password': password,  # Password is pre-hashed with SHA-256
            'name': name,
            'created_at': datetime.datetime.utcnow().isoformat()
        }
        
        # Generate JWT token
        token = jwt.encode({
            'email': email,
            'name': name,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(days=30)
        }, SECRET_KEY, algorithm='HS256')
        
        response = {
            'status': 'success',
            'message': 'Registration successful! Welcome to Speech Translator.',
            'user': {
                'email': email,
                'name': name,
                'created_at': users_db[email]['created_at']
            },
            'token': token
        }
        
        print(f"Registration successful: {email}")
        print(f"Total users: {len(users_db)}")
        return jsonify(response)
        
    except Exception as e:
        print(f"Registration error: {str(e)}")
        return jsonify({'error': f'Registration failed: {str(e)}'}), 500

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
            print(f"User not found: {email}")
            return jsonify({'error': 'Invalid email or password'}), 401
            
        user = users_db[email]
        
        # Check password (comparing hashed passwords)
        if user['password'] != password:
            print(f"Password mismatch for user: {email}")
            return jsonify({'error': 'Invalid email or password'}), 401
            
        # Generate JWT token
        token = jwt.encode({
            'email': email,
            'name': user['name'],
            'exp': datetime.datetime.utcnow() + datetime.timedelta(days=30)
        }, SECRET_KEY, algorithm='HS256')
        
        response = {
            'status': 'success',
            'message': f'Welcome back, {user["name"]}!',
            'user': {
                'email': user['email'],
                'name': user['name'],
                'created_at': user.get('created_at', 'Unknown')
            },
            'token': token
        }
        
        print(f"Login successful: {email}")
        return jsonify(response)
        
    except Exception as e:
        print(f"Login error: {str(e)}")
        return jsonify({'error': f'Login failed: {str(e)}'}), 500

@app.route('/auth/verify', methods=['POST'])
def verify_token_endpoint():
    """Verify if a JWT token is valid"""
    try:
        print("=== VERIFY TOKEN ENDPOINT CALLED ===")
        
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'error': 'No authorization token provided'}), 401
            
        token = auth_header.split(' ')[1]
        user = verify_token(token)
        
        if not user:
            return jsonify({'error': 'Invalid or expired token'}), 401
            
        return jsonify({
            'status': 'success',
            'message': 'Token is valid',
            'user': {
                'email': user['email'],
                'name': user['name']
            }
        })
        
    except Exception as e:
        print(f"Token verification error: {str(e)}")
        return jsonify({'error': 'Token verification failed'}), 500

@app.route('/auth/users', methods=['GET'])
def list_users():
    """Debug endpoint to list all registered users"""
    try:
        users_list = []
        for email, user_data in users_db.items():
            users_list.append({
                'email': email,
                'name': user_data['name'],
                'created_at': user_data.get('created_at', 'Unknown')
            })
        
        return jsonify({
            'status': 'success',
            'total_users': len(users_db),
            'users': users_list
        })
        
    except Exception as e:
        print(f"List users error: {str(e)}")
        return jsonify({'error': str(e)}), 500

# ================================
# STEP 4: ADD HELPER FUNCTIONS
# ================================

def verify_token(token):
    """Verify JWT token and return user data"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        email = payload['email']
        if email in users_db:
            return users_db[email]
        return None
    except jwt.ExpiredSignatureError:
        print("Token expired")
        return None
    except jwt.InvalidTokenError:
        print("Invalid token")
        return None

def require_auth():
    """Middleware to protect routes (optional)"""
    auth_header = request.headers.get('Authorization')
    if not auth_header or not auth_header.startswith('Bearer '):
        return jsonify({'error': 'No authorization token provided'}), 401
        
    token = auth_header.split(' ')[1]
    user = verify_token(token)
    if not user:
        return jsonify({'error': 'Invalid or expired token'}), 401
        
    return user

# ================================
# INSTALLATION INSTRUCTIONS
# ================================

"""
SETUP INSTRUCTIONS:

1. Install required Python package:
   cd d:\VSCODE\speech_translation_backend
   pip install PyJWT

2. Add the above code to your app.py file:
   - Add imports at the top
   - Add user storage variables after other variables
   - Add all the endpoints before if __name__ == '__main__':
   - Add helper functions at the end

3. Restart your backend server:
   python app.py

4. Test endpoints:
   POST http://localhost:5000/auth/register
   POST http://localhost:5000/auth/login
   POST http://localhost:5000/auth/verify
   GET  http://localhost:5000/auth/users

5. Your Flutter app will now work with authentication!

OPTIONAL: Protect existing endpoints by adding this to /transcribe:
```python
@app.route('/transcribe', methods=['POST'])
def transcribe_audio():
    # Uncomment to require authentication:
    # auth_result = require_auth()
    # if isinstance(auth_result, tuple):  # Error response
    #     return auth_result
    
    # Your existing transcribe code here...
```
"""
