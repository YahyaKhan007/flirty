// ignore_for_file: avoid_print



// Future<String> getCityNameFromCoordinates({
//   required double latitude,
//   required double longitude,
// }) async {
//   try {
//     var controller = Get.find<FirebaseAuthController>();
//     print('trying to find Location of the user');
//     print('latitude   .... $latitude');
//     print('longitude   .... $longitude');

//     List<Placemark> placemarks =
//         await placemarkFromCoordinates(latitude, longitude);
//     if (placemarks.isNotEmpty) {
//       controller.country.value = placemarks[0].country.toString();
//       log(placemarks[0].country.toString());
//       final locality = placemarks[0].locality;
//       final administrativeArea = placemarks[0].administrativeArea;
//       final subadministrativeArea = placemarks[0].subAdministrativeArea;

//       String location =
//           locality ?? administrativeArea ?? subadministrativeArea ?? 'Unknown';
//       print(location);
//       return location;
//     }
//     return 'Unknown';
//   } catch (e) {
//     print('Error: $e');
//     return 'Unknown';
//   }
// }
