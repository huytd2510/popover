import 'package:flutter/rendering.dart';
import 'package:flutter_screen_scaling/flutter_screen_scaling.dart';

import 'popover_direction.dart';
import 'popover_path.dart';
import 'utils/popover_utils.dart';

class PopoverRenderShiftedBox extends RenderShiftedBox {
  double? arrowWidth;
  double? arrowHeight;
  PopoverDirection? _direction;
  Rect? _attachRect;
  Color? _color;
  List<BoxShadow>? _boxShadow;
  double? _scale;
  double? _radius;

  PopoverRenderShiftedBox({
    this.arrowWidth,
    this.arrowHeight,
    RenderBox? child,
    Rect? attachRect,
    Color? color,
    List<BoxShadow>? boxShadow,
    double? scale,
    double? radius,
    PopoverDirection? direction,
  }) : super(child) {
    _attachRect = attachRect;
    _color = color;
    _boxShadow = boxShadow;
    _scale = scale;
    _radius = radius;
    _direction = direction;
  }

  Rect? get attachRect => _attachRect;
  set attachRect(Rect? value) {
    if (_attachRect == value) return;
    _attachRect = value;
    markNeedsLayout();
  }

  List<BoxShadow>? get boxShadow => _boxShadow;
  set boxShadow(List<BoxShadow>? value) {
    if (_boxShadow == value) return;
    _boxShadow = value;
    markNeedsLayout();
  }

  Color? get color => _color;
  set color(Color? value) {
    if (_color == value) return;
    _color = value;
    markNeedsLayout();
  }

  PopoverDirection? get direction => _direction;
  set direction(PopoverDirection? value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  double? get radius => _radius;
  set radius(double? value) {
    if (_radius == value) return;
    _radius = value;
    markNeedsLayout();
  }

  double? get scale => _scale;
  set scale(double? value) {
    _scale = value;
    markNeedsLayout();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final transform = Matrix4.identity();
    final childParentData = child!.parentData as BoxParentData;
    final _direction = PopoverUtils.popoverDirection(
      attachRect,
      size,
      direction,
      arrowHeight,
    );

    Rect? arrowRect;
    late Offset translation;
    Rect bodyRect;

    bodyRect = childParentData.offset & child!.size;

    final arrowLeft =
        attachRect!.left;

    final arrowTop =
        attachRect!.top;

    switch (_direction) {
      case PopoverDirection.top:
        arrowRect = Rect.fromLTRB(arrowLeft, child!.size.height, ScreenScale.convertWidth(145), arrowHeight!);

        translation = Offset(arrowLeft + arrowWidth! / 2, size.height);
        break;
      case PopoverDirection.bottom:
        arrowRect = Rect.fromLTRB(arrowLeft, 0, ScreenScale.convertWidth(145), arrowHeight!);
        translation = Offset(arrowLeft, 0);
        break;
      case PopoverDirection.left:
        arrowRect = Rect.fromLTWH(
          child!.size.width,
          arrowTop,
          arrowHeight!,
          arrowWidth!,
        );

        translation = Offset(size.width, arrowTop + arrowWidth! / 2);
        break;
      case PopoverDirection.right:
        arrowRect = Rect.fromLTWH(0, arrowTop, arrowHeight!, arrowWidth!);
        translation = Offset(0, arrowTop + arrowWidth! / 2);
        break;
      default:
    }

    _pushClipPath(
      context,
      offset,
      PopoverPath(radius!).draw(_direction, arrowRect, bodyRect),
      transform,
    );
  }

  void _transform(Matrix4 transform, Offset translation) {
    transform.translate(translation.dx, translation.dy);
    transform.scale(scale, scale, 1);
    transform.translate(-translation.dx, -translation.dy);
  }

  void _pushClipPath(
    PaintingContext context,
    Offset offset,
    Path path,
    Matrix4 transform,
  ) {
    super.paint(context, offset);
  }

  @override
  void performLayout() {
    assert(constraints.maxHeight.isFinite);

    _configureChildConstrains();
    _configureChildSize();
    _configureChildOffset();
  }

  void _configureChildConstrains() {
    BoxConstraints childConstraints;

    if (direction == PopoverDirection.top ||
        direction == PopoverDirection.bottom) {
      childConstraints = BoxConstraints(
        maxHeight: constraints.maxHeight - arrowHeight!,
      ).enforce(constraints);
    } else {
      childConstraints = BoxConstraints(
        maxWidth: constraints.maxWidth - arrowHeight!,
      ).enforce(constraints);
    }

    child!.layout(childConstraints, parentUsesSize: true);
  }

  void _configureChildSize() {
    if (direction == PopoverDirection.top ||
        direction == PopoverDirection.bottom) {
      size = Size(child!.size.width, child!.size.height + arrowHeight!);
    } else {
      size = Size(child!.size.width + arrowHeight!, child!.size.height);
    }
  }

  void _configureChildOffset() {
    final _direction = PopoverUtils.popoverDirection(
      attachRect,
      size,
      direction,
      arrowHeight,
    );

    final childParentData = child!.parentData as BoxParentData?;
    if (_direction == PopoverDirection.bottom) {
      childParentData!.offset = Offset(0, arrowHeight!);
    } else if (_direction == PopoverDirection.right) {
      childParentData!.offset = Offset(arrowHeight!, 0);
    }
  }
}
