# Supabase App Setup

This Flutter app uses environment variables to manage Supabase configuration securely.

## Setup Instructions

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Configure your Supabase project:**
   - Go to the [Supabase Dashboard](https://app.supabase.com/)
   - Create a new project or select an existing one
   - Go to Settings > API
   - Copy your Project URL and anon/public key

3. **Update the .env file:**
   Open the `.env` file and replace the placeholder values with your actual Supabase configuration:
   ```
   SUPABASE_URL=https://your-project-ref.supabase.co
   SUPABASE_ANON_KEY=your_actual_anon_key
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
- Keep your Supabase configuration values secure and never share them publicly
- The anon key is safe to use in client-side applications as it respects your Row Level Security policies
- Use different Supabase projects for development, staging, and production environments