# Water and Food Tracker

A comprehensive iOS application for tracking daily water intake, food consumption, and step count. The app helps users maintain a healthy lifestyle by monitoring their daily habits and providing insights into their progress.

<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; justify-content: center; align-items: center; width: max-content; margin: 0 auto;">
<img width="140" alt="image" src="https://github.com/user-attachments/assets/9f64d1b0-fb9f-4cb7-8e5c-402c72797f65" />
<img width="140" alt="image" src="https://github.com/user-attachments/assets/0de62bb6-1a65-4b59-beef-c738f329776e" />
<img width="140" alt="image" src="https://github.com/user-attachments/assets/ea8e2c3f-94b4-403a-a52c-f908e0a63aba" />
<img width="140" alt="image" src="https://github.com/user-attachments/assets/f7eabe61-1ece-4ccc-bc13-fcf4af733482" />
<img width="140" alt="image" src="https://github.com/user-attachments/assets/d9e49bc1-1400-4365-8d51-21e220c151a1" />
<img width="140" alt="image" src="https://github.com/user-attachments/assets/e0532822-81e4-4840-b67d-2d950012879d" />
</div>


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
