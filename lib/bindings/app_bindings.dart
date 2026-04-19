import 'package:get/get.dart';

import '../services/llm_service.dart';
import '../services/model_manager.dart';
import '../services/chat_storage_service.dart';
import '../controllers/chat_controller.dart';
import '../controllers/model_controller.dart';
import '../controllers/theme_controller.dart';

/// Initial bindings — registers all services and controllers with GetX DI.
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // ── Services (async init happens in splash) ──────────────────
    Get.lazyPut(() => LlmService(), fenix: true);
    Get.lazyPut(() => ModelManager(), fenix: true);
    Get.lazyPut(() => ChatStorageService(), fenix: true);

    // ── Controllers ──────────────────────────────────────────────
    Get.put(ThemeController()); // Put instead of lazyPut since we need theme immediately
    Get.lazyPut(() => ChatController(), fenix: true);
    Get.lazyPut(() => ModelController(), fenix: true);
  }
}
