import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/message.dart';
import 'package:mobile_kaskad/Models/woker.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';
import 'package:mobile_kaskad/Structures/Post/Post.dart';
import 'package:mobile_kaskad/Structures/Woker/Woker.dart';

class ItemWidget extends StatefulWidget {
  final String id;
  ItemWidget({Key key, @required this.id}) : super(key: key);

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  Message msg;
  int initIndex;
  List<Message> messages;
  bool isPublicite = false;
  Map<String, Widget> cacheWidgets = Map<String, Widget>();

  loadMessage(String guid) async {
    if (!cacheWidgets.containsKey(guid)) {
      msg = await Connection.getMessage(guid);
      if (!msg.isRead()) {
        StoreProvider.dispatchFuture(context, SetMessageRead(msg));
      }
      setState(() {
        cacheWidgets.addAll({guid: msgBody(context, msg)});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (BuildContext context, state) {
          initIndex = state.messages.indexWhere((e) => e.guid == widget.id);
          messages = state.messages;
          if (initIndex == -1) {
            initIndex = state.messagesP.indexWhere((e) => e.guid == widget.id);
            messages = state.messagesP;
            isPublicite = true;
          }
          if (initIndex == -1) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Ошибка',
                ),
                centerTitle: true,
              ),
              body: Center(
                child: Text(
                  'Не удалось получить информацию о сообщении',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            );
          }

          loadMessage(widget.id);

          PageController controller = PageController(initialPage: initIndex);
          return Scaffold(
            appBar: AppBar(
              title: Text(
                isPublicite ? 'Объявление' : 'Cообщение',
              ),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      Post.showContextMenu(context, msg);
                    })
              ],
            ),
            body: PageView.builder(
                controller: controller,
                itemCount: messages.length,
                onPageChanged: (index) {
                  loadMessage(messages[index].guid);
                  if (index == messages.length-1) {
                    StoreProvider.dispatch(context, UpdateMessages(isPublicite));
                  }
                },
                itemBuilder: (ctx, index) {
                  if (cacheWidgets.containsKey(messages[index].guid)) {
                    return cacheWidgets[messages[index].guid];
                  }
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                }),
          );
        });
  }

  Widget msgBody(BuildContext context, Message inMsg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ListView(
        children: <Widget>[
          Text(DateFormat("dd.MM.yyyy HH:mm:ss").format(inMsg.date)),
          Divider(),
          SelectableText(
            inMsg.title,
            style: TextStyle(fontSize: 16),
          ),
          Row(
            children: <Widget>[
              Text(
                "От: ",
                style: TextStyle(fontSize: 14),
              ),
              GestureDetector(
                onTap: () => Wkr.openItemById(context, inMsg.from.guid),
                child: Chip(
                  label: Text(inMsg.from.name),
                  avatar: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    child: Text(
                      inMsg.getAvatarLetter(),
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              )
            ],
          ),
          inMsg.to.length > 1
              ? GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (ctx) {
                          return Container(
                            decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
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
                                      itemCount: inMsg.to.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                          onTap: () => Wkr.openItemById(context, inMsg.to[index].guid),
                                          title: Text(inMsg.to[index].name),
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
                        label: Text(inMsg.to.length.toString()),
                        avatar: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.onSurface,
                          child: Icon(
                            Icons.people,
                            size: 12,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : inMsg.to.first != inMsg.from
                  ? Row(
                      children: <Widget>[
                        Text(
                          "Кому: ",
                          style: TextStyle(fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: (){
                            Wkr.openItemById(context, inMsg.to.first.guid);
                          },
                          child: Chip(
                            label: Text(inMsg.to.first.name),
                            avatar: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.onSurface,
                              child: Text(
                                getAvatarLetter(inMsg.to.first.name),
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(),
          Divider(),
          SelectableText(
            inMsg.text,
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
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
