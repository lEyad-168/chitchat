import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String calculateTimeSinceLastMessage(dynamic timestamp, WidgetRef ref) {
  if (timestamp == null) {
    return "";
  }

  if (timestamp is Timestamp) {
    timestamp = timestamp.toDate();
  } else if (timestamp is String) {
    timestamp = DateTime.parse(timestamp.toString());
  } else if (timestamp is! DateTime) {
    return "Invalid date";
  }

  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inHours < 24) {
    if (difference.inMinutes < 1) {
      return "Now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ${"ago"}";
    } else {
      return "${difference.inHours} h ${"ago"}";
    }
  } else {
    return DateFormat("dd/MM/yyyy").format(timestamp);
  }
}
