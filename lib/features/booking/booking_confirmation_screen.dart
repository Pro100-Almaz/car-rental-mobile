import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/primary_button.dart';
import '../home/data/sample_cars.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.carId,
    required this.startDate,
    required this.endDate,
  });

  final String carId;
  final DateTime startDate;
  final DateTime endDate;

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen> {
  _PaymentMethod _selectedPayment = _PaymentMethod.kaspi;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final car = ref.watch(carByIdProvider(widget.carId));

    if (car == null) {
      return const Scaffold(
        body: Center(child: Text('Car not found')),
      );
    }

    final int days =
        widget.endDate.difference(widget.startDate).inDays.clamp(1, 9999);
    final int dailySubtotal = car.pricePerDay * days;
    final int insurance = (car.pricePerDay * 0.15).round();
    final int serviceFee = (car.pricePerDay * 0.08).round();
    final int total = dailySubtotal + insurance + serviceFee;

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.neutral900),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Confirm Booking',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.neutral200),
        ),
      ),
      bottomNavigationBar: _ConfirmBar(
        total: total,
        isLoading: _isLoading,
        onConfirm: () => _handleConfirm(car),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CarCard(car: car),
            const SizedBox(height: AppSpacing.xl),
            _sectionLabel('Trip Details'),
            const SizedBox(height: AppSpacing.sm),
            _TripDatesCard(
              startDate: widget.startDate,
              endDate: widget.endDate,
              days: days,
            ),
            const SizedBox(height: AppSpacing.xl),
            _sectionLabel('Price Breakdown'),
            const SizedBox(height: AppSpacing.sm),
            _PriceCard(
              car: car,
              days: days,
              dailySubtotal: dailySubtotal,
              insurance: insurance,
              serviceFee: serviceFee,
              total: total,
            ),
            const SizedBox(height: AppSpacing.xl),
            _sectionLabel('Payment Method'),
            const SizedBox(height: AppSpacing.sm),
            _PaymentSelector(
              selected: _selectedPayment,
              onChanged: (m) => setState(() => _selectedPayment = m),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.neutral500,
      ),
    );
  }

  Future<void> _handleConfirm(CarListing car) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    ref.read(bookingsProvider.notifier).createBooking(
          car: car,
          startDate: widget.startDate,
          endDate: widget.endDate,
        );

    if (!mounted) return;
    context.go('/bookings');
  }
}

// ─── Car summary card ────────────────────────────────────────────────────────

class _CarCard extends StatelessWidget {
  const _CarCard({required this.car});
  final CarListing car;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: AppColors.elevation1,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: car.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.neutral200),
              errorWidget: (_, _, _) => Container(
                color: AppColors.neutral200,
                child: const Icon(Icons.directions_car_outlined,
                    size: 48, color: AppColors.neutral500),
              ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.confirmation_number_outlined,
                      label: car.plateNumber,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _InfoChip(
                      icon: Icons.category_outlined,
                      label: _capitalize(car.category),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _InfoChip(
                      icon: Icons.star_rounded,
                      label: car.rating.toStringAsFixed(1),
                      iconColor: AppColors.star,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.iconColor = AppColors.neutral500,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Trip dates card ─────────────────────────────────────────────────────────

class _TripDatesCard extends StatelessWidget {
  const _TripDatesCard({
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  final DateTime startDate;
  final DateTime endDate;
  final int days;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, d MMM yyyy');
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: AppColors.elevation1,
      ),
      child: Row(
        children: [
          Expanded(
            child: _DateColumn(
              label: 'Pick-up',
              date: fmt.format(startDate),
            ),
          ),
          Column(
            children: [
              Container(
                width: 40,
                height: 1.5,
                color: AppColors.neutral300,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '$days ${days == 1 ? 'day' : 'days'}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: _DateColumn(
              label: 'Return',
              date: fmt.format(endDate),
              align: CrossAxisAlignment.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  const _DateColumn({
    required this.label,
    required this.date,
    this.align = CrossAxisAlignment.start,
  });

  final String label;
  final String date;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: AppColors.neutral500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

// ─── Price breakdown card ─────────────────────────────────────────────────────

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.car,
    required this.days,
    required this.dailySubtotal,
    required this.insurance,
    required this.serviceFee,
    required this.total,
  });

  final CarListing car;
  final int days;
  final int dailySubtotal;
  final int insurance;
  final int serviceFee;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: AppColors.elevation1,
      ),
      child: Column(
        children: [
          _PriceLine(
            label: '₸ ${_formatPrice(car.pricePerDay)} × $days '
                '${days == 1 ? 'day' : 'days'}',
            value: dailySubtotal,
          ),
          const SizedBox(height: AppSpacing.sm),
          _PriceLine(label: 'Insurance (15%)', value: insurance),
          const SizedBox(height: AppSpacing.sm),
          _PriceLine(label: 'Service fee (8%)', value: serviceFee),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.neutral200, height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ),
              Text(
                '₸ ${_formatPrice(total)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.neutral700,
            ),
          ),
        ),
        Text(
          '₸ ${_formatPrice(value)}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

// ─── Payment method selector ──────────────────────────────────────────────────

enum _PaymentMethod { kaspi, bankCard }

class _PaymentSelector extends StatelessWidget {
  const _PaymentSelector({
    required this.selected,
    required this.onChanged,
  });

  final _PaymentMethod selected;
  final ValueChanged<_PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PaymentTile(
          method: _PaymentMethod.kaspi,
          selected: selected,
          onTap: () => onChanged(_PaymentMethod.kaspi),
          icon: Icons.bolt_rounded,
          iconColor: const Color(0xFFFF6B00),
          title: 'Kaspi Pay',
          subtitle: 'Pay instantly via Kaspi QR',
          badge: 'DEFAULT',
        ),
        const SizedBox(height: AppSpacing.sm),
        _PaymentTile(
          method: _PaymentMethod.bankCard,
          selected: selected,
          onTap: () => onChanged(_PaymentMethod.bankCard),
          icon: Icons.credit_card_rounded,
          iconColor: AppColors.neutral700,
          title: 'Bank Card',
          subtitle: 'Visa, Mastercard, Mir',
        ),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
  });

  final _PaymentMethod method;
  final _PaymentMethod selected;
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;

  bool get _isSelected => method == selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: _isSelected ? AppColors.primaryLight : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _isSelected ? AppColors.primary : AppColors.neutral200,
            width: _isSelected ? 1.5 : 1,
          ),
          boxShadow: _isSelected ? [] : AppColors.elevation1,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isSelected
                    ? AppColors.white
                    : AppColors.neutral100,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _isSelected
                              ? AppColors.primary
                              : AppColors.neutral900,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: _isSelected
                      ? AppColors.primary
                      : AppColors.neutral300,
                  width: 2,
                ),
              ),
              child: _isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: AppColors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom confirm bar ───────────────────────────────────────────────────────

class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar({
    required this.total,
    required this.onConfirm,
    required this.isLoading,
  });

  final int total;
  final VoidCallback onConfirm;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.neutral200, width: 0.5),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.paddingOf(context).bottom + AppSpacing.md,
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total amount',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.neutral500,
                ),
              ),
              Text(
                '₸ ${_formatPrice(total)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: PrimaryButton(
              label: isLoading ? 'Confirming...' : 'Confirm Booking',
              onPressed: isLoading ? null : onConfirm,
              icon: isLoading ? null : Icons.check_circle_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _formatPrice(int value) {
  final str = value.toString();
  final buf = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
    buf.write(str[i]);
  }
  return buf.toString();
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
