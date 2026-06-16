import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../data/repositories/water_repository_impl.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/repositories/water_repository.dart';

final localDataSourceProvider = Provider<LocalDataSource>(
  (_) => LocalDataSource(),
);

final waterRepositoryProvider = Provider<WaterRepository>(
  (ref) => WaterRepositoryImpl(ref.read(localDataSourceProvider)),
);

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => ReminderRepositoryImpl(ref.read(localDataSourceProvider)),
);
