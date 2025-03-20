
/// 自定义的Sustain类，支持年、月、天时间单位
class Sustain {
  final int years;
  final int months;
  final int days;

  Sustain({this.years = 0, this.months = 0, this.days = 0});

  /// 将Sustain转换为总天数
  int get totalDays {
    return years * 365 + months * 30 + days;
  }


  /// 从总天数创建Sustain
  static Sustain fromDays(int days) {
    int years = days ~/ 365;
    days %= 365;
    int months = days ~/ 30;
    days %= 30;
    return Sustain(years: years, months: months, days: days);
  }
}
