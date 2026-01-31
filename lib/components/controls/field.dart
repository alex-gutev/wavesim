import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../constants/theme.dart';

/// Represents the type of input field
enum FieldType {
  /// General text input field
  text(InputType.text),

  /// Password input field
  ///
  /// The contents of this type of field are obscured.
  password(InputType.password),

  /// Text field allowing multiple lines of input
  multiline(InputType.text),

  /// Field for selecting a date
  date(InputType.date),

  /// Field for selecting a date and a time
  datetime(InputType.dateTimeLocal),

  /// Field for entering an email
  email(InputType.email),

  /// Field for entering a year and month
  month(InputType.month),

  /// Field for entering a number
  number(InputType.number),

  /// Search text field
  search(InputType.search),

  /// Field for entering a telephone number
  telephone(InputType.tel),

  /// Field for entering a time (hour and minute)
  time(InputType.time),

  /// Field for entering a URL
  url(InputType.url),

  /// Field for entering a week
  week(InputType.week);

  /// HTML input type
  final InputType inputType;

  const FieldType(this.inputType);
}

/// Signature of the [Field] validation message callback.
typedef ValidationCallback = String Function(BuildContext context);

/// A text input field component.
class Field extends CellComponent {
  /// Cell holding the value entered in the field.
  ///
  /// The value of this cell is updated when the value of the field is changed
  /// by the user. Similarly, changing the value of this cell changes the
  /// value in the field.
  final MutableCell<String> value;

  /// Should the field be enabled for input?
  final bool enabled;

  /// The type of field
  final FieldType type;

  /// The text shown in the label associated with the field
  final String? title;

  /// Is this a required field?
  ///
  /// If true a required field marker is shown next to the [title] (provided
  /// it is not null). The required HTML attribute is set to true and an error
  /// message is shown if the field is left empty.
  final bool required;

  /// Validation message callback function.
  ///
  /// This function should return a message indicating invalid input or an
  /// empty string if the input is valid.
  ///
  /// This function is called in the context of a [CellComponent] thus may
  /// observe other cells including the [value] cell.
  final ValidationCallback? validate;

  /// Should validation error messages only be shown after the user navigates away from the field?
  ///
  /// If true, the validation error message is shown only after the user
  /// navigates away from the field for the first time, after which it is always
  /// shown.
  ///
  /// If false, validation error messages are shown as soon as invalid data is
  /// entered in the field
  final bool validateAfterEntry;

  /// Additional classes to add to the element
  final String? classes;

  /// Additional attributes to add to the input element
  final Map<String, String>? attributes;

  const Field({
    required this.value,
    this.title,
    this.type = FieldType.text,
    this.enabled = true,
    this.required = false,
    this.validate,
    this.validateAfterEntry = false,
    this.classes,
    this.attributes
  });

  String get _classes => classes != null
      ? 'field $classes'
      : 'field';

  String get _validationClass => validateAfterEntry
      ? ' user-validation'
      : ' immediate-validation';

  @override
  Component build(BuildContext context) {
    return label([
      div(classes: '$_classes$_validationClass', [
        if (title != null)
          span([
            text(title!),
            if (required)
              strong(classes: 'required-field-notice', [
                text(' *')
              ])
          ]),

        switch (type) {
          FieldType.multiline => _TextArea(
            value: value,
            enabled: enabled,
            required: required,
            attributes: attributes
          ),

          _ => _TextField(
              value: value,
              type: type.inputType,
              enabled: enabled,
              required: required,
              attributes: attributes,
          )
        },
        // TODO: Consider adding role=alert
        if (validate != null)
          span(
            classes: 'invalid-notice',
            attributes: {
              'aria-live': 'polite'
            },
            [
              text(validate!(context))
            ],
          )

        else if (required)
          span(
              classes: 'invalid-notice',
              attributes: {
                'aria-live': 'polite'
              },
              [
                text('Please fill in this field')
              ]
          ),
      ])
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.field', [
      css('&').styles(
          display: Display.flex,
          flexDirection: FlexDirection.column,
          alignItems: AlignItems.initial,
          gap: Gap.all(5.px)
      ),
      css('input', [
        css('&').styles(
            border: Border(
                style: BorderStyle.solid,
                width: 2.px,
                color: Theme.border
            ),
            radius: BorderRadius.all(Radius.circular(0.5.rem)),
            padding: Padding.all(0.5.rem),
            margin: Margin.all(0.px),

            width: 100.percent,
            boxSizing: BoxSizing.borderBox
        ),
        css('&:focus').styles(
          outline: Outline.unset,
          border: Border(
              style: BorderStyle.solid,
              width: 2.px,
              color: Theme.focus
          ),
        )
      ]),
      css('textarea', [
        css('&').styles(
            border: Border(
                style: BorderStyle.solid,
                width: 2.px,
                color: Theme.border
            ),
            radius: BorderRadius.all(Radius.circular(0.5.rem)),
            padding: Padding.all(0.5.rem),
            margin: Margin.all(0.px),

            width: 100.percent,
            boxSizing: BoxSizing.borderBox
        ),
        css('&:focus').styles(
          outline: Outline.unset,
          border: Border(
              style: BorderStyle.solid,
              width: 2.px,
              color: Theme.focus
          ),
        )
      ]),
    ]),

    css('.immediate-validation :is(input:invalid, textarea:invalid, select:invalid), '
        '.user-validation :is(input:user-invalid, textarea:user-invalid, select:user-invalid)').styles(
        border: Border(
            style: BorderStyle.solid,
            width: 2.px,
            color: Theme.error
        ),
        backgroundColor: Theme.errorContainer
    ),

    css('.invalid-notice').styles(
        display: Display.none,
        color: Theme.error,
        fontWeight: FontWeight.bold
    ),

    css('.immediate-validation :is(input:invalid, textarea:invalid, select:invalid, :has(input:invalid)) ~ .invalid-notice, '
        '.user-validation :is(input:user-invalid, textarea:user-invalid, select:user-invalid, :has(input:user-invalid)) ~ .invalid-notice').styles(
        display: Display.inline
    ),

    css('.field-container', [
      css('&').styles(
        position: Position.relative()
      ),
      css('& button').styles(
        position: Position.absolute(
            right: 10.px,
            top: 50.percent
        ),

        transform: Transform.translate(
          y: (-50).percent
        ),
        
        display: Display.inlineFlex,
        justifyContent: JustifyContent.center,
        alignContent: AlignContent.center,
        radius: BorderRadius.circular(50.percent),
        padding: Padding.all(0.2.em),
        fontSize: 1.2.em
      )
    ]),
    css('.vector-field').styles(
        display: Display.grid,
        gap: Gap(column: 10.px),
        gridTemplate: GridTemplate(
            columns: GridTracks([
              GridTrack.repeat(TrackRepeat(2), [
                GridTrack(TrackSize.fr(1))
              ])
            ])
        )
    ),

    css('.required-field-notice').styles(
        color: Colors.red
    )
  ];
}

/// A clear text field
class _TextField extends CellComponent {
  /// Cell holding the value entered in the field.
  final MutableCell<String> value;

  /// Should the field be enabled for input?
  final bool enabled;

  /// Is this field required?
  final bool required;

  /// HTML input type
  final InputType type;

  /// Additional attributes to add to the input element
  final Map<String, String>? attributes;

  const _TextField({
    required this.value,
    required this.enabled,
    required this.required,
    required this.type,
    required this.attributes,
  });

  @override
  Component build(BuildContext context) => input(
      type: type,
      value: value(),
      disabled: !enabled,
      onInput: (newValue) => value.value = newValue.toString(),

      attributes: {
        if (required)
          'required': '',

        ...?attributes
      },
  );
}

/// A multiline text field
class _TextArea extends CellComponent {
  /// Cell holding the value entered in the field.
  final MutableCell<String> value;

  /// Should the field be enabled for input?
  final bool enabled;

  /// Is this field required?
  final bool required;

  /// Additional attributes to add to the input element
  final Map<String, String>? attributes;

  const _TextArea({
    required this.value,
    required this.enabled,
    required this.required,
    required this.attributes,
  });

  @override
  Component build(BuildContext context) => textarea(
      disabled: !enabled,
      required: required,
      attributes: attributes,
      onInput: (newValue) => value.value = newValue,
      [
        text(value())
      ]
  );
}