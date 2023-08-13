import 'package:comanager/backend.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerHomePage extends StatefulWidget {
  const WorkerHomePage({super.key});

  @override
  State<WorkerHomePage> createState() => _WorkerHomePageState();
}

class _WorkerHomePageState extends State<WorkerHomePage> {
  final TextEditingController _rejectController = TextEditingController();
  late SharedPreferences prefs;
  final Backend _backend = Backend();
  var tasks;
  var me;

  @override
  void initState() {
    super.initState();
    _initPage().then((value) {
      setState(() {});
    });
  }

  Future<void> _initPage() async {
    prefs = await SharedPreferences.getInstance();
    tasks = await _backend.tasks(prefs.getString("token")!);
    if (tasks.runtimeType == String) {
      _backend.logout(prefs.getString("token")!).then((value) {
        prefs.remove("token");
        prefs.remove("role");
        Navigator.pushReplacementNamed(context, "/signin");
      });
    }

    me = await _backend.me(prefs.getString("token")!);
    if (me.runtimeType == String) {
      _backend.logout(prefs.getString("token")!).then((value) {
        prefs.remove("token");
        prefs.remove("role");
        Navigator.pushReplacementNamed(context, "/signin");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(me != null ? me['data']['attributes']['name'] : ""),
        actions: [
          IconButton(
            onPressed: () {
              _initPage().then((value) {
                setState(() {});
              });
            },
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              print("pressed");
              _backend.logout(prefs.getString("token")!).then((value) {
                if (_backend.statusCode == 200) {
                  prefs.remove("token");
                  prefs.remove("role");
                  Navigator.pushReplacementNamed(context, "/signin");
                }
              });
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: tasks != null
          ? tasks['data'].isEmpty
              ? Center(
                  child: Text("No tasks"),
                )
              : ListView.builder(
                  itemCount: tasks['data'].length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          tasks['data'][index]['attributes']['title'],
                          textAlign: TextAlign.center,
                        ),
                        subtitle: Text(
                          tasks['data'][index]['attributes']['description'],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        trailing: tasks['data'][index]['attributes']
                                    ['status'] ==
                                "pending"
                            ? Wrap(
                                spacing: -13,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              return AlertDialog(
                                                scrollable: true,
                                                title: const Text(
                                                    'Rejection Reason'),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    TextFormField(
                                                      controller:
                                                          _rejectController,
                                                      keyboardType:
                                                          TextInputType
                                                              .emailAddress,
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide.none,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        fillColor:
                                                            Colors.grey[300],
                                                        filled: true,
                                                      ),
                                                      maxLines: 10,
                                                      onChanged: (value) {
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: _rejectController
                                                                .text !=
                                                            ""
                                                        ? () {
                                                            _backend
                                                                .rejectTask(
                                                                    prefs.getString(
                                                                        "token")!,
                                                                    tasks['data']
                                                                            [
                                                                            index]
                                                                        ["id"],
                                                                    _rejectController
                                                                        .text)
                                                                .then((value) {
                                                              print(_backend
                                                                  .statusCode);
                                                              print(value);
                                                              if (_backend
                                                                      .statusCode ==
                                                                  200) {
                                                                _rejectController
                                                                    .text = "";
                                                                _initPage().then(
                                                                    (value) {
                                                                  super.setState(
                                                                      () {});
                                                                });
                                                              } else {}
                                                            });
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }
                                                        : null,
                                                    child: const Text('Ok'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _backend
                                          .acceptTask(prefs.getString("token")!,
                                              tasks['data'][index]["id"])
                                          .then((value) {
                                        if (_backend.statusCode == 200) {
                                          _initPage().then((value) {
                                            setState(() {});
                                          });
                                        } else {}
                                      });
                                    },
                                    icon: Icon(
                                      Icons.check,
                                    ),
                                  ),
                                ],
                              )
                            : tasks['data'][index]['attributes']['status'] ==
                                    "doing"
                                ? TextButton(
                                    style: TextButton.styleFrom(
                                      alignment: AlignmentDirectional.centerEnd,
                                    ),
                                    onPressed: () {
                                      _backend
                                          .finishTask(prefs.getString("token")!,
                                              tasks['data'][index]["id"])
                                          .then((value) {
                                        if (_backend.statusCode == 200) {
                                          _initPage().then((value) {
                                            setState(() {});
                                          });
                                        } else {}
                                      });
                                    },
                                    child: Text(
                                      "finish",
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  )
                                : tasks['data'][index]['attributes']
                                            ['status'] ==
                                        "finished"
                                    ? Text(
                                        "finished",
                                        style: TextStyle(color: Colors.green),
                                      )
                                    : Text(
                                        "rejected",
                                        style: TextStyle(color: Colors.red),
                                      ),
                      ),
                    );
                  },
                )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
