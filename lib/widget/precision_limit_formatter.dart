import 'package:flutter/services.dart';
import 'dart:math' as math;

///价格输入框和数量输入框的限制
class PrecisionLimitFormatter extends TextInputFormatter {
  int _scale;
  int maxLength;

  PrecisionLimitFormatter(this._scale,{this.maxLength});

  RegExp exp = new RegExp("[0-9.]");
  static const String POINTER = ".";
  static const String DOUBLE_ZERO = "00";

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {

    if (maxLength != null && maxLength > 0 && newValue.text.runes.length > maxLength) {
      final TextSelection newSelection = newValue.selection.copyWith(
        baseOffset: math.min(newValue.selection.start, maxLength),
        extentOffset: math.min(newValue.selection.end, maxLength),
      );
      final RuneIterator iterator = RuneIterator(newValue.text);
      if (iterator.moveNext())
        for (int count = 0; count < maxLength; ++count)
          if (!iterator.moveNext())
            break;
      final String truncated = newValue.text.substring(0, iterator.rawIndex);
      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }

    ///输入完全删除
    if (newValue.text.isEmpty) {
      return TextEditingValue();
    }

    ///只允许输入小数
    if (!exp.hasMatch(newValue.text)) {
      return oldValue;
    }

    ///包含小数点的情况
    if (newValue.text.contains(POINTER)) {
      ///包含多个小数
      if (newValue.text.indexOf(POINTER) !=
          newValue.text.lastIndexOf(POINTER)) {
        return oldValue;
      }
      String input = newValue.text;
      int index = input.indexOf(POINTER);

      ///小数点后位数
      int lengthAfterPointer = input.substring(index, input.length).length - 1;

      ///小数位大于精度
      if (lengthAfterPointer > _scale) {
        return oldValue;
      }
    } else if (newValue.text.startsWith(POINTER) ||
        newValue.text.startsWith(DOUBLE_ZERO)) {
      ///不包含小数点,不能以“00”开头
      return oldValue;
    }
    return newValue;
  }
}