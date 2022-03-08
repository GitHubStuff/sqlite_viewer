// List of tables in the database
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as M;
import 'package:flutter_modular/flutter_modular.dart';

import 'drift/drift_bridge.dart';
import 'raw_query_page.dart';
import 'table_item.dart';
import 'table_page.dart';

class TablesPage extends StatefulWidget {
  final DriftBridge driftBridge;
  final Function? onDatabaseDeleted;
  final int rowsPerPage;

  TablesPage({
    Key? key,
    required this.driftBridge,
    this.onDatabaseDeleted,
    required this.rowsPerPage,
  }) : super(key: key);

  _TablesPageState createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  final streamController = StreamController<List<TableItem>>();
  final Map<String, int> recordCounts = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 350), () {
      _getTables();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_timer == null) {
      _timer = Timer.periodic(Duration(seconds: 30), (timer) {
        _getTables();
      });
    }
    return Scaffold(body: _body(context));
  }

  @override
  dispose() {
    _timer?.cancel();
    streamController.close();
    _timer = null;
    super.dispose();
  }

  /// Query 'sqlite_master' to retrieve information about all the tables
  /// in a database.
  ///
  /// 'sqlite_master' is a table that stores information about all the
  /// tables created in a database. It has the following schema:
  /// - type: TEXT
  /// - name: TEXT
  /// - tbl_name: TEXT
  /// - rootpage: INTEGER
  /// - sql: TEXT
  Future<void> _getTables() async {
    if (!widget.driftBridge.isOpen) return;
    var tablesRows = await widget.driftBridge.getTables();
    final List<TableItem> tables = tablesRows.map((table) => TableItem(table['name'] as String, table['sql'] as String)).toList();
    for (TableItem table in tables) {
      int count = (await widget.driftBridge.recordCount(tableName: table.name))!;
      recordCounts[table.name] = count;
    }

    streamController.sink.add(tables);
  }

  Widget _body(BuildContext context) {
    return Container(
      color: Colors.black87, // The backing color
      child: M.Column(
        children: <Widget>[
          Container(
            child: Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _getTables();
                    },
                    child: Text(
                      'Refresh',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Modular.to.push(
                        MaterialPageRoute(
                          builder: (context) {
                            return RawQueryPage(
                              driftBridge: widget.driftBridge,
                              rowsPerPage: widget.rowsPerPage, // leave room at botton
                            );
                          },
                        ),
                      );
                    },
                    child: Text('Query', style: Theme.of(context).textTheme.button),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<TableItem>>(
              stream: streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return RefreshIndicator(
                    backgroundColor: Colors.deepPurple,
                    color: Colors.amberAccent,
                    onRefresh: () {
                      _getTables();
                      return Future.delayed(Duration.zero);
                    },
                    child: ListView(
                      children: snapshot.data!.map((table) {
                        final String recordCount = (recordCounts[table.name] ?? 0) == 0 ? 'none' : (recordCounts[table.name] ?? 0).toString();
                        return ListTile(
                          title: Text(
                            table.name,
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 28.0,
                            ),
                          ),
                          subtitle: Text(
                            'Records: $recordCount',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 22.0,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                              return TablePage(
                                tableName: table.name,
                                driftBridge: widget.driftBridge,
                                sql: table.sql,
                                rowsPerPage: widget.rowsPerPage,
                              );
                            }));
                          },
                          trailing: Icon(
                            Icons.art_track,
                            color: Colors.amberAccent,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
