import 'dart:io';

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

typedef FilterChanged = void Function(bool sent, bool justNew);
typedef ReadAll = void Function();

class MessageFilter extends StatefulWidget {
  final bool sent;
  final bool justNew;
  final bool hasNewMessages;
  final FilterChanged onFilterChanged;
  final ReadAll onReadAll;

  const MessageFilter(
      {Key key,
      @required this.sent,
      @required this.justNew,
      @required this.onFilterChanged,
      @required this.onReadAll,
      this.hasNewMessages = false})
      : super(key: key);
  @override
  _MessageFilterState createState() =>
      _MessageFilterState(sent: sent ? 1 : 0, justNew: justNew ? 1 : 0);
}

class _MessageFilterState extends State<MessageFilter> {
  int sent;
  int justNew;

  _MessageFilterState({this.sent, this.justNew});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 5),
          child: Text(
            "Настройки",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Visibility(
          visible: sent != 1,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8,
              left: 8,
              right: 8,
            ),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl(
                groupValue: justNew,
                onValueChanged: (val) {
                  setState(() {
                    justNew = val;
                  });
                },
                children: {
                  0: Text("все"),
                  1: Text("новые"),
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 10),
          child: SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl(
              groupValue: sent,
              onValueChanged: (val) {
                setState(() {
                  sent = val;
                  if (val == 1) {
                    justNew = 0;
                  }
                });
              },
              children: {
                0: Text("входящие"),
                1: Text("исходящие"),
              },
            ),
          ),
        ),
        SafeArea(
          child: Row(
            children: <Widget>[
              Visibility(
                visible: widget.hasNewMessages,
                child: Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 8, right: 4, bottom: 8, left: 8),
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      onPressed: () {
                        if (Platform.isAndroid) {
                          showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  content: Text("Прочитать все сообщения?"),
                                  actions: <Widget>[
                                    FlatButton(
                                        onPressed: () => widget.onReadAll(),
                                        child: Text("Да")),
                                    FlatButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text("Нет")),
                                  ],
                                );
                              });
                        } else {
                          showCupertinoDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  content: Text("Прочитать все сообщения?"),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                        onPressed: () => widget.onReadAll(),
                                        child: Text("Да")),
                                    CupertinoDialogAction(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text("Нет"))
                                  ],
                                );
                              });
                        }
                      },
                      color: ColorMain,
                      child: Text("Прочитать все"),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: widget.hasNewMessages
                      ? const EdgeInsets.only(
                          top: 8, right: 8, bottom: 8, left: 4)
                      : EdgeInsets.all(8),
                  child: CupertinoButton(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    onPressed: () {
                      widget.onFilterChanged(sent == 1 ? true : false,
                          justNew == 1 ? true : false);
                    },
                    color: ColorMain,
                    child: Text("Готово"),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class MessageList extends StatefulWidget {
  final bool isPublicate;

  const MessageList({Key key, this.isPublicate = false}) : super(key: key);

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _built = false;
  double _fabOpacity = 1;
  bool _fabVisibility = true;
  bool justNew = false;
  bool sent = false;
  bool hasNewMessages = false;

  RefreshController _refreshController = RefreshController(
      initialRefresh: false, initialLoadStatus: LoadStatus.loading);
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
              ScrollDirection.forward &&
          _fabOpacity == 0) {
        setState(() {
          _fabOpacity = 1;
          _fabVisibility = true;
        });
      } else if (_scrollController.position.userScrollDirection ==
              ScrollDirection.reverse &&
          _fabOpacity == 1) {
        setState(() {
          _fabOpacity = 0;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    if (sent || justNew) {
      StoreProvider.dispatchFuture(
          mainWidgetKey.currentContext, ClearMessages(widget.isPublicate));
    }
    super.dispose();
  }

  void _updateList() async {
    _isLoading = true;
    await StoreProvider.dispatchFuture(context,
        UpdateMessages(widget.isPublicate, sent: sent, justNew: justNew));
    _isLoading = false;
  }

  void _onRefresh() async {
    await StoreProvider.dispatchFuture(context,
        LoadMessages(widget.isPublicate, sent: sent, justNew: justNew));
    await StoreProvider.dispatchFuture(context, UpdateMessageCount());
    _refreshController.refreshCompleted();
  }

  void _openFilter(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (ctx) {
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return SingleChildScrollView(
                child: MessageFilter(
                    sent: sent,
                    justNew: justNew,
                    hasNewMessages: hasNewMessages,
                    onReadAll: () {
                      StoreProvider.dispatchFuture(
                          context, SetReadAll(widget.isPublicate));
                      Navigator.of(context).pop();
                    },
                    onFilterChanged: (_sent, _justNew) async {
                      setState(() {
                        sent = _sent;
                        justNew = _justNew;
                        _isUpdating = true;
                      });
                      Navigator.of(context).pop();
                      await StoreProvider.dispatchFuture(
                          context,
                          LoadMessages(widget.isPublicate,
                              sent: sent, justNew: justNew));
                      setState(() {
                        _isUpdating = false;
                      });
                    }),
              );
            }),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (BuildContext context, state) {
        var messages = widget.isPublicate ? state.messagesP : state.messages;
        hasNewMessages =
            widget.isPublicate ? state.postCount > 0 : state.msgCount > 0;
        if (!_built) {
          _built = true;
          if (messages.length == 0) {
            StoreProvider.dispatchFuture(context,
                LoadMessages(widget.isPublicate, sent: sent, justNew: justNew));
            return Scaffold(
              body: Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          } else {
            StoreProvider.dispatchFuture(
                context,
                UpdateMessages(widget.isPublicate,
                    addBefore: true, sent: sent, justNew: justNew));
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: <Widget>[
                Text(
                  widget.isPublicate ? 'Объявления' : 'Сообщения',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                Text(
                  sent ? 'исходящие' : 'входящие',
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(fontSize: 12),
                ),
              ],
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                  onPressed: () =>
                      Post.newItem(context, isPublicate: widget.isPublicate),
                  icon: Icon(Icons.add))
            ],
          ),
          floatingActionButton: fab(context),
          body: messages.length == 0
              ? Center(
                  child: justNew
                      ? Text("Нет новых сообщений")
                      : Text("Нет данных для отображения"),
                )
              : _isUpdating
                  ? Scaffold(
                      body: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    )
                  : Scrollbar(
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

  Widget fab(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 250),
      opacity: _fabOpacity,
      onEnd: () {
        if (_fabOpacity == 0) {
          setState(() {
            _fabVisibility = false;
          });
        }
      },
      child: Visibility(
        visible: _fabVisibility,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
                heroTag: "filter",
                onPressed: () => _openFilter(context),
                child: Icon(
                  FontAwesomeIcons.filter,
                  size: 18,
                )),
          ],
        ),
      ),
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
  return ListTileTheme(
    selectedColor: Theme.of(context).colorScheme.onSurface,
    child: ListTile(
      selected: !msg.isRead(),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        child: msg.toCount > 0
            ? Icon(Icons.mail_outline)
            : Text(msg.getAvatarLetter()),
      ),
      title: Text(
        msg.getTittle(),
        style: TextStyle(
            fontWeight: msg.isRead() ? FontWeight.normal : FontWeight.w800),
      ),
      subtitle: msg.toCount > 0
          ? Text("Получателей: ${msg.toCount}")
          : Text(msg.from.name),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(msg.getDate()),
        ],
      ),
    ),
  );
}
