import 'package:flutter_bloc/flutter_bloc.dart';

class ResultCubit extends Cubit<int> {
  ResultCubit() : super(0); // 0 = Photo tab, 1 = Statistic tab

  void selectTab(int index) => emit(index);
}
