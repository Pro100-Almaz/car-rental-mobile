import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _loading = false;
  String? _error;
  int _resendSeconds = 30;
  Timer? _timer;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds <= 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    _shakeCtrl.dispose();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _submit() async {
    final code = _code;
    if (code.length < 4) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok =
        await ref.read(currentUserProvider.notifier).verifyOtp(code);
    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      setState(() {
        _loading = false;
        _error = 'Invalid code. Please try again.';
      });
      _shakeCtrl.forward(from: 0);
    }
  }

  void _onDigitChanged(int i, String v) {
    if (v.isNotEmpty) {
      if (i < 3) {
        _focusNodes[i + 1].requestFocus();
      } else {
        _focusNodes[i].unfocus();
        _submit();
      }
    }
  }

  void _onResend() {
    if (_resendSeconds > 0) return;
    for (final c in _controllers) {
      c.clear();
    }
    setState(() => _error = null);
    _focusNodes[0].requestFocus();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.neutral900,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'Verify your number',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Enter the 4-digit code sent to ${widget.phone}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (context, child) {
                      final offset =
                          _shakeCtrl.isAnimating ? 8 * _shakeAnim.value * (1 - _shakeAnim.value) * 4 : 0.0;
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: TextField(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              enabled: !_loading,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutral900,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                  borderSide: BorderSide(
                                    color: _error != null
                                        ? AppColors.error
                                        : AppColors.neutral300,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                  borderSide: const BorderSide(
                                    color: AppColors.neutral200,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              onChanged: (v) => _onDigitChanged(i, v),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          )
                        : GestureDetector(
                            onTap: _resendSeconds == 0 ? _onResend : null,
                            child: Text(
                              _resendSeconds > 0
                                  ? 'Resend in 0:${_resendSeconds.toString().padLeft(2, '0')}'
                                  : 'Resend code',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _resendSeconds > 0
                                    ? AppColors.neutral500
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
