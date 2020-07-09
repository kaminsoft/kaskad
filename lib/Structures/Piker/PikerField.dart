import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/linkItem.dart';
import 'package:mobile_kaskad/Structures/Piker/Piker.dart';

typedef OnPickerChanged = void Function(PikerController controller);

class PikerField extends StatefulWidget {
  PikerController controller;
  String placeholder;
  bool readOnly;
  bool isRequired;
  _PikerFieldState state;
  bool separated;
  OnPickerChanged onPickerChanged;

  PikerField(
      {Key key,
      @required this.controller,
      this.placeholder = "",
      this.readOnly = false,
      this.isRequired = false,
      this.onPickerChanged})
      : super(key: key);

  @override
  _PikerFieldState createState() {
    state = _PikerFieldState();
    return state;
  }

  bool validate() {
    return state.validate();
  }
}

class _PikerFieldState extends State<PikerField> {
  bool get hasOwner => widget.controller.owner != null;
  bool get ownerIsEmpty => widget.controller.owner.value.isEmpty;
  LinkItem get ownerValue => widget.controller.owner.value;
  LinkItem get value => widget.controller.value;
  set value(LinkItem newVal) => widget.controller.value = newVal;
  LinkItem _lastOwnerValue;
  bool valid = true;

  @override
  void initState() {
    if (hasOwner) {
      _lastOwnerValue = ownerValue;
      widget.controller.owner.addListener(() {
        if (_lastOwnerValue != ownerValue) {
          setState(() {
            widget.controller.value = LinkItem();
          });
          _lastOwnerValue = ownerValue;
        }
      });
    }
    super.initState();
  }

  bool validate() {
    if (!widget.isRequired) {
      return true;
    }
    if (value.isEmpty) {
      setState(() {
        valid = false;
      });
    }
    return value.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    double mult = MediaQuery.of(context).textScaleFactor;
    return InkWell(
      onTap: onTap(context),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  label(mult),
                  Text(value.toString(),
                      style: TextStyle(
                          fontSize: 14 * mult, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Visibility(
              visible: value.isNotEmpty && !widget.readOnly,
              child: Row(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      setState(() {
                        widget.controller.value = LinkItem();
                      });
                      if (widget.onPickerChanged != null) {
                        widget.onPickerChanged(widget.controller);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      child: Icon(
                        FontAwesomeIcons.times,
                        size: 15,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        value.open(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child: Icon(
                          FontAwesomeIcons.clone,
                          size: 15,
                          color: ColorMain,
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding label(double mult) {
    String text = widget.controller.label;
    TextStyle style = TextStyle(
        fontSize: 12 * mult, color: Theme.of(context).colorScheme.onSurface);
    if (!valid) {
      text = "$text - обязательно для заполнения";
      style = style.copyWith(color: Colors.redAccent);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        text,
        style: style,
      ),
    );
  }

  Function onTap(BuildContext context) {
    if (widget.readOnly) {
      return () {
        if (value.isNotEmpty) {
          value.open(context);
        }
      };
    }
    return () {
      if (hasOwner && ownerIsEmpty) {
        Scaffold.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Заполните поле ${widget.controller.owner.label}",
              style: TextStyle(color: Colors.white),
            )));
      } else {
        Picker.pickElement(context, widget.controller.type,
                owner: hasOwner ? ownerValue : null)
            .then((onValue) {
          if (onValue != null) {
            setState(() {
              valid = true;
              value = onValue;
            });
            if (widget.onPickerChanged != null) {
              widget.onPickerChanged(widget.controller);
            }
          }
        });
      }
    };
  }
}
