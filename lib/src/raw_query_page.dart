import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:persisted_cache/persisted_cache.dart';
import 'package:sqlite_viewer/src/persisted_singleton.dart';

import '../sqlite_viewer.dart';

class RawQueryPage extends StatefulWidget {
  final DriftBridge driftBridge;
  final int rowsPerPage;

  const RawQueryPage({
    Key? key,
    required this.driftBridge,
    required this.rowsPerPage,
  }) : super(key: key);

  @override
  _RawQueryPage createState() => _RawQueryPage();
}

class _DBDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> _data;
  final Color textColor;

  _DBDataTableSource(this._data, {required this.textColor});

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    return DataRow(
      cells: _data[index].values.map((value) {
        return DataCell(Text(
          "$value",
          style: TextStyle(color: textColor),
        ));
      }).toList(),
    );
  }
}

class _RawQueryPage extends State<RawQueryPage> {
  List<Map<String, dynamic>>? _result;
  String _error = '';
  bool _isQueryRunning = false;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Raw Query'),
        actions: [
          //ThemeControlWidget(),
        ],
        iconTheme: IconThemeData(color: Colors.red),
        elevation: 0.0,
      ),
      body: _buildBody(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _persistingWidget() {
    PersistedCubit persistedCubit = PersistedSingleton().cubit;
    return BlocBuilder<PersistedCubit, PersistedState>(
        bloc: persistedCubit,
        builder: (context, state) {
          return PersistedWidet();
        });
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: <Widget>[
          _persistingWidget(),
          //_buildCommandBar(),
          SizedBox(height: 4.0),
          Expanded(
            child: _buildResult(),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    if (this._isQueryRunning) {
      return CircularProgressIndicator();
    }

    if (this._error.isNotEmpty) {
      return Text(
        _error,
        style: TextStyle(
          color: Colors.red,
        ),
      );
    }

    if (this._result == null) {
      return Container();
    }

    if (this._result != null && this._result!.isEmpty) {
      return Text(
        "Success.\nResults: $_result",
        style: TextStyle(backgroundColor: Colors.greenAccent),
      );
    }

    return SingleChildScrollView(
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.blueAccent,
          BlendMode.colorBurn,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.amberAccent,
            iconTheme: IconThemeData().copyWith(color: Colors.lightGreen),
          ),
          child: PaginatedDataTable(
            columns: _result![0].keys.map((key) {
              return DataColumn(
                label: Text(
                  key,
                  style: TextStyle(color: Colors.deepOrange),
                ),
              );
            }).toList(),
            header: Text(
              'Result',
              style: TextStyle(color: Colors.purple),
            ),
            source: _DBDataTableSource(_result!, textColor: Colors.black87),
            rowsPerPage: this.widget.rowsPerPage,
          ),
        ),
      ),
    );
  }

  void _runQuery(String sql) async {
    String query = sql;
    if (query.isEmpty) {
      return;
    }

    try {
      setState(() {
        _error = '';
        _isQueryRunning = true;
      });

      final result = await widget.driftBridge.rawSql(query);

      setState(() {
        _result = result;
        _isQueryRunning = false;
      });
    } catch (error) {
      setState(() {
        _error = "Invalid SQL Query! \n${error.toString()}";
        _isQueryRunning = false;
      });
    }
  }
}
