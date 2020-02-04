class ProgressValue {
  final double progress;

  final double value;

  const ProgressValue({this.value = 0.0, this.progress = 0.0});

  @override
  String toString() {
    return 'ProgressValue{progress: $progress, value: $value}';
  }
}
