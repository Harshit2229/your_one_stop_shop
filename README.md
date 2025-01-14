# Fake Store App

A Flutter e-commerce application that demonstrates integration with the Fake Store API.

## Testing Credentials

- Username: `johnd`
- Password: `m38rmF$`


## Features

- User authentication
- Browse product categories
- View products by category
- Product details
- Shopping cart functionality
- Persistent login state

## Getting Started

### Prerequisites

- Flutter SDK (3.24.0 or higher)
- Dart SDK (3.5.0  or higher)
- Android Studio
- Android SDK (for Android development)
- Xcode (for iOS development)

### Installation

1. Clone the repository:
2.
3. The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`


## Architecture

This app follows the BLoC (Business Logic Component) pattern and includes:

- BLoC for state management
- Repository pattern for data access
- Clean Architecture principles
- Service layer for API communication

## Dependencies

- flutter_bloc: ^8.1.3
- http: ^1.1.0
- equatable: ^2.0.5
- shared_preferences: ^2.2.0
- flutter_secure_storage: ^8.0.0

## API Reference

This app uses the [Fake Store API](https://fakestoreapi.com/) for all data.
