import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../services/llm_service.dart';
import '../services/model_manager.dart';
import '../services/chat_storage_service.dart';
import '../services/local_api_server_service.dart';
import '../services/wakelock_service.dart';
import '../services/background_optimizer_service.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      setState(() => _status = 'Setting up storage...');
      await Get.find<ChatStorageService>().init();

      setState(() => _status = 'Loading model catalog...');
      await Get.find<ModelManager>().init();

      setState(() => _status = 'Preparing AI engine...');
      await Get.find<LlmService>().init();

      setState(() => _status = 'Preparing local API...');
      await Get.find<LocalApiServerService>().init();

      setState(() => _status = 'Setting up background services...');
      await Get.find<WakelockService>().init();

      setState(() => _status = 'Ready!');
      await Future.delayed(const Duration(milliseconds: 500));

      // Prompt for battery optimization on Android (first launch only)
      if (mounted) {
        await BackgroundOptimizerService.checkAndPrompt(context);
      }

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    size: 42,
                    color: Colors.white,
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 24),
            Text(
              'Uncensored Local AI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: context.text,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
            const SizedBox(height: 8),
            Text(
              'Run uncensored LLMs natively on any device 🔓',
              style: TextStyle(fontSize: 13, color: context.textM),
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
            const SizedBox(height: 40),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(AppColors.accent),
              ),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 16),
            Text(
              _status,
              style: TextStyle(fontSize: 12, color: context.textD),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
