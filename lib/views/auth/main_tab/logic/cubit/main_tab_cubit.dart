import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'main_tab_state.dart';

class MainTabCubit extends Cubit<MainTabState> {
  MainTabCubit() : super(MainTabInitial());
  int currentIndex = 0;

  void changeCurrentIndex(int index) {
    currentIndex = index;
    emit(IndexChanged());
  }
}
