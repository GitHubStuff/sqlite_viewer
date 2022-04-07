import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../db/fsm_datasource.dart';

part 'build_state.dart';

class BuildCubit extends Cubit<BuildState> {
  BuildCubit() : super(BuildInitial());

  void build(List<DataColumn> columns, FSMDataSource source) {
    emit(BuildTable(columns, source));
  }

  void refresh() => emit(BuildInitial());
}
