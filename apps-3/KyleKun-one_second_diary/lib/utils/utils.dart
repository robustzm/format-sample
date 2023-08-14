import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/video_count_controller.dart';
import 'date_format_utils.dart';
import 'shared_preferences_util.dart';
import 'storage_utils.dart';

class Utils {
  // final logger = Logger(
  //   printer: PrettyPrinter(),
  //   level: Level.verbose,
  // );

  // void logInfo(info) {
  //   logger.i(info);
  // }

  // void logWarning(warning) {
  //   logger.w(warning);
  // }

  // void logError(warning) {
  //   logger.e(warning);
  // }

  static void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Used to request Android permissions
  static Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      // Utils().logInfo('Permission was already granted');
      return true;
    } else {
      final result = await permission.request();
      if (result == PermissionStatus.granted) {
        // Utils().logInfo('Permission granted? : ${result.isGranted}');
        return true;
      } else {
        // Utils().logInfo('Permission granted? : ${result.isGranted}');
        return false;
      }
    }
  }

  /// Write txt used by ffmpeg to concatenate videos when generating movie
  static Future<String> writeTxt(List<String> files) async {
    final io.Directory directory = await getApplicationDocumentsDirectory();
    final String txtPath = '${directory.path}/videos.txt';
    final String appPath = SharedPrefsUtil.getString('appPath');

    // Delete old txt files
    if (StorageUtils.checkFileExists(txtPath)) StorageUtils.deleteFile(txtPath);

    final io.File file = io.File(txtPath);

    for (int i = 0; i < files.length; i++) {
      // file model accepted by ffmpeg to be written
      String ffString = "file '$appPath${files[i]}'\r\n";

      // Not adding a new line at the end
      if (i == files.length - 1) ffString = "file '$appPath${files[i]}'";

      // Appending it to the txt
      await file.writeAsString(ffString, mode: io.FileMode.append);
    }

    return txtPath;
  }

  /// Get all video files inside OneSecondDiary folder
  static List<String> getAllVideos() {
    final directory = io.Directory(SharedPrefsUtil.getString('appPath'));

    List<io.FileSystemEntity> _files;

    _files = directory.listSync(recursive: true, followLinks: false);
    final List<String> mp4Files = [];

    // Getting video names
    for (int i = 0; i < _files.length; i++) {
      final String _fileName = _files[i].path;
      if (_fileName.contains('.mp4')) {
        String temp = _fileName.split('.').first;
        temp = temp.split('/').last;
        mp4Files.add(temp);
      }
    }

    return mp4Files;
  }

  // Update the counter based on the amount of mp4 files inside the app folder
  static void updateVideoCount() {
    final allFiles = getAllVideos();
    final VideoCountController _videoCountController = Get.find();

    final int numberOfVideos = allFiles.length;

    final snackBar = SnackBar(
      margin: const EdgeInsets.all(10.0),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black54,
      duration: const Duration(seconds: 3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      content: Text(
        (numberOfVideos != 1)
            ? '$numberOfVideos ${'foundVideos'.tr}'
            : '$numberOfVideos ${'foundVideo'.tr}',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    );

    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);

    // Setting videoCount number
    _videoCountController.setVideoCount(numberOfVideos);
  }

  // Get the list of all mp4 files names ordered by date to be written on a txt file
  static List<String> getAllVideosFromStorage() {
    final List<String> allVideos = [];

    try {
      final allFiles = getAllVideos();

      // Converting to Date in order to sort
      final List<DateTime> allDates = [];
      for (int i = 0; i < allFiles.length; i++) {
        allDates.add(DateTime.parse(allFiles[i]));
      }

      final List<DateTime> orderedDates = DateFormatUtils.orderDates(allDates);

      // Converting back to string
      for (int i = 0; i < orderedDates.length; i++) {
        // Adding a leading zero on Days and Months <= 9
        final String day = orderedDates[i].day <= 9
            ? '0${orderedDates[i].day}'
            : '${orderedDates[i].day}';
        final String month = orderedDates[i].month <= 9
            ? '0${orderedDates[i].month}'
            : '${orderedDates[i].month}';
        final String year = '${orderedDates[i].year}';

        allVideos.add('$year-$month-$day.mp4');
      }
    } catch (e) {}
    return allVideos;
  }
}

  /// Old/Not used methods but might be useful in the future
  /// 
  // Used only in an alternative way to edit video using ffmpeg
  // static Future<String> copyFontToStorage() async {
  //   io.Directory directory = await getApplicationDocumentsDirectory();
  //   String fontPath = directory.path + "/magic.ttf";
  //   try {
  //     if (checkFileExists(fontPath)) {
  //       Utils().logInfo('Font already exists');
  //     } else {
  //       ByteData data =
  //           await rootBundle.load("assets/fonts/YuseiMagic-Regular.ttf");
  //       List<int> bytes =
  //           data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  //       await io.File(fontPath).writeAsBytes(bytes);
  //       Utils().logInfo('Font copied to $fontPath');
  //     }
  //   } catch (e) {
  //     Utils().logError('$e');
  //   }

  //   return fontPath;
  // }

  // static Future<String> copyConfigVideoToStorage() async {
  //   io.Directory directory = await getApplicationDocumentsDirectory();
  //   String configVideoPath = directory.path + "/config.mp4";
  //   try {
  //     if (checkFileExists(configVideoPath)) {
  //       Utils().logInfo('Config video already exists');
  //     } else {
  //       ByteData data = await rootBundle.load("assets/video/config.mp4");
  //       List<int> bytes =
  //           data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  //       await io.File(configVideoPath).writeAsBytes(bytes);
  //       Utils().logInfo('Config video copied to $configVideoPath');
  //     }
  //   } catch (e) {
  //     Utils().logError('$e');
  //   }

  //   return configVideoPath;
  // }

  // static Future<void> configCameraResolution(String configVideoPath) async {
  //   String finalConfigPath = configVideoPath.replaceAll('.mp4', '_.mp4');
  //   Cup cup = Cup(
  //     Content(configVideoPath),
  //     [
  //       TapiocaBall.textOverlay(
  //         'a',
  //         200,
  //         200,
  //         20,
  //         Colors.white,
  //       ),
  //     ],
  //   );

  //   await cup.suckUp(finalConfigPath).then((_) {
  //     Utils().logInfo('finished processing');
  //   }, onError: (error) {
  //     Utils().logError(error);
  //     StorageUtil.putBool('isHighRes', false);
  //   });

  //   deleteFile(configVideoPath);
  //   deleteFile(finalConfigPath);
  //   Utils().logInfo("IS HIGH RES? -> ${StorageUtil.getBool('isHighRes')}");
  // }
