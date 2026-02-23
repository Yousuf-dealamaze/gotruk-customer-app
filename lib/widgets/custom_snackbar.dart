import 'package:flutter/material.dart';
import 'package:gotruck_customer/core/theme/colors.dart';
import 'package:gotruck_customer/router/app_router.dart';

class CustomSnackbar {
  static void show({
    required String message,
    Color? backgroundColor,
    Color? textColor,
    SnackBarAction? action,
    double borderRadius = 0.0,
    double margin = 0.0,
    double padding = 10.0,
    bool isSuccess = false,
  }) {
    final currentContext = navigatorKey.currentContext;
    if (currentContext == null) {
      return;
    }
    final errorColor = Theme.of(currentContext).colorScheme.error;
    final effectiveTextColor =
        textColor ?? Theme.of(currentContext).colorScheme.onError;
    final effectiveBackgroundColor =
        backgroundColor ?? (isSuccess ? successColor : errorColor);

    final snackBar = SnackBar(
      content: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: effectiveBackgroundColor),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // const SizedBox(width: 48),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: TextStyle(
                          color: effectiveTextColor,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: effectiveBackgroundColor,
      action: action,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: EdgeInsets.all(margin),
      padding: EdgeInsets.all(padding),
    );

    ScaffoldMessenger.of(currentContext).showSnackBar(snackBar);
  }
}
