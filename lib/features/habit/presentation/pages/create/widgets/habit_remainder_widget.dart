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

  @override
  void initState() {
    super.initState();
    _loadPermissionStatus();
  }

  Future<void> _loadPermissionStatus() async {
    final status = await Permission.notification.status;
    if (!mounted) return;
    setState(() {
      _permissionStatusLabel = _mapStatusToLabel(status);
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
            onPressed: () {
              Navigator.of(ctx).pop();
            },
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

                      // value == true: check / request notification permission
                      final granted = await _ensureNotificationPermission();

                      // Update local permission label (request may have changed it)
                      await _loadPermissionStatus();

                      if (granted) {
                        // permission available — enable remainder
                        if (!mounted) return;
                        context.read<HabitBloc>().add(
                          HabitRemainderToggleEvent(hasRemainder: true),
                        );
                      } else {
                        // permission not granted — show dialog to direct user to settings
                        await _showPermissionDialog();

                        // After dialog (and possible settings visit) reload status
                        await _loadPermissionStatus();

                        // If after settings user granted, enable remainder; otherwise keep it off.
                        final postStatus = await Permission.notification.status;
                        if (postStatus.isGranted) {
                          if (!mounted) return;
                          context.read<HabitBloc>().add(
                            HabitRemainderToggleEvent(hasRemainder: true),
                          );
                        } else {
                          // ensure the toggle remains off in the bloc/state
                          if (!mounted) return;
                          context.read<HabitBloc>().add(
                            HabitRemainderToggleEvent(hasRemainder: false),
                          );
                        }
                      }
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
                        Row(
                          children: [
                            Icon(
                              _permissionStatusLabel == 'Notifications allowed'
                                  ? Icons.check_circle_outline
                                  : Icons.info_outline,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _permissionStatusLabel,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontStyle: FontStyle.italic),
                              ),
                            ),
                            if (_permissionStatusLabel !=
                                'Notifications allowed')
                              TextButton(
                                onPressed: () async {
                                  await openAppSettings();
                                  await _loadPermissionStatus();
                                  final post =
                                      await Permission.notification.status;
                                  if (post.isGranted) {
                                    context.read<HabitBloc>().add(
                                      HabitRemainderToggleEvent(
                                        hasRemainder: true,
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Open Settings'),
                              ),
                          ],
                        ),
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
