class UploadProgress {
  final int sent;
  final int total;
  final int received;
  final double percentSent;
  final String formattedSent;
  final String formattedTotal;
  final String formattedReceived;
  final String formattedPercentSent;

  UploadProgress(
    this.sent,
    this.total,
    this.received,
    this.percentSent,
    {
      this.formattedSent,
      this.formattedTotal,
      this.formattedReceived,
      this.formattedPercentSent,
    }
  );

  @override
  String toString() => 'UploadProgress(sent: $sent, total: $total, received: $received, percentSent: $percentSent)';
}
