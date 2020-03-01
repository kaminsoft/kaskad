
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Consts.dart';

class InternetError extends StatelessWidget {
  const InternetError({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.error,
          color: ColorMain,
          size: 56,
        ),
        Text(
          'Не удалось соединиться с сервером\n Повторите попытку позднее',
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: OutlineButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: ColorMain,
            highlightColor: ColorMain,
            splashColor: ColorMain,
            child: Text("Назад"),
          ),
        )
      ],
    ));
  }
}