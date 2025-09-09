# Firebase App Setup

This Flutter app uses environment variables to manage Firebase configuration securely.

## Setup Instructions

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Configure your Firebase project:**
   - Go to the [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or select an existing one
   - Go to Project Settings > General > Your apps
   - Add a new app or select your existing app
   - Copy the configuration values

3. **Update the .env file:**
   Open the `.env` file and replace the placeholder values with your actual Firebase configuration:
   ```
   FIREBASE_API_KEY=your_actual_api_key
   FIREBASE_AUTH_DOMAIN=your_project_id.firebaseapp.com
   FIREBASE_PROJECT_ID=your_actual_project_id
   FIREBASE_STORAGE_BUCKET=your_project_id.appspot.com
   FIREBASE_MESSAGING_SENDER_ID=your_actual_sender_id
   FIREBASE_APP_ID=your_actual_app_id
   ```

4. **Install dependencies:**
   ```bash
   flutter pub get
   ```

5. **Run the app:**
   ```bash
   flutter run
   ```

## Security Notes

- The `.env` file is ignored by git and should never be committed to version control
- Keep your Firebase configuration values secure and never share them publicly
- Use different Firebase projects for development, staging, and production environments