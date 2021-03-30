import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:riderapp/components/constants.dart';
import 'input_helper.dart';

typedef void CaretMoved(Offset globalCaretPosition);
typedef void TextChanged(String text);

// Helper widget to track caret position.
class TrackingTextInput extends StatefulWidget {
  TrackingTextInput(
      {Key key,
      this.onCaretMoved,
      this.onTextChanged,
      this.hint,
      this.label,
      this.colour,
      this.isObscured = false})
      : super(key: key);
  final CaretMoved onCaretMoved;
  final TextChanged onTextChanged;
  final String hint;
  final String label;
  final bool isObscured;
  final Color colour;
  @override
  _TrackingTextInputState createState() => _TrackingTextInputState();
}

class _TrackingTextInputState extends State<TrackingTextInput> {
  final GlobalKey _fieldKey = GlobalKey();
  final TextEditingController _textController = TextEditingController();
  Timer _debounceTimer;
  @override
  initState() {
    _textController.addListener(() {
      // We debounce the listener as sometimes the caret position is updated after the listener
      // this assures us we get an accurate caret position.
      if (_debounceTimer?.isActive ?? false) _debounceTimer.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 100), () {
        if (_fieldKey.currentContext != null) {
          // Find the render editable in the field.
          final RenderObject fieldBox =
              _fieldKey.currentContext.findRenderObject();
          Offset caretPosition = getCaretPosition(fieldBox);

          if (widget.onCaretMoved != null) {
            widget.onCaretMoved(caretPosition);
          }
        }
      });
      if (widget.onTextChanged != null) {
        widget.onTextChanged(_textController.text);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: TextFormField(
        decoration: InputDecoration(
          //fillColor: Colors.white,
           /* border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(30.0),

            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                color: Colors.white,

              ),
            ),
           */
           border: InputBorder.none,
            hintText: widget.hint,
            labelText: widget.label,
            labelStyle: TextStyle(
              color: Colors.white30,
              fontSize: 20.0,
            )),
        key: _fieldKey,
        controller: _textController,
        obscureText: widget.isObscured,
        //validator: (value) {}
      ),
    );
  }
}
