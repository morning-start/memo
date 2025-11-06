
/// 时间持续时间类
///
/// 自定义的时间持续时间表示类，支持年、月、天时间单位。
/// 用于表示倒计时、任务持续时间等场景，提供灵活的时间单位转换和计算。
///
/// 功能特点：
/// - 支持年、月、天三种时间单位
/// - 提供总天数计算和转换方法
/// - 支持从总天数反向计算年、月、天
/// - 不可变对象，确保数据一致性
///
/// 使用示例：
/// ```dart
/// // 创建持续时间对象
/// final duration = Sustain(years: 1, months: 2, days: 15);
/// 
/// // 获取总天数
/// int total = duration.totalDays; // 约 435 天
/// 
/// // 从总天数创建持续时间
/// final fromTotal = Sustain.fromDays(435);
/// print('年: ${fromTotal.years}, 月: ${fromTotal.months}, 天: ${fromTotal.days}');
/// 
/// // 创建只有天数的持续时间
/// final daysOnly = Sustain(days: 30);
/// 
/// // 创建只有月数的持续时间
/// final monthsOnly = Sustain(months: 6);
/// ```
///
/// 注意事项：
/// - 此类使用简化的时间计算（1年=365天，1月=30天），不适用于精确的时间计算
/// - 月份天数按30天计算，不考虑实际月份的天数差异
/// - 不考虑闰年等复杂情况，仅适用于一般场景
class Sustain {
  /// 年数，默认值为0
  final int years;
  
  /// 月数，默认值为0
  final int months;
  
  /// 天数，默认值为0
  final int days;

  /// 构造函数
  /// 
  /// 创建一个新的持续时间实例，可以指定年、月、天。
  /// 所有参数都有默认值0，可以只指定部分时间单位。
  /// 
  /// 参数：
  ///   - years - int，年数，默认为0
  ///   - months - int，月数，默认为0
  ///   - days - int，天数，默认为0
  /// 
  /// 使用示例：
  /// ```dart
  /// // 创建1年2个月15天的持续时间
  /// final duration1 = Sustain(years: 1, months: 2, days: 15);
  /// 
  /// // 创建只有30天的持续时间
  /// final duration2 = Sustain(days: 30);
  /// 
  /// // 创建空持续时间
  /// final duration3 = Sustain();
  /// ```
  Sustain({this.years = 0, this.months = 0, this.days = 0});

  /// 计算并返回总天数
  /// 
  /// 将年、月、天转换为总天数，使用简化的计算方式：
  /// - 1年 = 365天
  /// - 1月 = 30天
  /// 
  /// 返回值：int，总天数
  /// 
  /// 使用示例：
  /// ```dart
  /// final duration = Sustain(years: 1, months: 2, days: 15);
  /// int total = duration.totalDays; // 返回 435 (365 + 60 + 15)
  /// ```
  int get totalDays {
    return years * 365 + months * 30 + days;
  }

  /// 从总天数创建Sustain实例
  /// 
  /// 将总天数转换为年、月、天的组合，使用简化的计算方式：
  /// - 1年 = 365天
  /// - 1月 = 30天
  /// 
  /// 参数：
  ///   - days - int，总天数
  /// 
  /// 返回值：Sustain，转换后的持续时间对象
  /// 
  /// 使用示例：
  /// ```dart
  /// // 从435天创建持续时间
  /// final duration = Sustain.fromDays(435);
  /// print('年: ${duration.years}, 月: ${duration.months}, 天: ${duration.days}');
  /// // 输出: 年: 1, 月: 2, 天: 15
  /// 
  /// // 从30天创建持续时间
  /// final month = Sustain.fromDays(30);
  /// print('年: ${month.years}, 月: ${month.months}, 天: ${month.days}');
  /// // 输出: 年: 0, 月: 1, 天: 0
  /// ```
  static Sustain fromDays(int days) {
    // 计算年数
    int years = days ~/ 365;
    days %= 365;
    
    // 计算月数
    int months = days ~/ 30;
    days %= 30;
    
    // 返回转换后的持续时间对象
    return Sustain(years: years, months: months, days: days);
  }
}
