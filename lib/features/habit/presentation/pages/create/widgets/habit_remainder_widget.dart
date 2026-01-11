import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/widgets/my_card_widget.dart';
import 'package:pursuit/features/widgets/time_picker_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class HabitRemainderWidget extends StatefulWidget {
  const HabitRemainderWidget({super.key, required this.backgroundColor});

  final Color backgroundColor;

  @override
  State<HabitRemainderWidget> createState() => _HabitRemainderWidgetState();
}

class _HabitRemainderWidgetState extends State<HabitRemainderWidget> {
  String _permissionStatusLabel = 'Unknown';
  bool _hasExactAlarmPermission = false;

  @override
  void initState() {
    super.initState();
    _loadPermissionStatus();
  }

  Future<void> _loadPermissionStatus() async {
    final notificationStatus = await Permission.notification.status;
    String notificationLabel = _mapStatusToLabel(notificationStatus);
    
    // Check exact alarm permission for Android
    bool hasExactAlarm = true; // Default for iOS and older Android
    if (Theme.of(context).platform == TargetPlatform.android) {
      try {
        final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
        hasExactAlarm = exactAlarmStatus.isGranted;
        
        if (notificationLabel == 'Notifications allowed') {
          // Add exact alarm status info
          if (!hasExactAlarm) {
            notificationLabel = 'Notifications allowed (may be delayed)';
          }
        }
      } catch (e) {
        hasExactAlarm = true; // Older Android versions don't need this
      }
    }
    
    if (!mounted) return;
    setState(() {
      _permissionStatusLabel = notificationLabel;
      _hasExactAlarmPermission = hasExactAlarm;
    });
  }

  String _mapStatusToLabel(PermissionStatus status) {
    if (status.isGranted) return 'Notifications allowed';
    if (status.isDenied) return 'Notifications denied';
    if (status.isPermanentlyDenied) return 'Notifications permanently denied';
    if (status.isRestricted) return 'Notifications restricted';
    if (status.isLimited) return 'Notifications limited';
    return 'Unknown';
  }

  Future<bool> _ensureExactAlarmPermission() async {
    // Check if we're on Android (iOS doesn't have this permission)
    if (Theme.of(context).platform != TargetPlatform.android) {
      return true;
    }

    // Check the current status of the exact alarm permission
    final status = await Permission.scheduleExactAlarm.status;

    if (status.isGranted) {
      return true; // Permission already granted
    }

    // Request the permission from the user
    final result = await Permission.scheduleExactAlarm.request();

    // Return true only if the user grants permission
    return result.isGranted;
  }

  Future<bool> _ensureNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      // Try to request permission
      final result = await Permission.notification.request();
      if (result.isGranted) {
        return true;
      }
      // either still denied or blocked — fall through to show dialog
      return false;
    }

    // If permanentlyDenied or restricted: cannot request, need settings
    return false;
  }

  Future<void> _showPermissionDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notification permissions required'),
        content: const Text(
          'To receive reminders, please enable notification permission for this app.\n\n'
          'You can grant it in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // opens the platform app settings page
              await openAppSettings();
              // reload status after returning from settings
              await _loadPermissionStatus();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showExactAlarmPermissionDialog() async {
  if (!mounted) return null;
  
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Precise Reminders'),
      content: const Text(
        'For notifications to appear at the exact time you set, '
        'we need "Schedule Exact Alarms" permission.\n\n'
        'Without it, Android may delay notifications to save battery.\n\n'
        'Would you like to continue with possibly delayed notifications, '
        'or open Settings to enable exact alarms?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Continue Anyway'),
        ),
        TextButton(
          onPressed: () {
            // First close the dialog with 'true' to indicate user wants to open settings
            Navigator.of(ctx).pop(true);
            // Then open settings separately
            openAppSettings();
          },
          child: const Text('Open Settings'),
        ),
      ],
    ),
  );
  
  return result;
}

  Widget _buildPermissionStatus() {
    return Row(
      children: [
        Icon(
          _permissionStatusLabel == 'Notifications allowed' && _hasExactAlarmPermission
              ? Icons.check_circle_outline
              : Icons.info_outline,
          size: 16,
          color: _permissionStatusLabel == 'Notifications allowed' && _hasExactAlarmPermission
              ? Colors.green
              : Colors.orange,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _permissionStatusLabel,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
        ),
        if (_permissionStatusLabel != 'Notifications allowed')
          TextButton(
            onPressed: () async {
              await openAppSettings();
              await _loadPermissionStatus();
              final post = await Permission.notification.status;
              if (post.isGranted) {
                context.read<HabitBloc>().add(
                  HabitRemainderToggleEvent(hasRemainder: true),
                );
              }
            },
            child: const Text('Open Settings'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitBloc, HabitState>(
      buildWhen: (previous, current) {
        if (previous is! AddHabitInitial || current is! AddHabitInitial) {
          return false;
        }

        return previous.hasRemainder != current.hasRemainder ||
            previous.remainderTime != current.remainderTime;
      },
      builder: (context, state) {
        if (state is! AddHabitInitial) return const SizedBox.shrink();
        final bool isExpanded = state.hasRemainder;
        final String time = state.remainderTime;

        return Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Remainder',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: _permissionStatusLabel == 'Notifications allowed' &&
                          !_hasExactAlarmPermission &&
                          Theme.of(context).platform == TargetPlatform.android
                      ? Text(
                          'Tap to enable exact notifications',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.orange),
                        )
                      : null,
                  trailing: Switch.adaptive(
                    value: isExpanded,
                    activeThumbColor: widget.backgroundColor,
                    inactiveThumbColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : widget.backgroundColor,
                    trackOutlineColor: WidgetStatePropertyAll(
                      widget.backgroundColor,
                    ),
                    onChanged: (value) async {
                      // If user is turning off, just dispatch the toggle
                      if (!value) {
                        context.read<HabitBloc>().add(
                          HabitRemainderToggleEvent(hasRemainder: false),
                        );
                        return;
                      }

                      // Step 1: First check notification permission
                      final notificationGranted = await _ensureNotificationPermission();
                      
                      if (!notificationGranted) {
                        // Notification permission not granted - show dialog
                        await _showPermissionDialog();
                        await _loadPermissionStatus();
                        
                        final postStatus = await Permission.notification.status;
                        if (!postStatus.isGranted) {
                          if (!mounted) return;
                          context.read<HabitBloc>().add(
                            HabitRemainderToggleEvent(hasRemainder: false),
                          );
                          return; // Stop here if notification permission is not granted
                        }
                      }

                      // Step 2: Notification permission is granted, now check exact alarm permission
                      final exactAlarmGranted = await _ensureExactAlarmPermission();
                      
                      // Step 3: Handle exact alarm permission result
                      if (!exactAlarmGranted && Theme.of(context).platform == TargetPlatform.android) {
                        // Show exact alarm permission dialog
                        final openSettings = await _showExactAlarmPermissionDialog();
                        
                        if (openSettings == true) {
                          // User chose to open settings, don't enable remainder yet
                          await _loadPermissionStatus();
                          return;
                        }
                        // User chose to continue anyway with possibly delayed notifications
                      }

                      // Step 4: All permissions handled - enable remainder
                      if (!mounted) return;
                      context.read<HabitBloc>().add(
                        HabitRemainderToggleEvent(hasRemainder: true),
                      );
                    },
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Everyday At'),
                            MyCard(
                              backgroundColor: widget.backgroundColor,
                              value: time.isNotEmpty ? time : 'Add Time',
                              onTap: () => showBottomSheet(
                                showDragHandle: true,
                                context: context,
                                builder: (context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AppTimePicker(
                                          onTimeSelected:
                                              (hour, minute, period, dateTime) {
                                                context.read<HabitBloc>().add(
                                                  HabitRemainderEvent(
                                                    remainderTime:
                                                        hour == 0 && minute == 0
                                                        ? ''
                                                        : "$hour:$minute $period",
                                                  ),
                                                );
                                              },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Permission status row
                        _buildPermissionStatus(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}