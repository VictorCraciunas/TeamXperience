String formatRemaining(Duration duration) {
  final total = duration.isNegative ? Duration.zero : duration;
  final hours = total.inHours;
  final minutes = total.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = total.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
