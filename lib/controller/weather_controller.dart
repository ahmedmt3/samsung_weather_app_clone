import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart';
import 'package:weather_app/controller/settings_controller.dart';
import 'package:weather_app/core/config/app_routes.dart';
import 'package:weather_app/core/themes/app_themes.dart';
import 'package:weather_app/model/enums.dart';
import 'package:weather_app/model/search_location.dart';
import 'package:weather_app/model/weather.dart';
import 'package:weather_app/util/helpers/app_helpers.dart';
import 'package:weather_app/util/services/api_services.dart';
import 'package:weather_app/util/services/location_services.dart';

class WeatherController extends GetxController {
  final ApiServices apiServices = ApiServices();
  final LocationServices locationServices = LocationServices();
  final GetStorage box = GetStorage();
  String location = "Paris";
  RxBool isLoading = false.obs;
  PageController outlookPageController = PageController();
  int currOutlookPage = 0;
  late ApiResponse responseStatus;
  Rx<ApiResponse> searchStatus = ApiResponse.unknownErr.obs;
  Color? backgroundColor;
  SettingsController settingsController = Get.find<SettingsController>();
  Timer? timer;
  RxList<Weather> weathers = <Weather>[].obs;
  RxList<SearchLocation> searchedLocations = <SearchLocation>[].obs;
  int refreshCount = 0;

  /// ## Get weather data from API
  /// Perform `GET` request with end Point the [query].
  /// When getting data for new location set [newLoc] to `true`
  /// to pass it to [_updateWeathersList] function.
  /// Handel any errors <br>
  /// Calls back when [responseStatus] == [ApiResponse.offline]
  /// -----------------------------------------------------------
  Future<void> getWeatherData(String query, {bool newLoc = false}) async {
    isLoading(true);
    var response = await apiServices.getRequest(endPoint: "&q=$query");

    if (response.isRight()) {
      //On Success
      responseStatus = ApiResponse.ok;
      log(responseStatus.toString());
      Map<String, dynamic> jsonResponse = response.getOrElse(() => {});
      // log("Response: ${jsonResponse.toString()}");
      weathers.add(Weather.fromJson(jsonResponse));
      _updateWeathersList(newLoc: newLoc);
      saveWeatherData(query, weathers);
      location = query;
    } else {
      //On Error
      responseStatus = response.fold((l) => l, (r) => ApiResponse.unknownErr);
      log(responseStatus.toString());
      if (responseStatus == ApiResponse.offline) {
        await AppHelpers.showOffLineDialog(
            cancelFunction: Get.back,
            confirmFunction: () async {
              Get.back();
              await Future.delayed(const Duration(seconds: 2));
              await getWeatherData(query);
            });
      }
    }
    isLoading(false);
    update();
  }

  /// #### Save [weathers] and [location] localy using `get_storage` <br>
  /// Convert each weather object to json then cast all to list.
  void saveWeatherData(String location, List<Weather> weathers) {
    box.write('location', location);
    List<Map<String, dynamic>> weatherList =
        weathers.map((weather) => weather.toJson()).toList();
    box.write('weathers', weatherList);
  }

  /// ### Perform get request on search API
  /// - Fetch locations from the response
  /// and assign it to [searchedLocations] list.
  /// - Handle any errors.
  void searchLocation(String query) async {
    searchStatus(ApiResponse.loading);
    var response =
        await apiServices.getRequest(endPoint: "&q=$query", isSearch: true);
    response.fold((left) {
      //On Error
      searchStatus.value = left;
      log(left.toString());
    }, (right) {
      //On Success
      List<dynamic> jsonRes = right;
      if (jsonRes.isNotEmpty) {
        searchStatus(ApiResponse.ok);
        searchedLocations.value = jsonRes
            .map(
              (json) => SearchLocation.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
    });
  }

  /// **Calls when selecting location widget from *search_view*** <br>
  /// Calls `getWeatherData()` whith [newLoc] set to `true` to shift
  /// the wethers lis down and add new location on top.
  void selectLocation(String loc) async {
    await getWeatherData(loc, newLoc: true);
    searchedLocations.clear();
    searchStatus.value = ApiResponse.unknownErr;
    updateBackgrounColor();
    Get.toNamed(AppRoutes.home);
    log("Weathers count = ${weathers.length}");
    update();
  }

  /// ## Function to get the current device location
  /// - Checks internet connection.
  /// - Checks for location service if enabled or not.
  /// - Checks location access if allowed or not.
  /// #### Handels any error in all cases.
  Future<void> getUserLocation() async {
    log("Getting Location...");
    Either<LocationError, LocationData> result =
        await locationServices.getLocation();
    result.fold((left) async {
      log(left.toString());
      _handelLocationError(left);
    }, (right) async {
      log(right.toString());
      final String lat = right.latitude!.toString();
      final String lon = right.longitude!.toString();
      location = "$lat,$lon";
      log("Location before sending to api: $location");
      await getWeatherData(location);
    });
  }

  /// ## Function to refresh weather data
  /// This calls the `getLocation()` function. And checks if there's
  /// stored weather on `weathers` list or not, and compare the new location
  /// with the first weather location. If `true`
  Future<void> refreshWeather() async {
    if (refreshCount < 3) {
      await getWeatherData(location);
      refreshCount++;
    } else {
      await getUserLocation();
      refreshCount = 0;
    }
    log("Refresh count = $refreshCount");
    log("Stored location from api: ${weathers.first.location!.lat}, ${weathers.first.location!.lon}");
    updateBackgrounColor();
    update();
  }

  /// ## Function to update weathers list
  /// if `weathers.lenght > 1` Update the favourite weather (1st one)
  /// with the updated (last one) <br>
  /// if `newLoc` is true, insert the new added location at the top (to be favourite)
  /// and remove it from the buttom of the list.
  void _updateWeathersList({bool newLoc = false}) {
    if (newLoc) {
      if (weathers.length > 1) {
        weathers.insert(0, weathers.last);
        weathers.removeLast();
      }
    } else {
      if (weathers.length > 1) {
        weathers.first = weathers.last;
        weathers.removeLast();
      }
    }
  }

  /// Updates the counter index for pageView in *outlook_widget*
  void onOutlookPageChange(index) {
    currOutlookPage = index;
    update();
  }

  /// Updates the *home_view* Scaffold backgroundColor
  /// based on `isDay` value for favourite weather
  void updateBackgrounColor() {
    if (weathers.first.current!.isDay == 1) {
      backgroundColor = AppThemes.dayBackground;
    } else {
      backgroundColor = AppThemes.nightBackground;
    }
  }

  /// Calls [refreshWeather] function every [timer] value
  void _autoRefresh() {
    if (settingsController.refreshTime.inHours != 0) {
      refreshWeather();
      log("Auto Refreshed at ${DateTime.now()}");
    }
  }

  /// Swap the [weathers] Item from [oldIndex] to [newIndex]
  /// Then call [refreshWeather] to update data.
  /// Called in **locations_view** and **app_drawer**
  void onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex--;
    final Weather tempWeather = weathers.removeAt(oldIndex);
    weathers.insert(newIndex, tempWeather);

    refreshWeather();
    update();
  }

  /// Shows an AlertDialog for each [LocationError]
  _handelLocationError(LocationError error) async {
    getUserLocationCallBack() async {
      Get.back();
      await Future.delayed(const Duration(seconds: 2));
      await getUserLocation();
    }

    if (error == LocationError.offline) {
      await AppHelpers.showOffLineDialog(
          cancelFunction: Get.back, confirmFunction: getUserLocationCallBack);
    } else if (error == LocationError.notEnabled) {
      await AppHelpers.notEnabledDialog(
          cancelFunction: Get.back, confirmFunction: getUserLocationCallBack);
    } else if (error == LocationError.denied) {
      await AppHelpers.deniedDialog(
          cancelFunction: Get.back, confirmFunction: getUserLocationCallBack);
    }
  }

  @override
  void onInit() async {
    isLoading(true);
    location = box.read<String>('location') ?? location;
    List<dynamic>? savedWeatherList = box.read<List<dynamic>>('weathers');
    if (savedWeatherList != null) {
      log("Weather before: $weathers");
      weathers.value =
          savedWeatherList.map((json) => Weather.fromJson(json)).toList();
      await refreshWeather();
    } else {
      await getUserLocation();
    }
    // Start timer
    timer =
        Timer.periodic(settingsController.refreshTime, (t) => _autoRefresh());
    isLoading(false);
    super.onInit();
  }

  @override
  void onClose() async {
    await box.remove('weathers');
    weathers.clear();
    outlookPageController.dispose();
    super.onClose();
  }
}
