import 'package:flutter/material.dart';

import '../service/registration_status_service.dart';

/// Card "Status Proses Pendaftaran" dengan progress 3 langkah.
/// Hanya ditampilkan saat status = not_registered atau pending.
/// Saat status = accepted, widget ini mengembalikan SizedBox.shrink().
class RegistrationStatusCard extends StatelessWidget {
  const RegistrationStatusCard({super.key, required this.status});

  final RegistrationStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == RegistrationStatus.accepted) return const SizedBox.shrink();

    final activeStep = switch (status) {
      RegistrationStatus.notRegistered => 0,
      RegistrationStatus.pending => 1,
      RegistrationStatus.accepted => 2,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EF)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Proses Pendaftaran',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF172033)),
          ),
          const SizedBox(height: 16),
          _RegistrationProgressStepper(activeStep: activeStep),
        ],
      ),
    );
  }
}

class _RegistrationProgressStepper extends StatelessWidget {
  const _RegistrationProgressStepper({required this.activeStep});

  final int activeStep;

  static const _labels = ['Daftar', 'Diproses', 'Diterima'];
  static const _primary = Color(0xFF2457D6);
  static const _done = Color(0xFF16A87A);
  static const _inactive = Color(0xFFD1D5DB);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length * 2 - 1, (i) {
        // Connector line
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          final filled = stepIndex < activeStep;
          return Expanded(
            child: Container(
              height: 2,
              color: filled ? _done : _inactive,
            ),
          );
        }

        // Step circle
        final stepIndex = i ~/ 2;
        final isDone = stepIndex < activeStep;
        final isActive = stepIndex == activeStep;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? _done
                    : isActive
                        ? _primary
                        : Colors.white,
                border: Border.all(
                  color: isDone ? _done : isActive ? _primary : _inactive,
                  width: 2,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : isActive
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          )
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _inactive,
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _labels[stepIndex],
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isDone
                    ? _done
                    : isActive
                        ? _primary
                        : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        );
      }),
    );
  }
}
