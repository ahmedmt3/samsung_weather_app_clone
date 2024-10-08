# Samsung weather app clone 🌦️

This project is a clone of the Samsung Weather app built using Flutter. It features real-time weather updates, forecast information, and a sleek user interface. Ideal for learning Flutter and understanding weather API integrations.


## Features 🌟
- 🌧️ **Real-Time Weather Updates**: Fetches and displays the latest weather information.
- 📆 **7-Day Weather Forecast**: Provides a detailed forecast for the upcoming week.
- 📍 **Current Location Weather**: Automatically detects and shows weather for your current location.
- 🔍 **Search Functionality**: Allows users to search for weather in different cities.
- ⛅ **Detailed Weather Information**: Displays temperature, humidity, wind speed, and more.
- 📱 **Sleek User Interface**: User-friendly design inspired by the Samsung Weather app.
- 🌚 **Dark Mode**: Supports dark mode for a better user experience in low-light conditions.
- 💻 **Responsive Design**: Optimized for both mobile and tablet screens.

## Screenshots 📸

<div style="display: flex;">
  <img src="assets/screenshots/home2.png" alt="Texas Cairo Weather Screenshot" height="300">
  <img src="assets/screenshots/details.png" alt="Details Home Page" height="300" style="margin-right: 30px;">
  <img src="assets/screenshots/drawer.png" alt="Drawer Screenshot" height="300">
  <img src="assets/screenshots/locations_view.png" alt="Locations View" height="300">
</div>
<br>
<div style="display: flex;">
   <img src="assets/screenshots/dialog.png" alt="Alert Dialog" height="300">
   <img src="assets/screenshots/settings.png" alt="Alert Dialog" height="300">
   <img src="assets/screenshots/search.png" alt="Search Page" height="300" style="margin-right: 30px;">
</div>
<br>

### Search and autocomplete 🔍

<div style="display: flex;">
  <img src="assets/screenshots/search1.png" alt="Search Page" width="170" style="margin-right: 30px;">
  <img src="assets/screenshots/search2.png" alt="Search Page" width="200">
</div>
<br>

## Packages 📦
You can read more about each package on [pub.dev](https://www.pub.dev)

- `get`: ^4.6.6
- `path`: ^1.9.0
- `http`: ^1.2.2
- `shared_preferences`: ^2.2.3
- `intl`: ^0.19.0
- `font_awesome_flutter`: ^10.7.0
- `lottie`: ^3.1.2
- `flutter_svg`: ^2.0.10+1
- `dartz`: ^0.10.1
- `get_storage`: ^2.1.1
- `location`: ^7.0.0
- `fluttertoast`: ^8.2.6

## Usage
1. Clone this repository. Or [Download as ZIP file 📁](https://github.com/ahmedmt3/samsung_weather_app_clone/archive/refs/heads/main.zip)
```bash
git clone https://github.com/ahmedmt3/samsung_weather_app_clone.git
cd samsung_weather_app_clone
```
2. Get dependencies

```
flutter pub get
```

3. Inside `lib/core/config/app_config.dart` edit this line with your API key, [get API key.](https://www.weatherapi.com/login.aspx)
```dart
static const String apiKey = "YOUR_API_KEY";
```

4. Run the project 🎉
```
flutter run
```

## Installing
This app isn't available on the play store yet, but you can download the apk [from here]()

## API

<a href="https://www.weatherapi.com/" title="Free Weather API"><img src='https://cdn.weatherapi.com/v4/images/weatherapi_logo.png' alt="Weather data by WeatherAPI.com" border="0"></a>
<br>
This app powered by free weather API from [weatherapi.com](https://www.weatherapi.com)

<br>

## Contributing
You can contribute by reporting bugs, suggesting improvements, and/or by helping out in code.

</br>

## Getting Started With Flutter?

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
