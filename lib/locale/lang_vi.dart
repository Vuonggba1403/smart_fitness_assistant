import 'package:flutter/material.dart';
import 'package:intl/locale.dart';

import 'locale_key.dart';

Map<String, String> viVN = {
  LocaleKey.language: 'VI',
  LocaleKey.appName: 'Smart Fitness',

  //Onboarding view
  LocaleKey.textOnboarding: 'Ai cũng có thể tập luyện',
  LocaleKey.titleOnBoarding1: 'Theo dõi mục tiêu của bạn',
  LocaleKey.titleOnBoarding2: 'Đốt cháy năng lượng',
  LocaleKey.titleOnBoarding3: 'Ăn uống lành mạnh',
  LocaleKey.titleOnBoarding4: 'Cải thiện\nchất lượng giấc ngủ',
  LocaleKey.subtitleOnBoarding:
      'Đừng lo nếu bạn gặp khó khăn trong việc xác định mục tiêu. Chúng tôi sẽ giúp bạn đặt ra và theo dõi mục tiêu của mình.',
  LocaleKey.subtitleOnBoarding2:
      'Hãy tiếp tục tập luyện để đạt được mục tiêu. Cơn đau chỉ là tạm thời — nếu bạn bỏ cuộc, nỗi đau sẽ kéo dài mãi mãi.',
  LocaleKey.subtitleOnBoarding3:
      'Hãy bắt đầu lối sống lành mạnh cùng chúng tôi. Chúng tôi sẽ giúp bạn lên thực đơn mỗi ngày — ăn uống lành mạnh cũng rất thú vị!',
  LocaleKey.subtitleOnBoarding4:
      'Cải thiện chất lượng giấc ngủ cùng chúng tôi. Một giấc ngủ ngon sẽ mang lại tâm trạng tuyệt vời vào buổi sáng.',

  //permission Message
  LocaleKey.permissionMessage: "Vui lòng không để trống",

  //change language dialog
  LocaleKey.langChanged: "Đã thay đổi ngôn ngữ thành công!",

  LocaleKey.changeDarkMode: "Đã thay đổi chế độ thành công!",

  //Login View
  LocaleKey.textLogin: "Xin chào",
  LocaleKey.forgotPassword: "Quên mật khẩu?",
  LocaleKey.buttonLogin: "Đăng nhập",
  LocaleKey.dontAccount: "Chưa có tài khoản?",
  LocaleKey.buttonRegis: "Đăng ký",
  LocaleKey.or: "Hoặc",
  //Login View - Message
  LocaleKey.loginSuccess: "Đăng nhập thành công",
  LocaleKey.loginError: "Đăng nhập thất bại",

  //Register View
  LocaleKey.textRegister: "Tạo tài khoản của bạn",
  LocaleKey.haveAccount: "Đã có tài khoản?",
  //Register View-Complete profile
  LocaleKey.titleCompleteProfile: "Hoàn thành hồ sơ của bạn",
  LocaleKey.textCompleteProfile: "Nó sẽ giúp chúng tôi hiểu rõ hơn về bạn!",
  LocaleKey.hintHeight: "Nhập chiều cao của bạn",
  LocaleKey.hintWeight: "Nhập cân nặng của bạn",
  LocaleKey.hintWeightGoal: "Nhập mục tiêu cân nặng của bạn",
  LocaleKey.hintAge: "Nhập tuổi của bạn",
  LocaleKey.textHeight1: "Chiều cao của bạn",
  LocaleKey.textWeight1: "Cân nặng của bạn",
  LocaleKey.textAge: "Tuổi",
  LocaleKey.buttonNext: "Tiếp theo",
  //Register-Message
  LocaleKey.registerSuccess: "Đăng ký thành công",
  LocaleKey.registerError: "Đăng ký thất bại",
  LocaleKey.whatYourGoal: "Mục tiêu của bạn",
  //Forgot Password View
  LocaleKey.titleForgotPassword: "Quên mật khẩu",
  LocaleKey.textForgotPassword:
      "Vui lòng nhập địa chỉ email của bạn để nhận liên kết đặt lại mật khẩu.",
  LocaleKey.buttonSend: "Gửi",
  LocaleKey.passwordResetError: "Lỗi đặt lại mật khẩu",
  LocaleKey.passwordResetSuccess: "Email đặt lại mật khẩu đã được gửi",

  //Home View
  LocaleKey.welcomeBack: 'Chào mừng trở lại',
  LocaleKey.dailyActivity: 'Hoạt động hàng ngày',
  LocaleKey.latestWorkout: 'Buổi tập gần đây',
  LocaleKey.seeMore: 'Xem thêm',
  LocaleKey.todayTarget: "Mục tiêu hôm nay",
  LocaleKey.check: "Kiểm tra",
  //BMI
  LocaleKey.bmi: "BMI (Chỉ số khối cơ thể)",
  LocaleKey.classificationBMI1: "Gầy độ III",
  LocaleKey.classificationBMI2: "Gầy độ II",
  LocaleKey.classificationBMI3: "Gầy độ I",
  LocaleKey.classificationBMI4: "Bình thường",
  LocaleKey.classificationBMI5: "Thừa cân",
  LocaleKey.classificationBMI6: "Béo phì độ I",
  LocaleKey.classificationBMI7: "Béo phì độ II",
  LocaleKey.classificationBMI8: "Béo phì độ III",

  //Select view
  LocaleKey.workoutTracker: 'Theo dõi Tập Luyện',
  LocaleKey.mealPlanner: 'Kế Hoạch Ăn Uống',
  LocaleKey.drinkWater: 'Theo dõi Uống Nước',
  LocaleKey.changeLanguage: 'Thay đổi Ngôn ngữ',

  //Profile View
  LocaleKey.profile: "Trang cá nhân",
  LocaleKey.editProfile: "Chỉnh sửa",
  LocaleKey.textHeight: "Chiều cao",
  LocaleKey.textWeight: "Cân nặng",
  LocaleKey.textWeightGoal: "Mục tiêu",
  LocaleKey.account: "Tài khoản",
  LocaleKey.darkMode: "Chế độ tối",
  LocaleKey.accountArr1: "Dữ liệu cá nhân",
  LocaleKey.accountArr2: "Thành tích",
  LocaleKey.accountArr3: "Lịch sử hoạt động",
  LocaleKey.accountArr4: "Tiến độ tập luyện",
  LocaleKey.other: "Khác",
  LocaleKey.otherArr1: "Liên hệ với chúng tôi",
  LocaleKey.otherArr2: "Chính sách quyền riêng tư",
  LocaleKey.otherArr3: "Cài đặt",
  LocaleKey.logout: "Đăng xuất",
  LocaleKey.logoutSuccess: "Đăng xuất thành công",
  LocaleKey.logoutError: "Đăng xuất thất bại",
  LocaleKey.deleteAcc: "Tài khoản đã được xóa thành công.",
  LocaleKey.yearOld: "Tuổi",
  LocaleKey.titleAlog: "Xác nhận xóa tài khoản",
  LocaleKey.contentAlog:
      "Hành động này không thể hoàn tác và tất cả dữ liệu sẽ bị xóa vĩnh viễn.",
  LocaleKey.buttonNo: "Hủy",
  LocaleKey.buttonYes: "Có",
  LocaleKey.delAcc: "Xóa tài khoản",
  //Work Tracker View
  LocaleKey.gymEx: "Bài tập tại phòng gym",
  LocaleKey.homeEx: "Bài tập tại nhà", // ✅ THÊM TRANSLATION
  LocaleKey.dailyWorkoutSchedule: "Lịch tập hàng ngày",
  LocaleKey.upCommingWork: "Buổi tập sắp tới",
  LocaleKey.exercises: "Bài tập",
  LocaleKey.mins: "Phút",
  LocaleKey.kcal: "Kcal",
  LocaleKey.startWorkout: "Bắt đầu tập luyện",
  LocaleKey.item: "Mục",
  LocaleKey.youNeed: "Bạn cần",
  LocaleKey.device: "Thiết bị",
  LocaleKey.muscleGroup: "Khu vực tập trung",
  LocaleKey.des: "Cách thực hiện",
  LocaleKey.completeEx: "Hoàn tất",
  LocaleKey.noEquipment: "Không cần thiết bị",
  LocaleKey.sets: "Sets",
  LocaleKey.reps: "Reps",
  LocaleKey.titleDialog: "Ngừng Tập",
  LocaleKey.contentDialog: "Bạn có chắc chắn muốn ngừng tập không?",

  // Time ago
  LocaleKey.justNow: "Vừa xong",
  LocaleKey.minutesAgo: "phút trước",
  LocaleKey.hoursAgo: "giờ trước",
  LocaleKey.daysAgo: "ngày trước",
  LocaleKey.weeksAgo: "tuần trước",

  //Water Tracker
  LocaleKey.dailyGoal: "Mục tiêu hàng ngày",
  LocaleKey.nextReminder: "Nhắc nhở tiếp theo",
  LocaleKey.addWater: "Thêm nước",
  LocaleKey.waterIntake: "Ghi nước một chạm",
  LocaleKey.snackBar: "Cập nhật cài đặt nhắc nhở thành công!",
  LocaleKey.reminder: "Đã cập nhật nhắc nhở",
  LocaleKey.texttitlewater: "Ghi nước\nmột chạm",
  LocaleKey.reminderWater: "Nhắc nhở uống nước",
  LocaleKey.startWater: "Bắt đầu từ",
  LocaleKey.endWater: "Kết thúc lúc",
  LocaleKey.nhac: "Nhắc mỗi",
  LocaleKey.khoangtime: "Chọn khoảng thời gian",
  LocaleKey.buttonSave: "Lưu",
  LocaleKey.titleDialogWater: "Xuất sắc! 🎉",
  LocaleKey.contentDialogWater: "ĐÃ HOÀN THÀNH\nMỤC TIÊU UỐNG NƯỚC!",
  LocaleKey.textDialog:
      "Tuyệt vời! Bạn đã hoàn thành mục tiêu uống nước hôm nay.",
  LocaleKey.buttonCon: "Tiếp tục",

  //Social View
  LocaleKey.postImg: "Chụp ảnh",
  LocaleKey.choiceImg: "Chọn từ thư viện",
  LocaleKey.titleSocial: "Diễn Đàn Fitness",
  LocaleKey.noPost: "Chưa có bài đăng",
  LocaleKey.newThing: "Có gì mới không? 💭",
  LocaleKey.buttonPost: "Ảnh/Video",
  LocaleKey.createPost: "Tạo bài đăng",
  LocaleKey.tagWork: "Gắn thẻ bài tập (tuỳ chọn)",
  LocaleKey.chooseWork: "Chọn bài tập",
  LocaleKey.submitPic: "Ảnh đã chọn",
  LocaleKey.changePic: "Thay đổi ảnh",
  LocaleKey.caption: "Chú thích",
  LocaleKey.writeCap: "Viết chú thích...*",
  LocaleKey.postNew: "Đăng bài",
  LocaleKey.comments: "Bình luận",
  LocaleKey.noComments: "Chưa có bình luận nào",
  LocaleKey.writeComments: "Viết bình luận...",
  LocaleKey.loading: "Đang tải...",
};
