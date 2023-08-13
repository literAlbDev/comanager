import 'package:comanager/backend.dart';
import 'package:comanager/pages/signin.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Shared {
  static bool finishedLoadingWorkers = false;
  static bool finishedLoadingTasks = false;
  static var me;
  static var workers;
  static var tasks;
}

class ManagerHomePage extends StatefulWidget {
  const ManagerHomePage({super.key});

  @override
  State<ManagerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<ManagerHomePage> {
  late SharedPreferences prefs;
  final Backend _backend = Backend();

  @override
  void initState() {
    super.initState();
    _initPage().then((value) {
      setState(() {
        Shared.finishedLoadingWorkers = true;
        Shared.finishedLoadingTasks = true;
      });
    });
  }

  Future<void> _initPage() async {
    prefs = await SharedPreferences.getInstance();
    Shared.me = await _backend.me(prefs.getString("token")!);
    if (Shared.me.runtimeType == String) {
      _backend.logout(prefs.getString("token")!).then((value) {
        prefs.remove("token");
        prefs.remove("role");
        Navigator.pushReplacementNamed(context, "/signin");
      });
    }

    Shared.tasks = await _backend.tasks(prefs.getString("token")!);
    if (Shared.tasks.runtimeType == String) {
      _backend.logout(prefs.getString("token")!).then((value) {
        prefs.remove("token");
        prefs.remove("role");
        Navigator.pushReplacementNamed(context, "/signin");
      });
    }

    Shared.workers = Shared.me['data']['attributes']['workers'];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Shared.me != null ? Shared.me['data']['attributes']['name'] : ""),
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
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: EdgeInsets.all(0),
            overlayColor: MaterialStateProperty.resolveWith(
                (states) => Colors.transparent),
            tabs: [
              Tab(
                text: "Workers",
              ),
              Tab(text: "Tasks"),
            ],
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: TabBarView(
          children: [
            WorkersTab(_initPage),
            TasksTab(_initPage),
          ],
        ),
      ),
    );
  }
}

class WorkersTab extends StatefulWidget {
  var _initPage;

  WorkersTab(this._initPage);

  @override
  State<WorkersTab> createState() => _WorkersTabState();
}

class _WorkersTabState extends State<WorkersTab> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _rpasswordController = TextEditingController();
  bool _passwordHidden = true;
  bool _rpasswordHidden = true;
  late SharedPreferences prefs;
  final Backend _backend = Backend();
  bool loading = false;
  String error = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {

    print(Shared.workers);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Add worker'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            fillColor: Colors.grey[300],
                            filled: true,
                            hintText: "Full Name",
                            hintStyle: const TextStyle(fontSize: 13),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            fillColor: Colors.grey[300],
                            filled: true,
                            hintText: "Email",
                            hintStyle: const TextStyle(fontSize: 13),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _passwordHidden,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            fillColor: Colors.grey[300],
                            filled: true,
                            hintText: "Password",
                            hintStyle: const TextStyle(fontSize: 13),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _passwordHidden = !_passwordHidden;
                                });
                              },
                              icon: Icon(
                                _passwordHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _rpasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _rpasswordHidden,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            fillColor: Colors.grey[300],
                            filled: true,
                            hintText: "Re-Password",
                            hintStyle: const TextStyle(fontSize: 13),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _rpasswordHidden = !_rpasswordHidden;
                                });
                              },
                              icon: Icon(
                                _rpasswordHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          error,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('cancel'),
                      ),
                      TextButton(
                        onPressed: loading
                            ? null
                            : () async {
                                setState(() {
                                  loading = true;
                                  error = '';
                                });

                                if (_passwordController.text !=
                                    _rpasswordController.text) {
                                  setState(() {
                                    error =
                                        "the 2 password fields did not match";
                                    loading = false;
                                  });
                                  return;
                                }

                                var result = await _backend.addWorker(
                                    prefs.getString("token")!,
                                    _nameController.text,
                                    _emailController.text,
                                    _passwordController.text,
                                    Shared.me['data']['id']);

                                if (_backend.statusCode > 300) {
                                  setState(() {
                                    error = result.toString();
                                    loading = false;
                                  });
                                  return;
                                }
                                widget._initPage().then((value){
                                  super.setState(() {
                                    loading = false;
                                  });
                                });
                                Navigator.of(context).pop();
                              },
                        child: const Text(
                          "Add",
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: Icon(
          Icons.add,
        ),
      ),
      body: Shared.finishedLoadingWorkers
          ? Shared.workers.isEmpty
              ? Center(
                  child: Text("No workers"),
                )
              : ListView.builder(
                  itemCount: Shared.workers.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.account_circle,
                          size: 30,
                        ),
                        title:
                            Text(Shared.workers[index]['attributes']['name']),
                        subtitle:
                            Text(Shared.workers[index]['attributes']['email']),
                        trailing: Wrap(
                          spacing: -13,
                          children: [
                            IconButton(
                              onPressed: () {
                                _nameController.text =
                                    Shared.workers[index]['attributes']['name'];
                                _emailController.text = Shared.workers[index]
                                    ['attributes']['email'];
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          scrollable: true,
                                          title: const Text('Edit worker'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextFormField(
                                                controller: _nameController,
                                                keyboardType:
                                                    TextInputType.name,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  fillColor: Colors.grey[300],
                                                  filled: true,
                                                  hintText: "Full Name",
                                                  hintStyle: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              TextFormField(
                                                controller: _emailController,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  fillColor: Colors.grey[300],
                                                  filled: true,
                                                  hintText: "Email",
                                                  hintStyle: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              TextFormField(
                                                controller: _passwordController,
                                                keyboardType: TextInputType
                                                    .visiblePassword,
                                                obscureText: _passwordHidden,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  fillColor: Colors.grey[300],
                                                  filled: true,
                                                  hintText: "Password",
                                                  hintStyle: const TextStyle(
                                                      fontSize: 13),
                                                  suffixIcon: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _passwordHidden =
                                                            !_passwordHidden;
                                                      });
                                                    },
                                                    icon: Icon(
                                                      _passwordHidden
                                                          ? Icons.visibility_off
                                                          : Icons.visibility,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              TextFormField(
                                                controller:
                                                    _rpasswordController,
                                                keyboardType: TextInputType
                                                    .visiblePassword,
                                                obscureText: _rpasswordHidden,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  fillColor: Colors.grey[300],
                                                  filled: true,
                                                  hintText: "Re-Password",
                                                  hintStyle: const TextStyle(
                                                      fontSize: 13),
                                                  suffixIcon: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _rpasswordHidden =
                                                            !_rpasswordHidden;
                                                      });
                                                    },
                                                    icon: Icon(
                                                      _rpasswordHidden
                                                          ? Icons.visibility_off
                                                          : Icons.visibility,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              Text(
                                                error,
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ],
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('cancel'),
                                            ),
                                            TextButton(
                                              onPressed: loading
                                                  ? null
                                                  : () async {
                                                      setState(() {
                                                        loading = true;
                                                        error = '';
                                                      });

                                                      if (_passwordController
                                                              .text !=
                                                          _rpasswordController
                                                              .text) {
                                                        setState(() {
                                                          error =
                                                              "the 2 password fields did not match";
                                                          loading = false;
                                                        });
                                                        return;
                                                      }

                                                      var result = await _backend
                                                          .editWorker(
                                                              prefs.getString(
                                                                  "token")!,
                                                              _nameController
                                                                  .text,
                                                              _emailController
                                                                  .text,
                                                              _passwordController
                                                                  .text,
                                                              Shared.workers[
                                                                  index]['id']);

                                                      if (_backend.statusCode >
                                                          300) {
                                                        setState(() {
                                                          error = result;
                                                        });
                                                      }
                                                      widget
                                                          ._initPage()
                                                          .then((value) {
                                                        super.setState(() {
                                                          loading = false;
                                                        });
                                                      });
                                                      if (error.isEmpty) {
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    },
                                              child: const Text(
                                                "Save",
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.edit,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _backend
                                    .deleteWorker(prefs.getString("token")!,
                                        Shared.workers[index]["id"])
                                    .then((value) {
                                  if (_backend.statusCode < 300) {
                                    widget._initPage().then((value) {
                                      setState(() {});
                                    });
                                  } else {}
                                });
                              },
                              icon: Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class TasksTab extends StatefulWidget {
  var _initPage;

  TasksTab(this._initPage, {super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  late SharedPreferences prefs;
  final Backend _backend = Backend();
  bool loading = false;
  String error = "";
  int? dropDownValue = Shared.workers != null ? Shared.workers.isNotEmpty ? Shared.workers[0]['id'] : null : null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    print(Shared.tasks);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Add task'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            fillColor: Colors.grey[300],
                            filled: true,
                            hintText: "Title",
                            hintStyle: const TextStyle(fontSize: 13),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          maxLines: 4,
                          controller: _descriptionController,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            fillColor: Colors.grey[300],
                            filled: true,
                            hintText: "Description",
                            hintStyle: const TextStyle(fontSize: 13),
                          ),
                        ),
                        SizedBox(height: 20),
                        DropdownButton(
                          value: dropDownValue,
                          items: List.generate(
                              Shared.workers.length,
                              (index) => DropdownMenuItem(
                                  value: Shared.workers[index]['id'],
                                  child: Text(Shared.workers[index]
                                      ['attributes']['name']))),
                          onChanged: (value) {
                            setState(() {
                              dropDownValue = int.parse(value.toString());
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        Text(
                          error,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('cancel'),
                      ),
                      TextButton(
                        onPressed: loading
                            ? null
                            : () async {
                                setState(() {
                                  loading = true;
                                  error = '';
                                });

                                var result = await _backend.addTask(
                                    prefs.getString("token")!,
                                    _titleController.text,
                                    _descriptionController.text,
                                    dropDownValue!);

                                if (_backend.statusCode > 300) {
                                  setState(() {
                                    error = result.toString();
                                    loading = false;
                                  });
                                  return;
                                }
                                widget._initPage().then((value){
                                  super.setState(() {
                                    loading = false;
                                  });
                                });
                                Navigator.of(context).pop();
                              },
                        child: const Text(
                          "Add",
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: Icon(
          Icons.add,
        ),
      ),
      body: Shared.finishedLoadingTasks
          ? Shared.tasks['data'].isEmpty
              ? Center(
                  child: Text("No tasks"),
                )
              : ListView.builder(
                  itemCount: Shared.tasks['data'].length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: Shared.tasks['data'][index]['attributes']
                                    ['status'] ==
                                "rejected"
                            ? TextButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text("Rejection reason"),
                                          content: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            padding: EdgeInsets.all(10),
                                            child: Text(Shared.tasks['data']
                                                    [index]['attributes']
                                                ['reason']),
                                          ),
                                        );
                                      });
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: Size(30, 30),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.zero,
                                alignment: AlignmentDirectional.centerStart),
                                child: Text(
                                  Shared.tasks['data'][index]['attributes']
                                      ['worker']['attributes']['name'],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.red),
                                ),
                              )
                            : Text(Shared.tasks['data'][index]['attributes']
                                ['worker']['attributes']['name']),
                        title: Center(
                          child: IntrinsicHeight(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  Shared.tasks['data'][index]['attributes']['title'],
                                  textAlign: TextAlign.center,
                                ),
                                VerticalDivider(
                                  color: Colors.grey,
                                  thickness: 2,
                                ),
                                Text(
                                  Shared.tasks['data'][index]['attributes']['status'],
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        subtitle: Text(
                          Shared.tasks['data'][index]['attributes']
                              ['description'],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        trailing: Wrap(
                          spacing: -13,
                          children: [
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    _titleController.text = Shared.tasks['data'][index]['attributes']['title'];
                                    _descriptionController.text = Shared.tasks['data'][index]['attributes']['description'];
                                    dropDownValue = Shared.tasks['data'][index]['attributes']['worker']['id'];
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          title: const Text('Edit task'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextFormField(
                                                controller: _titleController,
                                                keyboardType: TextInputType.name,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius: BorderRadius.circular(15),
                                                  ),
                                                  fillColor: Colors.grey[300],
                                                  filled: true,
                                                  hintText: "Title",
                                                  hintStyle: const TextStyle(fontSize: 13),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              TextFormField(
                                                maxLines: 4,
                                                controller: _descriptionController,
                                                keyboardType: TextInputType.multiline,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius: BorderRadius.circular(15),
                                                  ),
                                                  fillColor: Colors.grey[300],
                                                  filled: true,
                                                  hintText: "Description",
                                                  hintStyle: const TextStyle(fontSize: 13),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              DropdownButton(
                                                value: dropDownValue,
                                                items: List.generate(
                                                    Shared.workers.length,
                                                        (index) => DropdownMenuItem(
                                                        value: Shared.workers[index]['id'],
                                                        child: Text(Shared.workers[index]
                                                        ['attributes']['name']))),
                                                onChanged: (value) {
                                                  setState(() {
                                                    dropDownValue = int.parse(value.toString());
                                                  });
                                                },
                                              ),
                                              SizedBox(height: 20),
                                              Text(
                                                error,
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            ],
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('cancel'),
                                            ),
                                            TextButton(
                                              onPressed: loading
                                                  ? null
                                                  : () async {
                                                setState(() {
                                                  loading = true;
                                                  error = '';
                                                });

                                                var result = await _backend.editTask(
                                                    prefs.getString("token")!,
                                                    Shared.tasks['data'][index]["id"],
                                                    _titleController.text,
                                                    _descriptionController.text,
                                                    dropDownValue!);

                                                if (_backend.statusCode > 300) {
                                                  setState(() {
                                                    error = result.toString();
                                                    loading = false;
                                                  });
                                                  return;
                                                }
                                                widget._initPage().then((value){
                                                  super.setState(() {
                                                    loading = false;
                                                  });
                                                });
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                "Save",
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.edit,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _backend
                                    .deleteTask(prefs.getString("token")!,
                                        Shared.tasks['data'][index]["id"])
                                    .then((value) {
                                  if (_backend.statusCode < 300) {
                                    setState(() {
                                      Shared.finishedLoadingTasks = false;
                                    });
                                    widget._initPage().then((value) {
                                      setState(() {
                                        Shared.finishedLoadingTasks = true;
                                      });
                                    });
                                  } else {}
                                });
                              },
                              icon: Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
