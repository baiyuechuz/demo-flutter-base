# Flutter Apps with Firebase & Supabase

[![Flutter CI](https://github.com/YOUR_USERNAME/YOUR_REPO/workflows/Flutter%20CI/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/flutter-ci.yml)
[![Code Quality](https://github.com/YOUR_USERNAME/YOUR_REPO/workflows/Code%20Quality/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/code-quality.yml)

This repository contains two Flutter applications demonstrating integration with Firebase and Supabase, both configured with environment variables using dotenv for secure configuration management.

## 📱 Applications

### Firebase App
A Flutter application integrated with Firebase services, featuring:
- Firebase Core initialization
- Environment-based configuration
- Secure credential management

### Supabase App  
A Flutter application integrated with Supabase, featuring:
- Supabase client initialization
- Environment-based configuration
- Secure credential management

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.24.0 or later)
- Dart SDK
- Android Studio / VS Code
- Git

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. **Setup Firebase App:**
   ```bash
   cd firebase_app
   cp .env.example .env
   # Edit .env with your Firebase configuration
   flutter pub get
   flutter run
   ```

3. **Setup Supabase App:**
   ```bash
   cd supabase_app
   cp .env.example .env
   # Edit .env with your Supabase configuration
   flutter pub get
   flutter run
   ```

For detailed setup instructions, see:
- [Firebase App Setup](firebase_app/SETUP.md)
- [Supabase App Setup](supabase_app/SETUP.md)

## 🔧 CI/CD Pipeline

This repository includes comprehensive GitHub Actions workflows:

### Flutter CI (`flutter-ci.yml`)
- **Triggers:** Push/PR to main/develop branches
- **Jobs:**
  - Code analysis for both apps
  - Code formatting checks

### Code Quality (`code-quality.yml`)
- **Triggers:** Push/PR + Daily scheduled runs
- **Features:**
  - Advanced code analysis with fatal info checks
  - Dependency vulnerability scanning
  - Security scanning with Trivy


## 📊 Workflow Status

| Workflow | Status | Description |
|----------|--------|-------------|
| Flutter CI | [![Flutter CI](https://github.com/YOUR_USERNAME/YOUR_REPO/workflows/Flutter%20CI/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/flutter-ci.yml) | Continuous integration checks |
| Code Quality | [![Code Quality](https://github.com/YOUR_USERNAME/YOUR_REPO/workflows/Code%20Quality/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/code-quality.yml) | Code quality and security scans |

## 🛡️ Security

- Environment variables are properly configured in `.gitignore`
- Sensitive credentials are never committed to version control
- Security scanning is integrated into the CI pipeline
- Dependency vulnerability checks run daily

## 🏗️ Project Structure

```
├── .github/
│   └── workflows/          # GitHub Actions workflows
├── firebase_app/           # Firebase Flutter application
│   ├── lib/
│   ├── .env.example       # Environment template
│   ├── SETUP.md           # Setup instructions
│   └── pubspec.yaml
├── supabase_app/          # Supabase Flutter application
│   ├── lib/
│   ├── .env.example       # Environment template
│   ├── SETUP.md           # Setup instructions
│   └── pubspec.yaml
└── README.md              # This file
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure all CI checks pass
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Note**: Replace `YOUR_USERNAME/YOUR_REPO` in the badge URLs with your actual GitHub username and repository name to display live workflow status.