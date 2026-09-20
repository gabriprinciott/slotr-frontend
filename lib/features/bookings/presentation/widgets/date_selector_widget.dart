import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/booking_bloc.dart';

class DateSelectorWidget extends StatelessWidget {
  const DateSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      buildWhen: (prev, curr) => prev.selectedDate != curr.selectedDate,
      builder: (context, state) {
        final date = state.selectedDate;
        final formatter = DateFormat('MMMM d, yyyy');

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  final newDate = date.subtract(const Duration(days: 1));
                  context.read<BookingBloc>().add(FetchBookings(date: _formatDate(newDate)));
                },
              ),
              Expanded(
                child: Text(
                  formatter.format(date),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  final newDate = date.add(const Duration(days: 1));
                  context.read<BookingBloc>().add(FetchBookings(date: _formatDate(newDate)));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
