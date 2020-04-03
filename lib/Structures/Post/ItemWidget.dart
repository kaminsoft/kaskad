import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/message.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Structures/Post/Post.dart';

class ItemWidget extends StatefulWidget {
  final String id;
  ItemWidget({Key key, @required this.id}) : super(key: key);

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Connection.getMessage(widget.id),
        builder: (BuildContext context, AsyncSnapshot<Message> snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(body: Center(child: CupertinoActivityIndicator()));
          }
          var msg = snapshot.data;
          if (msg.number == null) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Ошибка',
                ),
                centerTitle: true,
                brightness: Brightness.light,
              ),
              body: Center(
                child: Text(
                  'Не удалось получить информацию о сообщении',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            );
          }
          if (!msg.isRead()) {
            StoreProvider.dispatchFuture(context, SetMessageRead(msg));
          }

          return Scaffold(
              appBar: AppBar(
                title: Text(
                  msg.isPublicite ? 'Объявление' : 'Cообщение',
                ),
                centerTitle: true,
                brightness: Brightness.light,
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {
                        Post.showContextMenu(context, msg);
                      })
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ListView(
                  children: <Widget>[
                    Text(DateFormat("dd.MM.yyyy HH:mm:ss").format(msg.date)),
                    Divider(),
                    SelectableText(
                      msg.title,
                      style: TextStyle(fontSize: 16),
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          "От: ",
                          style: TextStyle(fontSize: 14),
                        ),
                        Chip(
                          label: Text(msg.from.name),
                          avatar: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.onSurface,
                            child: Text(
                              msg.getAvatarLetter(),
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        )
                      ],
                    ),
                    msg.to.length > 1
                        ? GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (ctx) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20))),
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text(
                                              "Получатели",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                          Expanded(
                                            child: Scrollbar(
                                              child: ListView.builder(
                                                itemCount: msg.to.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return ListTile(
                                                    title: Text(
                                                        msg.to[index].name),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Кому: ",
                                  style: TextStyle(fontSize: 14),
                                ),
                                Chip(
                                  label: Text(msg.to.length.toString()),
                                  avatar: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                                    child: Icon(
                                      Icons.people,
                                      size: 12,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container(),

                    Divider(),
                    // SizedBox(
                    //   height: 24,
                    //   child: ListView.builder(
                    //     scrollDirection: Axis.horizontal,
                    //     itemCount: msg.to.length,
                    //     itemBuilder: (BuildContext context, int index) {
                    //       return UserChip(text: msg.to[index].name);
                    //     },
                    //   ),
                    // ),
                    SelectableText(
                      msg.text,
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ));
        });
  }
}

class UserChip extends StatelessWidget {
  const UserChip({
    Key key,
    @required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 2),
      decoration: BoxDecoration(
          color: Colors.black12, borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
