/**
 * Format class that takes in values to conform to graph generation
 */
class formattedWeekEntry {
  double mass;
  String day;
  formattedWeekEntry(this.mass, this.day);
}

class MassEntry {

  double mass;
  final DateTime dateTimeValue;
  final String timestamp, shortenedTime, day, month, year;

  MassEntry (
      this.mass,
      this.timestamp,
      this.shortenedTime,
      this.dateTimeValue,
      this.day,
      this.month,
      this.year);

  MassEntry.fromMap(Map<String, dynamic> map)
      : assert(map['mass'] != null),
        assert(map['timestamp'] != null),
        assert(map['timestamp2'] != null),
        assert(map['day'] != null),
        assert(map['month'] != null),
        assert(map['year'] != null),
        mass = double.parse(map['mass']),
        timestamp = map['timestamp'],
        shortenedTime = map['timestamp2'],
        dateTimeValue = DateTime.parse(map['timestamp']),
        day = map['day'],
        month = map['month'],
        year = map['year'];


}
