import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/time_table.dart';
import '../services/local_cache.dart';
import '../services/notification.dart';

class TimetableState {
  final bool isLoading;
  final String? errorMessage;
  final List<TimeTable> slots;
  final bool isOffline;
  final DateTime? lastCacheUpdate;

  TimetableState({
    this.isLoading = false,
    this.errorMessage,
    this.slots = const [],
    this.isOffline = false,
    this.lastCacheUpdate,
  });

  TimetableState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TimeTable>? slots,
    bool? isOffline,
    DateTime? lastCacheUpdate,
  }) {
    return TimetableState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      slots: slots ?? this.slots,
      isOffline: isOffline ?? this.isOffline,
      lastCacheUpdate: lastCacheUpdate ?? this.lastCacheUpdate,
    );
  }
}

class TimeTableViewModel extends StateNotifier<TimetableState> {
  final SupabaseClient _supabase;

  TimeTableViewModel(this._supabase) : super(TimetableState());

  Future<void> fetchSlots({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Check if we have cached data and if we should use it
      final hasCachedData = await TimetableDB.instance.hasCachedData();
      final lastUpdate = await TimetableDB.instance.getLastCacheUpdate();

      // If not forcing refresh and we have recent cached data, use it first
      if (!forceRefresh && hasCachedData) {
        final cacheAge = lastUpdate != null
            ? DateTime.now().difference(lastUpdate).inHours
            : 0;

        // Use cache if it's less than 24 hours old
        if (cacheAge < 24) {
          final cachedSlots = await TimetableDB.instance.getSlots();
          if (cachedSlots.isNotEmpty) {
            // Schedule notifications safely
            _scheduleNotificationsSafely(cachedSlots);
            state = state.copyWith(
              isLoading: false,
              slots: cachedSlots,
              isOffline: false,
              lastCacheUpdate: lastUpdate,
              errorMessage: null,
            );

            // Try to fetch fresh data in background
            _fetchSlotsFromServer(background: true);
            return;
          }
        }
      }

      // Fetch fresh data from server
      await _fetchSlotsFromServer();

    } catch (e) {
      // Try to load from cache as fallback
      await _loadFromCache(errorMessage: e.toString());
    }
  }

  Future<void> _fetchSlotsFromServer({bool background = false}) async {
    try {
      final userEmail = _supabase.auth.currentUser?.email;
      if (userEmail == null) throw Exception("User not logged in");

      final userData = await _supabase
          .from('users')
          .select('program_id')
          .eq('email', userEmail)
          .single();

      final programId = userData['program_id'];

      final response = await _supabase
          .from('timetable')
          .select('t_id, program_id, course_id, class_code, day, start_time, end_time, courses(course_name)')
          .eq('program_id', programId)
          .order('start_time', ascending: true);

      final slots = (response as List<dynamic>)
          .map((s) => TimeTable.fromMap(s as Map<String, dynamic>))
          .toList();

      // Save to SQLite cache with error handling
      try {
        await TimetableDB.instance.saveSlots(slots);
      } catch (cacheError) {
        // Try to recreate the database schema
        try {
          await TimetableDB.instance.recreateDatabase();
          await TimetableDB.instance.saveSlots(slots);
        } catch (recreateError) {
          // Continue without cache - app should still work with server data
        }
      }

      // Schedule notifications safely
      _scheduleNotificationsSafely(slots);

      if (!background) {
        state = state.copyWith(
          isLoading: false,
          slots: slots,
          isOffline: false,
          lastCacheUpdate: DateTime.now(),
          errorMessage: null,
        );
      }
    } on SocketException {
      // Network error - load from cache
      await _loadFromCache(
        errorMessage: background ? null : 'No internet connection. Using cached data.',
        isOffline: true,
      );
    } on PostgrestException catch (e) {
      // Database error
      if (!background) {
        await _loadFromCache(
          errorMessage: 'Server error: ${e.message}. Using cached data.',
          isOffline: false,
        );
      }
    } catch (e) {
      // Other errors
      if (!background) {
        await _loadFromCache(
          errorMessage: 'Error fetching data: $e. Using cached data.',
          isOffline: false,
        );
      }
    }
  }

  Future<void> _loadFromCache({String? errorMessage, bool isOffline = true}) async {
    try {
      final cachedSlots = await TimetableDB.instance.getSlots();
      final lastUpdate = await TimetableDB.instance.getLastCacheUpdate();

      if (cachedSlots.isNotEmpty) {
        // Schedule notifications safely
        _scheduleNotificationsSafely(cachedSlots);
        state = state.copyWith(
          isLoading: false,
          slots: cachedSlots,
          isOffline: isOffline,
          lastCacheUpdate: lastUpdate,
          errorMessage: errorMessage,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: isOffline
              ? 'No internet connection and no cached timetable available'
              : 'No timetable data available',
          isOffline: isOffline,
        );
      }
    } catch (e) {
      // If cache loading fails, try to recreate database
      try {
        await TimetableDB.instance.recreateDatabase();
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Cache corrupted. Please refresh to reload data.',
          isOffline: isOffline,
          slots: [], // Clear any corrupted data
        );
      } catch (recreateError) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Database error. Please restart the app.',
          isOffline: isOffline,
          slots: [],
        );
      }
    }
  }

  Future<List<TimeTable>> getSlotsForDay(String day) async {
    try {
      // First try from current state
      if (state.slots.isNotEmpty) {
        return state.slots
            .where((slot) => slot.day.toLowerCase() == day.toLowerCase())
            .toList();
      }

      // If no slots in state, try cache
      return await TimetableDB.instance.getSlotsByDay(day);
    } catch (e) {
      return [];
    }
  }

  Future<void> refreshTimetable() async {
    await fetchSlots(forceRefresh: true);
  }

  Future<void> clearCache() async {
    try {
      await TimetableDB.instance.clearCache();
      // Also cancel all notifications when clearing cache
      await _cancelAllNotificationsSafely();
      state = state.copyWith(
        slots: [],
        errorMessage: null, // Clear error message when cache is cleared
        lastCacheUpdate: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error clearing cache: $e');
    }
  }

  // Add method to fix database issues
  Future<void> fixDatabaseIssues() async {
    try {
      await TimetableDB.instance.recreateDatabase();
      // Cancel notifications when fixing database
      await _cancelAllNotificationsSafely();
      state = state.copyWith(
        errorMessage: 'Database fixed. Please refresh to reload data.',
        slots: [],
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Could not fix database. Please reinstall the app.',
      );
    }
  }

  // Safe notification scheduling with comprehensive error handling
  void _scheduleNotificationsSafely(List<TimeTable> slots) {
    // Use a separate isolate or microtask to avoid blocking the main thread
    Future.microtask(() async {
      try {
        await _scheduleNotifications(slots);
      } catch (e) {
        debugPrint('Error scheduling notifications: $e');
        // Don't crash the app if notifications fail
      }
    });
  }

  // Safe notification cancellation
  Future<void> _cancelAllNotificationsSafely() async {
    try {
      await NotificationService.instance.cancelAll();
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
      // Don't crash if cancellation fails
    }
  }

  Future<void> _scheduleNotifications(List<TimeTable> slots) async {
    if (slots.isEmpty) return;

    try {
      // First, safely cancel existing notifications
      await _cancelAllNotificationsSafely();

      // Validate notification service is available and has permission
      if (!await NotificationService.instance.isAvailable()) {
        debugPrint('Notification service not available');
        return;
      }

      if (!await NotificationService.instance.hasPermission()) {
        debugPrint('No notification permission');
        return;
      }

      int successCount = 0;
      final now = DateTime.now();

      // Limit number of notifications to avoid hitting system limits
      final limitedSlots = slots.take(50).toList();

      for (int i = 0; i < limitedSlots.length; i++) {
        final slot = limitedSlots[i];

        try {
          final weekday = _weekdayNumber(slot.day);

          // Skip invalid days
          if (weekday < DateTime.monday || weekday > DateTime.sunday) {
            continue;
          }

          // Base class start time
          DateTime classTime = DateTime(
            now.year,
            now.month,
            now.day,
            slot.startTime.hour,
            slot.startTime.minute,
          );

          // Validate and shift to the next occurrence if needed
          if (weekday != now.weekday || classTime.isBefore(now.add(const Duration(minutes: 5)))) {
            int daysToAdd = 0;
            while (classTime.weekday != weekday || classTime.isBefore(now.add(const Duration(minutes: 5)))) {
              classTime = classTime.add(const Duration(days: 1));
              daysToAdd++;
              if (daysToAdd > 14) break; // safety
            }
          }

          // Notification time = 2 minutes before class
          final notifyTime = classTime.subtract(const Duration(minutes: 2));

          // Only schedule if valid and within 7 days
          if (notifyTime.isAfter(now) && notifyTime.difference(now).inDays <= 7) {
            final title = 'Class Reminder';
            final body =
                '${_sanitizeString(slot.courseName)} (${_sanitizeString(slot.classCode)}) starts at '
                '${slot.startTime.hour}:${slot.startTime.minute.toString().padLeft(2, '0')}';

            final scheduled = await NotificationService.instance.schedule(
              id: i + 1000,
              title: title,
              body: body,
              dateTime: notifyTime,
              payload: 'timetable_${slot.day}_${slot.classCode}',
            );

            if (scheduled) {
              successCount++;
            }
          }
        } catch (slotError) {
          debugPrint('Error scheduling notification for slot: $slotError');
          continue;
        }
      }

      debugPrint('Successfully scheduled $successCount notifications out of ${limitedSlots.length} slots');

      final pending = await NotificationService.instance.getPendingNotifications();
      debugPrint('Total pending notifications: ${pending.length}');
    } catch (e) {
      debugPrint('Critical error in notification scheduling: $e');
    }
  }


  // Helper method to sanitize strings for notifications
  String _sanitizeString(String? input) {
    if (input == null) return '';
    // Remove potentially problematic characters and limit length
    return input
        .replaceAll(RegExp(r'[^\w\s\-\(\)]'), '')
        .trim()
        .substring(0, input.length > 50 ? 50 : input.length);
  }

  int _weekdayNumber(String day) {
    final dayLower = day.toLowerCase().trim();
    switch (dayLower) {
      case 'monday':
        return DateTime.monday;
      case 'tuesday':
        return DateTime.tuesday;
      case 'wednesday':
        return DateTime.wednesday;
      case 'thursday':
        return DateTime.thursday;
      case 'friday':
        return DateTime.friday;
      case 'saturday':
        return DateTime.saturday;
      case 'sunday':
        return DateTime.sunday;
      default:
        debugPrint('Unknown day: $day');
        return DateTime.monday;
    }
  }

  // Add method to manually reschedule notifications
  Future<void> rescheduleNotifications() async {
    try {
      if (state.slots.isNotEmpty) {
        _scheduleNotificationsSafely(state.slots);
      }
    } catch (e) {
      debugPrint('Error rescheduling notifications: $e');
    }
  }

  // Add method to check notification permissions
  Future<bool> checkNotificationPermissions() async {
    try {
      return await NotificationService.instance.hasPermission();
    } catch (e) {
      debugPrint('Error checking notification permissions: $e');
      return false;
    }
  }
}

final slotsProvider = StateNotifierProvider<TimeTableViewModel, TimetableState>((ref) {
  final supabase = Supabase.instance.client;
  return TimeTableViewModel(supabase);
});