
const String osName = 'ANDROID';
String osVersion = "15";
String deviceMake = 'GOOGLE';
String model = 'Pixel 9';
const String clientFormFactor = 'SMALL_FORM_FACTOR';
const String platform = "MOBILE";
const String key = 'AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8';
const String host = 'https://www.youtube.com/youtubei/v1';
const String inlineSettingStatus = 'INLINE_SETTING_STATUS_ON';
const String webHost = 'https://www.youtube.com/watch?v=';

const String webClientVersion = "2.20250116.01.00";
const String browserName = 'Chrome';
const String webClientName = 'WEB';
const String browserVersion = '131.0.0.0';
const String clientScreen = 'WATCH';
String? languageCode;
String? countryCode;
String? visitorData;

final youtubeContext = {
  "context": {
    "client": {
      "hl": languageCode ?? 'en',
      "gl": countryCode ?? 'US',
      "clientVersion": webClientVersion,
      "clientName": webClientName,
      "browserVersion": browserVersion,
      "osName": osName,
      "platform": platform,
      "clientFormFactor": clientFormFactor,
      "browserName": browserName,
      "deviceMake": deviceMake,
      "osVersion": osVersion,
      'deviceModel': model,
      'clientScreen':clientScreen,
    }
  },
};