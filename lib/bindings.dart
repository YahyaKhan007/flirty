import 'package:get/get.dart';

import 'controllers/chatroom_controller.dart';
import 'controllers/controllers.dart';

class ControllerBinding implements Bindings {
  @override
  void dependencies() {
    // Get.put(FirebaseAuthController());
    // Get.put(LangController());
    Get.put((ChatroomController()));
    Get.put(FirebaseAuthController());
  }
}
