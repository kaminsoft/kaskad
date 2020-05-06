import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Models/woker.dart';
import 'package:mobile_kaskad/Structures/Woker/Woker.dart';

import '../../Data/Connection.dart';

import '../../Data/Consts.dart';

import '../../Data/Database.dart';

class ListWidget extends StatefulWidget {
  @override
  _ListWidgetState createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  List<Woker> list;
  List<Woker> searchList;
  bool searchMode = false;
  List<Woker> birthdayWorkers = List<Woker>();
  FocusNode focusNode = FocusNode();
  TextEditingController filter = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void updateBirtdays(List<Woker> workers) async {
    await DBProvider.db.saveWorkers(list);
    var blist = await WorkerHelper.getBirthdayWorkers(allWorkers: list);
    setState((){
      birthdayWorkers = blist;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (list == null) {
      DBProvider.db.getWorkers().then((wokers) {
        setState(() {
          list = wokers;
          searchList = wokers;
        });
        Connection.getWorkers().then((wokers) {
          if (wokers.isNotEmpty) {
            setState(() {
              list = wokers;
              searchList = wokers;
            });
            updateBirtdays(list);
          }
        });
      });
    }

    return Scaffold(
      appBar: searchMode
          ? AppBar(
              automaticallyImplyLeading: false,
              title: TextField(
                controller: filter,
                focusNode: focusNode,
                style: Theme.of(context).textTheme.title,
                textInputAction: TextInputAction.unspecified,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Поиск',
                  hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                ),
                onChanged: (text) {
                  if (filter.text.isEmpty) {
                    setState(() {
                      searchList = list;
                    });
                  } else {
                    setState(() {
                      searchList = list
                          .where((e) =>
                              e.name
                                  .toLowerCase()
                                  .startsWith(filter.text.toLowerCase()) ||
                              e.position
                                  .toLowerCase()
                                  .startsWith(filter.text.toLowerCase()) ||
                              e.subdivision
                                  .toLowerCase()
                                  .startsWith(filter.text.toLowerCase()))
                          .toList();
                    });
                  }
                },
              ),
              leading: IconButton(
                  icon: Icon(Platform.isAndroid
                      ? Icons.arrow_back
                      : Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      searchMode = false;
                    });
                  }),
              actions: <Widget>[
                Visibility(
                  visible: filter.text.isNotEmpty,
                  child: IconButton(
                      icon: Icon(CupertinoIcons.clear),
                      onPressed: () {
                        setState(() {
                          filter.text = '';
                          searchList = list;
                        });
                      }),
                ),
              ],
            )
          : AppBar(
              title: Text('Сотрудники'),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        searchMode = true;
                      });
                      Timer(Duration(milliseconds: 100), () {
                        FocusScope.of(context).requestFocus(focusNode);
                      });
                    })
              ],
            ),
      floatingActionButton: Visibility(
          visible: birthdayWorkers.length > 0,
          child: FloatingActionButton(
            onPressed: () => WorkerHelper.openBirthdayWidget(context, workers: birthdayWorkers),
            backgroundColor: ColorMain,
            child: Icon(Icons.cake),
          )),
      body: Builder(builder: (context) {
        List workList = searchMode ? searchList : list;
        if (workList == null) {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        }
        if (workList.length == 0) {
          return Center(
            child: Text(
              'Нет данных для отображения',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.body1,
            ),
          );
        }
        return Scrollbar(
          child: ListView.builder(
            itemCount: workList.length,
            itemBuilder: (BuildContext context, int index) {
              Woker woker = workList[index];
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                      child: Text(getAvatarLetter(woker.name)),
                    ),
                    title: Text(woker.shortName),
                    subtitle: Text("${woker.subdivision}\n${woker.position}"),
                    trailing: Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () => WorkerHelper.openItem(context, woker),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
