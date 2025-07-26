import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final bool isMobile;

  const AppSettings({required this.isMobile});

  const AppSettings.empty() : this(isMobile: false);

  AppSettings copyWith({bool? isMobile}) {
    return AppSettings(isMobile: isMobile ?? this.isMobile);
  }

  @override
  List<Object?> get props => [isMobile];
}
