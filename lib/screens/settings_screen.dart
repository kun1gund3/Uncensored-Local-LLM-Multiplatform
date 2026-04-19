import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../controllers/chat_controller.dart';
import '../controllers/theme_controller.dart';
import '../services/model_manager.dart';

class SettingsScreen extends StatelessWidget {
  /// When true, no Scaffold — just the body content for embedding in tabs.
  final bool embedded;

  const SettingsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    if (embedded) {
      return _SettingsBody(showBackButton: false);
    }
    return Scaffold(
      backgroundColor: context.bg,
      body: _SettingsBody(showBackButton: true),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  final bool showBackButton;

  const _SettingsBody({this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    final chatCtrl = Get.find<ChatController>();
    final modelManager = Get.find<ModelManager>();
    final themeCtrl = Get.find<ThemeController>();

    return Column(
      children: [
        // ── Top bar ──────────────────────────────────
        Container(
          padding: EdgeInsets.only(
            top: showBackButton ? MediaQuery.of(context).padding.top : 0,
            left: 4,
            right: 4,
          ),
          decoration: BoxDecoration(
            color: context.bg,
            border: Border(bottom: BorderSide(color: context.border, width: 0.5)),
          ),
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                if (showBackButton)
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: context.text),
                    onPressed: () => Get.back(),
                  ),
                if (!showBackButton) const SizedBox(width: 16),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: context.text,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Body ─────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Appearance ────────────────────────────────
              _sectionHeader(context, 'Appearance'),
              const SizedBox(height: 12),
              _card(
                context,
                child: Obx(() => SwitchListTile(
                      title: Text('Dark Mode', style: TextStyle(color: context.text, fontSize: 14)),
                      subtitle: Text(
                        themeCtrl.isDarkMode ? 'Using dark theme' : 'Using light theme',
                        style: TextStyle(color: context.textD, fontSize: 12),
                      ),
                      secondary: Icon(
                        themeCtrl.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: context.textM,
                      ),
                      value: themeCtrl.isDarkMode,
                      onChanged: (val) => themeCtrl.toggleTheme(),
                      activeColor: AppColors.accent,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    )),
              ),

              const SizedBox(height: 28),

              // ── System Prompt ─────────────────────────────
              _sectionHeader(context, 'Global System Prompt'),
              const SizedBox(height: 8),
              Text(
                'Applied to all new chats. Existing chats keep their own prompt.',
                style: TextStyle(fontSize: 12, color: context.textD),
              ),
              const SizedBox(height: 12),
              Obx(() => TextField(
                    controller: TextEditingController(text: chatCtrl.systemPrompt.value)
                      ..selection = TextSelection.fromPosition(
                          TextPosition(offset: chatCtrl.systemPrompt.value.length)),
                    maxLines: 4,
                    style: TextStyle(fontSize: 14, color: context.text, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'e.g. You are a helpful assistant...',
                      hintStyle: TextStyle(color: context.textD),
                      filled: true,
                      fillColor: context.bgInput,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.accent),
                      ),
                    ),
                    onChanged: (v) => chatCtrl.setGlobalSystemPrompt(v),
                  )),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    chatCtrl.clearGlobalSystemPrompt();
                    Get.snackbar('Cleared', 'Global system prompt removed.',
                        snackPosition: SnackPosition.BOTTOM);
                  },
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  style: TextButton.styleFrom(foregroundColor: AppColors.red),
                  label: const Text('Clear Prompt', style: TextStyle(fontSize: 13)),
                ),
              ),

              const SizedBox(height: 28),

              // ── Temperature ───────────────────────────────
              _sectionHeader(context, 'Temperature'),
              const SizedBox(height: 12),
              _card(
                context,
                child: Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.thermostat_rounded, size: 20, color: context.textM),
                          Expanded(
                            child: Slider(
                              value: chatCtrl.temperature.value,
                              min: 0.0,
                              max: 2.0,
                              divisions: 20,
                              activeColor: AppColors.accent,
                              inactiveColor: context.border,
                              label: chatCtrl.temperature.value.toStringAsFixed(1),
                              onChanged: (v) => chatCtrl.updateTemperature(v),
                            ),
                          ),
                          Container(
                            width: 44,
                            alignment: Alignment.center,
                            child: Text(
                              chatCtrl.temperature.value.toStringAsFixed(1),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.text),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),

              const SizedBox(height: 28),

              // ── Storage ───────────────────────────────────
              _sectionHeader(context, 'Storage'),
              const SizedBox(height: 12),
              _card(
                context,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.folder_outlined, size: 20, color: context.textM),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          modelManager.modelsDir,
                          style: TextStyle(fontSize: 13, color: context.text),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Danger Zone ───────────────────────────────
              _sectionHeader(context, 'Danger Zone'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_forever_rounded, size: 18),
                label: const Text('Delete All Chats',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      backgroundColor: context.bgPanel,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Text('Delete All Chats?', style: TextStyle(color: context.text)),
                      content: Text('This cannot be undone.', style: TextStyle(color: context.textM)),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text('Cancel', style: TextStyle(color: context.textD)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            chatCtrl.chats.clear();
                            chatCtrl.activeChatId.value = null;
                            Get.back();
                            Get.snackbar('Done', 'All chats deleted.',
                                snackPosition: SnackPosition.BOTTOM);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red, elevation: 0),
                          child: const Text('Delete All', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: const BorderSide(color: AppColors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 40),

              // ── About ─────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Text('Portable AI v1.0.0',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.textM)),
                    const SizedBox(height: 4),
                    Text('Powered by llamadart + llama.cpp',
                        style: TextStyle(fontSize: 11, color: context.textD)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.textM,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: context.bgPanel,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
