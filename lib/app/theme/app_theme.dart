import 'package:flutter/material.dart';

import '../../shared/theme/theme.dart';
import '../../shared/theme/util.dart';

class AppTheme {
  static MaterialTheme build(BuildContext context) {
    final textTheme = createTextTheme(context, 'Ubuntu', 'Aclonica');
    return MaterialTheme(textTheme);
  }
}
