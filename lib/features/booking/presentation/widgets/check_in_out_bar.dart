import 'package:flutter/material.dart';

import '../../booking_logic/stay_dates.dart';
import '../theme/booking_colors.dart';
import 'stay_date_format.dart';

class CheckInOutBar extends StatelessWidget implements PreferredSizeWidget {
  const CheckInOutBar({
    super.key,
    required this.stay,
    required this.onFieldTap,
  });

  final StayDates stay;
  final ValueChanged<StayField> onFieldTap;

  @override
  Size get preferredSize => const Size.fromHeight(108);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: BookingColors.navyLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BookingColors.gold.withValues(alpha: 0.4)),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _StayFieldButton(
                  label: 'CHECK-IN',
                  date: stay.checkIn,
                  alignment: CrossAxisAlignment.start,
                  onTap: () => onFieldTap(StayField.checkIn),
                ),
              ),
              _NightsBadge(nights: stay.nights),
              Expanded(
                child: _StayFieldButton(
                  label: 'CHECK-OUT',
                  date: stay.checkOut,
                  alignment: CrossAxisAlignment.end,
                  onTap: () => onFieldTap(StayField.checkOut),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StayFieldButton extends StatelessWidget {
  const _StayFieldButton({
    required this.label,
    required this.date,
    required this.alignment,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final CrossAxisAlignment alignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: alignment,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: BookingColors.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                StayDateFormat.dayMonth(date),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                StayDateFormat.weekday(date),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NightsBadge extends StatelessWidget {
  const _NightsBadge({required this.nights});

  final int nights;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 1,
          height: 12,
          color: BookingColors.gold.withValues(alpha: 0.35),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: BookingColors.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: BookingColors.gold.withValues(alpha: 0.55),
            ),
          ),
          child: Text(
            StayDateFormat.nightsShort(nights),
            style: const TextStyle(
              color: BookingColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Container(
          width: 1,
          height: 12,
          color: BookingColors.gold.withValues(alpha: 0.35),
        ),
      ],
    );
  }
}
