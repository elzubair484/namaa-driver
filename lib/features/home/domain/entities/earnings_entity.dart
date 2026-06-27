import 'package:equatable/equatable.dart';

class EarningsEntity extends Equatable {
  const EarningsEntity({
    required this.totalEarnings,
    required this.tripsCount,
    required this.period,
  });

  final double totalEarnings;
  final int tripsCount;
  final String period;

  @override
  List<Object?> get props => [totalEarnings, tripsCount, period];
}
