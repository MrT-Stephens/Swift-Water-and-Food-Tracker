# Water and Food Tracker

A comprehensive iOS application for tracking daily water intake, food consumption, and step count. The app helps users maintain a healthy lifestyle by monitoring their daily habits and providing insights into their progress.

![App Screenshot](Screenshots/app-screenshot.png)

## Features

### Water Tracking
- Log water intake throughout the day
- Set daily water intake goals
- View water consumption history
- Track progress with visual indicators

### Food Tracking
- Log meals and snacks with calorie information
- Categorize food entries (Breakfast, Lunch, Dinner, Snack)
- Set daily calorie goals
- View food consumption history

### Step Tracking
- Track daily step count
- Set daily step goals
- View step history

### Widgets
- Add widgets to your home screen to quickly view your daily progress
- Available in small and medium sizes
- Shows water intake and food consumption at a glance
- Updates automatically every 30 minutes

### Data Management
- Persistent storage of all entries
- Data sharing between app and widgets
- Option to reset data or initialize with sample data

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
    - `NotificationManager.swift` - Local notifications
  - **Views/**
    - Various SwiftUI views for the app interface
  - **Assets.xcassets/**
    - App icons and images
  - **Info.plist**
    - App configuration

- **Water-Widget/**
  - Widget extension for displaying water and food intake on the home screen
  - `SharedDataManager.swift` - Shared data access between app and widget

## Data Sharing Between App and Widget

The app uses App Groups to share data between the main application and the widget extension. This allows the widget to display the same data that's shown in the app.

The shared data includes:
- Water intake entries
- Food intake entries
- User targets

## Acknowledgments

- Icons provided by SF Symbols
- Sample data generation for testing purposes 