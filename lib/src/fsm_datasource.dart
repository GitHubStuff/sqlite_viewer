import 'package:flutter/material.dart';

class FSMDataSource extends DataTableSource {
  List<List<Widget>> _data = [];

  addData(List<List<Widget>> data) {
    _data.clear();
    _data.addAll(data);
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    return DataRow(
        cells: _data[index].map((cell) {
      return DataCell(cell);
    }).toList());
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
