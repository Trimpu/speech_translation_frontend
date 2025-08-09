# 🚨 Backend Configuration for Mobile Access

## 🔍 Current Issue
Your mobile app is now configured to connect to `192.168.0.4:5000`, but your backend might only be accepting connections from `localhost`.

## 🔧 Backend Fix Required

### Check Your Backend Configuration

Your Flask backend needs to run with `host='0.0.0.0'` to accept connections from other devices.

**Look for this in your backend code:**
```python
# ❌ This only accepts localhost connections:
app.run(debug=True)
# or
app.run(host='localhost', port=5000)

# ✅ This accepts connections from other devices:
app.run(host='0.0.0.0', port=5000, debug=True)
```

### Quick Backend Update

1. **Open your backend file** (likely `app.py`)
2. **Find the `app.run()` line** at the bottom
3. **Update it to:**
   ```python
   if __name__ == '__main__':
       app.run(host='0.0.0.0', port=5000, debug=True)
   ```

### Restart Backend
After updating:
1. Stop your current backend (Ctrl+C)
2. Run it again: `python app.py`
3. You should see: `Running on http://0.0.0.0:5000`

## 🔥 Windows Firewall

You might also need to allow the connection through Windows Firewall:
1. Windows will likely prompt you when you restart the backend
2. **Allow** the connection for both Private and Public networks

## 🎯 Test Connection

Once both are updated:
1. ✅ Backend running on `0.0.0.0:5000`
2. ✅ Mobile app rebuilt with `192.168.0.4:5000`
3. ✅ Try registration again on mobile

## 📱 Expected Result

You should see in backend logs:
```
POST /auth/register - 200
```

Instead of connection refused errors.
