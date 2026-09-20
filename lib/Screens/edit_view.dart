import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_doing/Controller/screen_state_controller.dart';
import 'package:flutter_doing/Controller/settings_controller.dart';
import 'package:flutter_doing/Helpers/log_helper.dart';
import 'package:flutter_doing/Models/item_model.dart';

import 'package:flutter_doing/Services/shared_preferences_service.dart';
import 'package:flutter_doing/Widgets/AppBars/settings_title_bar_mac.dart';
import 'package:flutter_doing/Widgets/AppBars/settings_title_bar_windows.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SaveStatus { idle, saving, saved, error }

class EditView extends ConsumerStatefulWidget {
  const EditView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditViewState();
}

class _EditViewState extends ConsumerState {
  Item? selectedItem;
  final textFieldController = TextEditingController();

  Timer? _debounce;
  SaveStatus _saveStatus = SaveStatus.idle;

  void _onNoteChanged(String value) {
    _debounce?.cancel();

    setState(() => _saveStatus = SaveStatus.idle);
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _saveNote(value);
    });
  }

  Future<void> _saveNote(String value) async {
    setState(() => _saveStatus = SaveStatus.saving);
    try {
      if (!mounted) return;
      setState(() => _saveStatus = SaveStatus.saved);

      Timer(const Duration(seconds: 2), () {
        if (mounted && _saveStatus == SaveStatus.saved) {
          setState(() => _saveStatus = SaveStatus.idle);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _saveStatus = SaveStatus.error);
    }
    coloredLog("[PROJECT SCREEN] Saving note", color: 'green');
  }

  Widget _buildSuffixIcon() {
    switch (_saveStatus) {
      case SaveStatus.saving:
        return const SizedBox(
          key: ValueKey('saving'),
          width: 20,
          height: 20,
          child: Padding(
            padding: EdgeInsets.all(2.0),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.blue,
            ),
          ),
        );
      case SaveStatus.saved:
        return const Icon(
          Icons.save,
          key: ValueKey('saved'),
          color: Colors.green,
        );
      case SaveStatus.error:
        return const Icon(
          Icons.error_outline,
          key: ValueKey('error'),
          color: Colors.red,
        );
      case SaveStatus.idle:
        return const SizedBox.shrink(key: ValueKey('idle'));
    }
  }

  @override
  void initState() {
    super.initState();

    setInitialNoteValue();
  }

  void setInitialNoteValue() {
    coloredLog(
      "[PROJECT SCREEN] Setting initial value for note",
      color: 'magenta',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // to prevent render overflows, use Layout Builder here
    // Flutter evaluates layout constraints instantly during a window resize (from project screen to smaller screens)
    // it forces our project screen widget tree to render within the new size resulting in a render overflow
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight <= 490) {
          return SizedBox.shrink();
        } else {
          return Column(
            children: [
              Platform.isMacOS
                  ? SettingsTitleBarMac(title: "Doing")
                  : SettingsTitleBarWindows(title: ""),
              Padding(
                padding: const EdgeInsets.only(top: 60, left: 50, right: 50),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return Container(color: theme.scaffoldBackgroundColor);
                    } else if (constraints.maxHeight < 250) {
                      return Container(color: theme.scaffoldBackgroundColor);
                    } else {
                      return _projectScreenContent(theme);
                    }
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _projectScreenContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "bearbeiten",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const Spacer(),
            IconButton(
              onPressed: () async {
                final appState = await SharedPreferencesService.instance
                    .loadAppScreenState();
                final settings = ref.read(settingsProvider);

                await ref
                    .read(screenStateProvider.notifier)
                    .changeState(appState, settings);
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        SizedBox(height: 50),

        // projectListAsync.when(
        //   skipError: true,
        //   skipLoadingOnRefresh: true,
        //   skipLoadingOnReload: true,
        //   loading: () => const Text(""),
        //   error: (error, stack) => Text('Fehler: $error'),
        //   data: (activities) {
        //     coloredLog(
        //       "[PROJECT SCREEN] current activity = ${status.activityId}",
        //       color: 'yellow',
        //     );

        //     // todo: if error occurs and there is an empty activity list, we crash here
        //     final current = activities.firstWhere(
        //       (p) => p.id == status.activityId.toString(),
        //       orElse: () => Activity(id: "0"),
        //     );

        //     return DropdownMenu<Activity>(
        //       key: ValueKey(current.id),
        //       initialSelection: current,
        //       dropdownMenuEntries: activities.map((activity) {
        //         return DropdownMenuEntry<Activity>(
        //           value: activity,
        //           label: activity.name,
        //         );
        //       }).toList(),

        //       onSelected: (activity) async {
        //         setState(() {
        //           selectedActivity = activity;
        //         });
        //       },
        //     );
        //   },
        // ),
        SizedBox(height: 30),
        SizedBox(
          width: 400,
          child: Column(
            children: [
              TextField(
                onChanged: (value) => _onNoteChanged(value),
                controller: textFieldController,
                maxLines: 6,
                minLines: 1,
                expands: false,
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: InputDecoration(
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _buildSuffixIcon(),
                    ),
                  ),

                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  hint: Text("edit hint"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    textFieldController.dispose();
    super.dispose();
  }
}
