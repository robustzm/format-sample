part of katana_form;

/// Displays the label for each item on the form.
///
/// Pass the text to be displayed to [label].
///
/// By specifying [icon], an icon is displayed before [label].
///
/// You can change the color of [label] and [icon] by specifying [color].
///
/// If [prefix] and [suffix] are specified, widgets can be placed before and after the dividing line.
///
/// フォームの各項目のラベルを表示します。
///
/// [label]に表示するテキストを渡します。
///
/// [icon]を指定することで[label]の前にアイコンが表示されます。
///
/// [color]を指定すると[label]と[icon]の色を変えることができます。
///
/// [prefix]と[suffix]を指定すると分断線の前後にWidgetを配置することができます。
class FormLabel extends StatelessWidget {
  /// Displays the label for each item on the form.
  ///
  /// Pass the text to be displayed to [label].
  ///
  /// By specifying [icon], an icon is displayed before [label].
  ///
  /// You can change the color of [label] and [icon] by specifying [color].
  ///
  /// If [prefix] and [suffix] are specified, widgets can be placed before and after the dividing line.
  ///
  /// フォームの各項目のラベルを表示します。
  ///
  /// [label]に表示するテキストを渡します。
  ///
  /// [icon]を指定することで[label]の前にアイコンが表示されます。
  ///
  /// [color]を指定すると[label]と[icon]の色を変えることができます。
  ///
  /// [prefix]と[suffix]を指定すると分断線の前後にWidgetを配置することができます。
  const FormLabel(
    this.label, {
    super.key,
    this.icon,
    this.color,
    this.prefix,
    this.suffix,
  });

  /// Display the icon in front of [label].
  ///
  /// [label]の前にアイコンを表示します。
  final IconData? icon;

  /// Change the color of [label] and [icon].
  ///
  /// [label]と[icon]の色を変更します。
  final Color? color;

  /// Widget displayed before the dividing line.
  ///
  /// 分断線の前に表示されるWidget。
  final Widget? prefix;

  /// Widget displayed after the dividing line.
  ///
  /// 分断線の後に表示されるWidget。
  final Widget? suffix;

  /// Form labels.
  ///
  /// フォームのラベル。
  final String label;

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ??
        Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.5) ??
        Theme.of(context).colorScheme.onBackground.withOpacity(0.5);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(width: 12, child: Divider(color: color)),
        const SizedBox(width: 4),
        if (prefix != null) ...[
          prefix!,
          const SizedBox(width: 4),
        ],
        if (icon != null) ...[
          Icon(
            icon,
            color: color ?? dividerColor,
            size: 12,
          ),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: TextStyle(
            color: color ?? dividerColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(child: Divider(color: color)),
        if (suffix != null) ...[
          const SizedBox(width: 4),
          suffix!,
          SizedBox(width: 12, child: Divider(color: color)),
        ],
      ],
    );
  }
}
