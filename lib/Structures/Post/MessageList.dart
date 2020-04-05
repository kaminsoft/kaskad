import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/message.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'Post.dart';

class MessageList extends StatefulWidget {
  final bool isPublicate;

  const MessageList({Key key, this.isPublicate = false}) : super(key: key);

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  bool _isLoading = false;
  bool _built = false;
  double _fabOpacity = 1;
  bool _fabVisibility = true;
  bool justNew = false;
  bool sent = false;
  RefreshController _refreshController = RefreshController(
      initialRefresh: false, initialLoadStatus: LoadStatus.loading);
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(() {
      
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward && _fabOpacity == 0) {
        setState(() {
          _fabOpacity = 1;
          _fabVisibility = true;
        });
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse  && _fabOpacity == 1) {
         setState(() {
          _fabOpacity = 0;
        });
      }
    });
    super.initState();
  }

  void _updateList() async {
    _isLoading = true;
    await StoreProvider.dispatchFuture(
        context, UpdateMessages(widget.isPublicate));
    _isLoading = false;
  }

  void _onRefresh() async {
    await StoreProvider.dispatchFuture(
        context, LoadMessages(widget.isPublicate));
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (BuildContext context, state) {
        var messages = widget.isPublicate ? state.messagesP : state.messages;

        if (messages.length == 0) {
          StoreProvider.dispatchFuture(
              context, LoadMessages(widget.isPublicate));
          return Scaffold(
            backgroundColor: ColorGray,
            body: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        } else if (!_built) {
          _built = true;
          StoreProvider.dispatchFuture(
              context, UpdateMessages(widget.isPublicate, addBefore: true));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.isPublicate ? 'Объявления' : 'Сообщения'),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                  onPressed: () =>
                      Post.newItem(context, isPublicate: widget.isPublicate),
                  icon: Icon(Icons.add))
            ],
          ),
          floatingActionButton: AnimatedOpacity(
            duration: Duration(milliseconds: 250),
            opacity: _fabOpacity,
            onEnd: (){
              if (_fabOpacity == 0) {
                setState(() {
                  _fabVisibility = false;
                });
              }
            },
            child: Visibility(
              visible: _fabVisibility,
              child: FloatingActionButton(
                  onPressed: () {},
                  child: Icon(
                    FontAwesomeIcons.filter,
                    size: 18,
                  )),
            ),
          ),
          body: Scrollbar(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!_isLoading &&
                    scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200 &&
                    scrollInfo.metrics.pixels <=
                        scrollInfo.metrics.maxScrollExtent) {
                  _updateList();
                  return true;
                }
                //print(scrollInfo.metrics.maxScrollExtent);
                return false;
              },
              child: SmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefresh,
                header: ClassicHeader(
                  completeText: 'Готово',
                  failedText: 'Ошибка обновления',
                  idleText: 'Потяните для обновления',
                  refreshingText: 'Обновление',
                  releaseText: 'Отпустите для обновления',
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    Message msg = messages[index];
                    if (index == 0 ||
                        messages[index].getSeparatorText() !=
                            messages[index - 1].getSeparatorText()) {
                      return Column(
                        children: <Widget>[
                          Text(messages[index].getSeparatorText()),
                          itemCard(context, msg)
                        ],
                      );
                    } else {
                      return itemCard(context, msg);
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget itemCard(BuildContext context, Message msg) {
  return Card(
      elevation: msg.isRead() ? 0 : 3,
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () async {
          Post.openItem(context, msg.guid);
        },
        onLongPress: () {
          Post.showContextMenu(context, msg);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: itemBody(context, msg),
        ),
      ));
}

Widget itemBody(BuildContext context, Message msg) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      child: Text(msg.getAvatarLetter()),
    ),
    title: Text(
      msg.getTittle(),
      style: TextStyle(
          fontWeight: msg.isRead() ? FontWeight.normal : FontWeight.w800),
    ),
    subtitle: Text(msg.from.name),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(msg.getDate()),
      ],
    ),
  );
}
