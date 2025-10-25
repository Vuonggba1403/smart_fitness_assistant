import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingCubit extends Cubit<int> {
  OnboardingCubit() : super(0); // state = chỉ số trang hiện tại

  void changePage(int index) => emit(index);

  void nextPage(int totalPages) {
    if (state < totalPages - 1) {
      emit(state + 1);
    }
  }
}
