import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial()) {
    _initializeHome();
  }

  void _initializeHome() {
    final lastWorkoutArr = [
      {
        "name": "Full Body Workout",
        "image": "assets/img/Workout1.png",
        "kcal": "180",
        "time": "20",
        "progress": 0.3,
      },
      {
        "name": "Lower Body Workout",
        "image": "assets/img/Workout2.png",
        "kcal": "200",
        "time": "30",
        "progress": 0.4,
      },
      {
        "name": "Ab Workout",
        "image": "assets/img/Workout3.png",
        "kcal": "300",
        "time": "40",
        "progress": 0.7,
      },
    ];

    final waterArr = [
      {"title": "6am - 8am", "subtitle": "600ml"},
      {"title": "9am - 11am", "subtitle": "500ml"},
      {"title": "11am - 2pm", "subtitle": "1000ml"},
      {"title": "2pm - 4pm", "subtitle": "700ml"},
      {"title": "4pm - now", "subtitle": "900ml"},
    ];

    emit(
      HomeLoaded(
        showingTooltipOnSpots: [21],
        lastWorkoutArr: lastWorkoutArr,
        waterArr: waterArr,
      ),
    );
  }

  void updateTooltipSpot(int spotIndex) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(showingTooltipOnSpots: [spotIndex]));
    }
  }
}
