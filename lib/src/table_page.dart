// Show a single table
import 'package:extensions_package/extensions_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/build_cubit.dart';
import 'cubit/cubit_singleton.dart';
import 'drift/drift_bridge.dart';
import 'fsm_datasource.dart';
import 'structure_page.dart';

class TablePage extends StatefulWidget {
  final String sql;
  final String tableName;
  final DriftBridge driftBridge;
  final int rowsPerPage;

  TablePage({
    Key? key,
    required this.tableName,
    required this.driftBridge,
    required this.sql,
    this.rowsPerPage = 8,
  }) : super(key: key ?? UniqueKey());

  _TablePageState createState() => _TablePageState(this.tableName);
}

class _TablePageState extends ObservingStatefulWidget<TablePage> {
  String tableName;
  _TablePageState(this.tableName);

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    super.afterFirstLayout(context);
    Future.delayed(Duration(milliseconds: 250), () {
      CubitSingleton().cubit.refresh();
    });
  }

  @override
  void didChangePlatformBrightness() {}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress)
          return false;
        else
          return true;
      },
      child: SafeArea(
        child: Container(
          color: Colors.blueGrey,
          child: Column(
            children: <Widget>[
              /// 'Clear table', 'Refresh', 'Structure' buttons
              Container(
                child: Wrap(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ElevatedButton(
                        child: Text("Clear table", style: Theme.of(context).textTheme.button),
                        onPressed: () {
                          widget.driftBridge.clear(table: widget.tableName).then((value) {
                            _getData();
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ElevatedButton(
                        child: Text("Refresh", style: Theme.of(context).textTheme.button),
                        onPressed: () {
                          CubitSingleton().cubit.refresh();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ElevatedButton(
                        child: Text("Structure", style: Theme.of(context).textTheme.button),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                            return StructurePage(sql: widget.sql);
                          }));
                        },
                      ),
                    )
                  ],
                ),
              ),

              ///If the number doesn't reach full length of the widget, Expanded fills the gap
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: _displayDataWithHeaders(),
                  ),
                ),
              ),

              /// Back/pop button
              Container(
                padding: EdgeInsets.all(20),
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  key: UniqueKey(),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _displayDataWithHeaders() {
    final bloc = CubitSingleton().cubit;
    return BlocBuilder<BuildCubit, BuildState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is BuildInitial) {
          Future.delayed(Duration(milliseconds: 500), () {
            _getData();
          });
          return CircularProgressIndicator(color: Colors.amberAccent);
        }
        if (state is BuildTable) {
          return state.columns.isNotEmpty
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.white60,
                    BlendMode.colorBurn,
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.black87,
                      iconTheme: IconThemeData().copyWith(color: Colors.deepPurple),
                    ),
                    child: PaginatedDataTable(
                      rowsPerPage: widget.rowsPerPage,
                      columns: state.columns,
                      header: Text(
                        widget.tableName,
                        style: TextStyle(color: Colors.lightGreenAccent, fontSize: 32.0),
                      ),
                      source: state.dataSource,
                    ),
                  ),
                )
              : Container(color: Colors.black12);
        }
        return Text('Huh?');
      },
    );
  }

  _getData() {
    final sql = "SELECT * FROM ${widget.tableName} ORDER BY rowid";
    widget.driftBridge.rawSql(sql).then(
      (rows) {
        FSMDataSource _dataSource = FSMDataSource();
        if (rows.length > 0) {
          List<List<Widget>> list = [];
          rows.forEach((row) {
            list.add(row.values
                .map((value) => Text(
                      value.toString(),
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ))
                .toList());
          });
          _dataSource.addData(list);
        } else {
          _dataSource.addData([]);
        }
        _getColumns(_dataSource);
      },
    );
  }

  _getColumns(FSMDataSource data) {
    widget.driftBridge.rawSql("select group_concat(name, '|') from pragma_table_info('${this.tableName}')").then(
      (rows) {
        var cleanedRows = rows;
        var columnsString = cleanedRows.toString().replaceAll("[{group_concat(name, '|'): ", "").replaceAll("}]", "");
        var column = columnsString.toString().split("|");
        final columnNameColor = Colors.green[800]!;
        List<DataColumn> columnNames = [];
        columnNames.addAll(column.map((key) {
          return DataColumn(
            label: Text(
              key.trimLeft().split(' ').first,
              style: TextStyle(color: columnNameColor),
            ),
          );
        }).toList());

        CubitSingleton().cubit.build(columnNames, data);
      },
    );
  }
}
