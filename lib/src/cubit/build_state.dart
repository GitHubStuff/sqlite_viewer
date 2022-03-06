part of 'build_cubit.dart';

@immutable
abstract class BuildState {}

class BuildInitial extends BuildState {}

class BuildTable extends BuildState {
  final List<DataColumn> columns;
  final FSMDataSource dataSource;
  BuildTable(this.columns, this.dataSource) : super();
}
