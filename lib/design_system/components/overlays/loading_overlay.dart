import 'package:flutter/material.dart';
import '../../tokens/colors.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  static Future<T> run<T>({
    required BuildContext context,
    required Future<T> Function() task,
    String? message,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: _LoadingDialog(message: message),
        ),
      ),
    ).then((_) => task());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: Center(
              child: _LoadingDialog(message: message),
            ),
          ),
      ],
    );
  }
}

class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: NamaaColors.primary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: NamaaColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
