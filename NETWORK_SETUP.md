# 🌐 Network Configuration for Mobile App

## 🔍 Find Your PC's IP Address

### Method 1: Command Prompt
1. Press `Win + R`, type `cmd`, press Enter
2. Type: `ipconfig`
3. Look for "IPv4 Address" under your WiFi adapter
4. It will look like: `192.168.1.XXX` or `10.0.0.XXX`

### Method 2: Settings
1. Open Windows Settings
2. Go to Network & Internet → WiFi
3. Click on your connected network
4. Scroll down to find "IPv4 address"

### Method 3: Task Manager
1. Open Task Manager (Ctrl+Shift+Esc)
2. Go to Performance tab
3. Click on "Wi-Fi" or "Ethernet"
4. See IP address at the bottom

## 🔧 Update API Configuration

Once you find your IP address (e.g., `192.168.1.105`), I need to update the API service:

### Current Configuration
```dart
// Android: Use your PC's IP address
return 'http://192.168.1.100:5000';  // ← Update this line
```

### Example Updates
If your IP is `192.168.1.105`:
```dart
return 'http://192.168.1.105:5000';
```

If your IP is `10.0.0.50`:
```dart
return 'http://10.0.0.50:5000';
```

## 🔥 Quick Test

1. **Find your IP**: Use one of the methods above
2. **Tell me the IP**: Share your PC's IP address
3. **I'll update the code**: Fix the API service immediately
4. **Hot reload**: Changes will apply instantly to your mobile app

## 🛜 Network Requirements

Make sure:
- ✅ Both PC and phone are on the same WiFi network
- ✅ Windows Firewall allows Flask app (port 5000)
- ✅ Your router doesn't block internal communication

## 🚨 Common IP Ranges

Most home networks use:
- `192.168.1.XXX` (most common)
- `192.168.0.XXX`
- `10.0.0.XXX`
- `172.16.XXX.XXX`

## ⚡ What to Share

Just tell me your IP address (e.g., "192.168.1.105") and I'll immediately update the API service so your mobile app can connect to your backend!
