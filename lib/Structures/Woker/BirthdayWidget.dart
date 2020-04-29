import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Models/woker.dart';

class BirthdayWidget extends StatefulWidget {
  final List<Woker> workers;

  const BirthdayWidget({Key key, @required this.workers}) : super(key: key);
  @override
  _BirthdayWidgetState createState() => _BirthdayWidgetState();
}

class _BirthdayWidgetState extends State<BirthdayWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text('С днем рождения!'),
          ),
          body: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.workers.length,
                      itemBuilder: (BuildContext context, int index) {
                        Woker worker = widget.workers[index];
                        return ListTile(
                          title: Text(
                            worker.name,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .title
                                .copyWith(fontSize: 18),
                          ),
                          subtitle: Text(
                            worker.position,
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {},
                        );
                      },
                    ),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FlareActor(
                      "assets/img/etc/cakes.flr",
                      animation: 'Untitled',
                    ),
                  ))
                ],
              ),
              Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: double.infinity,
                      child: FlareActor(
                        "assets/img/etc/sparks2.flr",
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        animation: 'Animations',
                      ))),
            ],
          ),
        ),
        IgnorePointer(
          child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                  width: double.infinity,
                  child: FlareActor(
                    "assets/img/etc/sparks.flr",
                    alignment: Alignment.bottomCenter,
                    fit: BoxFit.cover,
                    animation: 'Animations',
                  ))),
        ),
      ],
    );
  }
}
