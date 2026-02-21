import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatapp/core/constants/app_colors.dart';
import 'package:chatapp/data/models/chat_group.dart';
import 'package:chatapp/injection.dart';
import 'package:chatapp/presentation/verify_pin/bloc/verify_pin_bloc.dart';
import 'package:chatapp/presentation/verify_pin/bloc/verify_pin_event.dart';
import 'package:chatapp/presentation/verify_pin/bloc/verify_pin_state.dart';

class VerifyPinDialog extends StatelessWidget {
  final ChatGroup group;
  final VoidCallback onVerified;

  const VerifyPinDialog({
    super.key,
    required this.group,
    required this.onVerified,
  });

  static Future<bool?> show(
    BuildContext context, {
    required ChatGroup group,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider(
        create: (context) => sl<VerifyPinBloc>(),
        child: VerifyPinDialog(
          group: group,
          onVerified: () {
            Navigator.of(context).pop(true);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VerifyPinBloc, VerifyPinState>(
      listener: (context, state) {
        if (state is VerifyPinSuccess) {
          onVerified();
        }
      },
      builder: (context, state) {
        return _VerifyPinContent(
          group: group,
          isLoading: state is VerifyPinLoading,
          errorMessage: state is VerifyPinError ? state.message : null,
          onVerify: (pin) {
            context.read<VerifyPinBloc>().add(
                  VerifyPinSubmitEvent(
                    groupId: group.id ?? '',
                    pin: pin,
                  ),
                );
          },
        );
      },
    );
  }
}

class _VerifyPinContent extends StatefulWidget {
  final ChatGroup group;
  final bool isLoading;
  final String? errorMessage;
  final void Function(int pin) onVerify;

  const _VerifyPinContent({
    required this.group,
    required this.isLoading,
    required this.errorMessage,
    required this.onVerify,
  });

  @override
  State<_VerifyPinContent> createState() => _VerifyPinContentState();
}

class _VerifyPinContentState extends State<_VerifyPinContent> {
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _handleVerify() {
    if (_formKey.currentState!.validate()) {
      final pinText = _pinController.text.trim();
      if (pinText.length == 6) {
        widget.onVerify(int.parse(pinText));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Masukkan PIN Grup",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Masukkan 6 digit PIN untuk akses\n${widget.group.name}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                obscureText: true,
                enabled: !widget.isLoading,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "• • • • • •",
                  hintStyle: TextStyle(
                    fontSize: 24,
                    letterSpacing: 4,
                    color: AppColors.textHint,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'PIN harus diisi';
                  }
                  if (value.length != 6) {
                    return 'PIN harus 6 digit';
                  }
                  if (int.tryParse(value) == null) {
                    return 'PIN harus berupa angka';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _handleVerify(),
              ),
            ),
            if (widget.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.errorMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: widget.isLoading
                        ? null
                        : () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.divider),
                      ),
                    ),
                    child: const Text(
                      "Batal",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.isLoading ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.surface,
                            ),
                          )
                        : const Text(
                            "Verifikasi",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.surface,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
