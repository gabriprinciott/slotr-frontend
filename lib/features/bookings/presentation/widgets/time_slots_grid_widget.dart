import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/booking_bloc.dart';
import 'slot_item_widget.dart';

class TimeSlotsGridWidget extends StatelessWidget {
  final String? selectedTimeSlot;
  final ValueChanged<String>? onSlotSelected;

  const TimeSlotsGridWidget({
    super.key,
    this.selectedTimeSlot,
    this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state.status == BookingStatus.loading && state.bookings.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }


        final List<String> slots = List.generate(
          9,
          (index) {
            final startHour = (9 + index).toString().padLeft(2, '0');
            final endHour = (10 + index).toString().padLeft(2, '0');
            return "$startHour:00-$endHour:00";
          },
        );

        final dateString = _formatDate(state.selectedDate);

        final isMobile = MediaQuery.of(context).size.width < 600;

        return GridView.builder(
          padding: const EdgeInsets.all(24.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 3,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: isMobile ? 1.8 : 2.0,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final time = slots[index];
            final slotKey = "${dateString}_$time";

            final isBooked = state.bookings.any((b) => b.timeSlot == time);
            final isLocked = state.lockedSlots.contains(slotKey);
            final isSelected = selectedTimeSlot == time;

            SlotState slotState = SlotState.available;
            if (isBooked) {
              slotState = SlotState.booked;
            } else if (isSelected) {
              slotState = SlotState.selected;
            } else if (isLocked) {
              slotState = SlotState.locked;
            }

            return SlotItemWidget(
              time: time,
              state: slotState,
              onTap: () {
                if (slotState == SlotState.available || slotState == SlotState.selected) {

                  if (selectedTimeSlot != null && selectedTimeSlot != time) {
                    context.read<BookingBloc>().add(UnlockSlot(date: dateString, timeSlot: selectedTimeSlot!));
                  }
                  
                  if (slotState != SlotState.selected) {

                    context.read<BookingBloc>().add(LockSlot(date: dateString, timeSlot: time));
                    onSlotSelected?.call(time);
                  } else {

                    context.read<BookingBloc>().add(UnlockSlot(date: dateString, timeSlot: time));
                    onSlotSelected?.call('');
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
