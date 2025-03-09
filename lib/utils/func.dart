import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, bool res, String success,
    {String? fail, VoidCallback? onSuccess, VoidCallback? onFail}) {
  if (res) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success),
      ),
    );
    onSuccess?.call(); // 执行成功回调
  } else if (fail != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(fail),
      ),
    );
    onFail?.call(); // 执行失败回调
  }
}
