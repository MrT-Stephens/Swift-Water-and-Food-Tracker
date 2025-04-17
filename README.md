# Water and Food Tracker

A comprehensive iOS application for tracking daily water intake, food consumption, and step count. The app helps users maintain a healthy lifestyle by monitoring their daily habits and providing insights into their progress.

![App Screenshot](Screenshots/app-screenshot.png)

## Features

### Water Tracking
- Log water intake throughout the day
- Set daily water intake goals
- View water consumption history
- Track progress with visual indicators
- Smart notifications for hydration reminders

### Food Tracking
- Log meals and snacks with calorie information
- Categorize food entries (Breakfast, Lunch, Dinner, Snack)
- Set daily calorie goals
- View food consumption history
- AI-powered meal suggestions based on preferences and goals

### Step Tracking
- Automatic step tracking through HealthKit integration
- Set daily step goals
- View step history
- Real-time step count updates

### Widgets
- Add widgets to your home screen to quickly view your daily progress
- Available in small and medium sizes
- Shows water intake, food consumption, and step count at a glance
- Updates automatically every 30 minutes

### Smart Features
- AI-powered meal suggestions
- Customizable smart notifications
- Progress tracking and analytics
- Data persistence with SwiftData
- Seamless HealthKit integration

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/Swift-Water-and-Food-Tracker.git
   ```

2. Open the project in Xcode:
   ```
   cd Swift-Water-and-Food-Tracker
   open Water-and-Food-Tracker.xcodeproj
   ```

3. Set up App Groups:
   - Select your project in the navigator
   - Select your main app target
   - Go to the "Signing & Capabilities" tab
   - Click the "+" button and add "App Groups"
   - Add a group with identifier "group.com.thomasstephens.waterandfoodtracker"
   - Repeat the same steps for your widget target

4. Build and run the application

## Project Structure

- **Water-and-Food-Tracker/**
  - **Models/**
    - `Models.swift` - Data models and DataManager
    - `HealthKitManager.swift` - HealthKit integration
    - `NotificationManager.swift` - Smart notification system
    - `AIManager.swift` - AI-powered meal suggestions
  - **Views/**
    - Various SwiftUI views for the app interface
  - **Assets.xcassets/**
    - App icons and images
  - **Info.plist**
    - App configuration

- **Water-and-Food-Tracker-Widget/**
  - Widget extension for displaying water and food intake on the home screen
  - `SharedDataManager.swift` - Shared data access between app and widget

## Data Management

The app uses SwiftData for reliable data persistence and App Groups for sharing data between the main application and the widget extension. This ensures consistent data across all components of the app.

The shared data includes:
- Water intake entries
- Food intake entries
- User targets
- AI preferences and suggestions

## Future Enhancements

- Enhanced AI features for more personalized meal suggestions
- Social features for sharing progress and challenges
- Advanced analytics and trend analysis
- Integration with additional health and fitness platforms

## Acknowledgments

- Icons provided by SF Symbols
- HealthKit integration for step tracking
- SwiftData for reliable data persistence 