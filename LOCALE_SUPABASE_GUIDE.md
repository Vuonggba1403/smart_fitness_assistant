# 📘 Hướng Dẫn Locale Dữ Liệu Từ Supabase

## 📌 Tổng Quan Về Hệ Thống Hiện Tại

### 1. **Cách Locale Đang Hoạt Động**

Hiện tại app của bạn sử dụng **GetX Translation** với:

- **2 ngôn ngữ**: Tiếng Việt (vi_VI) và Tiếng Anh (en_US)
- **File quản lý**:
  - `lib/locale/translation_manager.dart` - Quản lý ngôn ngữ
  - `lib/locale/locale_key.dart` - Các key translation
  - `lib/locale/lang_vi.dart` - Bản dịch tiếng Việt
  - `lib/locale/lang_en.dart` - Bản dịch tiếng Anh

### 2. **Vấn Đề Với Dữ Liệu Từ Supabase**

Dữ liệu từ Supabase (exercise categories, exercises, meals...) **KHÔNG được locale** vì:

- Chúng được lưu trực tiếp trong database
- Khi lấy về, chỉ có 1 ngôn ngữ (thường là Tiếng Việt hoặc Tiếng Anh)
- Không có cơ chế chuyển đổi ngôn ngữ

**Ví dụ**:

```dart
// Exercise Category từ DB
ExerciseCategory(
  titleEx: "Bài Tập Ngực", // ❌ Chỉ có tiếng Việt
  classify: "Bài tập tại phòng gym" // ❌ Chỉ có tiếng Việt
)
```

---

## 🎯 Các Giải Pháp Locale Dữ Liệu Supabase

### **Giải Pháp 1: Thêm Cột Đa Ngôn Ngữ Trong Database** ⭐ (Khuyên Dùng)

#### ✅ **Ưu điểm**:

- Dữ liệu đầy đủ, chính xác
- Dễ quản lý và mở rộng
- Performance tốt (không cần xử lý nhiều)

#### ❌ **Nhược điểm**:

- Phải sửa database schema
- Tốn storage hơn

#### 📝 **Cách Thực Hiện**:

##### **Bước 1: Sửa Database Schema**

Thêm các cột đa ngôn ngữ vào bảng `exercise_categories`:

```sql
-- Thêm cột cho tiếng Anh
ALTER TABLE exercise_categories
ADD COLUMN title_ex_en TEXT,
ADD COLUMN classify_en TEXT;

-- Cập nhật dữ liệu mẫu
UPDATE exercise_categories
SET
  title_ex_en = 'Chest Workout',
  classify_en = 'Gym Workout'
WHERE title_ex = 'Bài Tập Ngực';

UPDATE exercise_categories
SET
  title_ex_en = 'Home Abs Workout',
  classify_en = 'Home Workout'
WHERE title_ex = 'Bài Tập Bụng Tại Nhà';
```

Tương tự cho các bảng khác:

```sql
-- Bảng exercise_items
ALTER TABLE exercise_items
ADD COLUMN title_en TEXT,
ADD COLUMN des_en TEXT;

-- Bảng meals
ALTER TABLE meals
ADD COLUMN name_en TEXT,
ADD COLUMN description_en TEXT;

-- Bảng devices
ALTER TABLE devices
ADD COLUMN name_en TEXT;
```

##### **Bước 2: Sửa Model Class**

Cập nhật `ExerciseCategory` model:

```dart
// lib/core/models/exercise_category.dart
class ExerciseCategory extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? imgUrl;

  // Tiếng Việt (mặc định)
  final String? titleEx;
  final String? classify;

  // ✅ THÊM: Tiếng Anh
  final String? titleExEn;
  final String? classifyEn;

  final List<dynamic>? exerciseItems;

  const ExerciseCategory({
    this.id,
    this.createdAt,
    this.imgUrl,
    this.titleEx,
    this.classify,
    this.titleExEn, // ✅ THÊM
    this.classifyEn, // ✅ THÊM
    this.exerciseItems,
  });

  factory ExerciseCategory.fromJson(Map<String, dynamic> json) {
    return ExerciseCategory(
      id: json['id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      imgUrl: json['img_url'] as String?,
      titleEx: json['title_ex'] as String?,
      classify: json['classify'] as String?,
      titleExEn: json['title_ex_en'] as String?, // ✅ THÊM
      classifyEn: json['classify_en'] as String?, // ✅ THÊM
      exerciseItems: json['exercise_items'] as List<dynamic>?,
    );
  }

  // ✅ THÊM: Method lấy title theo ngôn ngữ hiện tại
  String getLocalizedTitle(String languageCode) {
    if (languageCode == 'en' && titleExEn != null) {
      return titleExEn!;
    }
    return titleEx ?? 'Unknown';
  }

  // ✅ THÊM: Method lấy classify theo ngôn ngữ hiện tại
  String getLocalizedClassify(String languageCode) {
    if (languageCode == 'en' && classifyEn != null) {
      return classifyEn!;
    }
    return classify ?? 'Unknown';
  }

  @override
  List<Object?> get props => [
    id, createdAt, imgUrl, titleEx, classify,
    titleExEn, classifyEn, exerciseItems, // ✅ THÊM
  ];
}
```

##### **Bước 3: Sử Dụng Trong UI**

```dart
// lib/views/workout_tracker/ui/workout_tracker_view.dart
import 'package:get/get.dart';

class WorkoutTrackerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ✅ Lấy ngôn ngữ hiện tại
    final currentLang = Get.locale?.languageCode ?? 'vi';

    return StreamBuilder<List<ExerciseCategory>>(
      stream: cubit.streamGymCategories(),
      builder: (context, snapshot) {
        final categories = snapshot.data ?? [];

        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];

            // ✅ Hiển thị theo ngôn ngữ
            final title = category.getLocalizedTitle(currentLang);
            final classify = category.getLocalizedClassify(currentLang);

            return ListTile(
              title: Text(title), // ✅ Tự động đổi ngôn ngữ
              subtitle: Text(classify),
            );
          },
        );
      },
    );
  }
}
```

---

### **Giải Pháp 2: Tạo Bảng Translation Riêng** 🔄

#### ✅ **Ưu điểm**:

- Không sửa schema hiện tại
- Dễ thêm ngôn ngữ mới
- Phù hợp khi có nhiều ngôn ngữ (> 3)

#### ❌ **Nhược điểm**:

- Phức tạp hơn
- Query chậm hơn (phải JOIN)

#### 📝 **Cách Thực Hiện**:

##### **Bước 1: Tạo Bảng Translation**

```sql
-- Tạo bảng translation chung
CREATE TABLE translations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  entity_type TEXT NOT NULL, -- 'exercise_category', 'exercise_item', 'meal', ...
  entity_id UUID NOT NULL, -- ID của entity cần translate
  field_name TEXT NOT NULL, -- 'title', 'description', ...
  language_code TEXT NOT NULL, -- 'vi', 'en', 'ja', ...
  translated_text TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Index để query nhanh
CREATE INDEX idx_translations_lookup
ON translations(entity_type, entity_id, field_name, language_code);

-- Thêm dữ liệu mẫu
INSERT INTO translations (entity_type, entity_id, field_name, language_code, translated_text)
VALUES
  ('exercise_category', 'uuid-of-chest-workout', 'title_ex', 'en', 'Chest Workout'),
  ('exercise_category', 'uuid-of-chest-workout', 'classify', 'en', 'Gym Workout'),
  ('exercise_category', 'uuid-of-abs-workout', 'title_ex', 'en', 'Home Abs Workout'),
  ('exercise_category', 'uuid-of-abs-workout', 'classify', 'en', 'Home Workout');
```

##### **Bước 2: Tạo Translation Service**

```dart
// lib/core/services/translation_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class TranslationService {
  final _supabase = Supabase.instance.client;

  // Cache để giảm số lần query
  final Map<String, Map<String, String>> _cache = {};

  /// Lấy bản dịch cho một entity
  ///
  /// [entityType]: 'exercise_category', 'exercise_item', 'meal'
  /// [entityId]: ID của entity
  /// [fieldName]: 'title', 'description'
  /// [languageCode]: 'en', 'vi'
  Future<String?> getTranslation({
    required String entityType,
    required String entityId,
    required String fieldName,
    String? languageCode,
  }) async {
    final lang = languageCode ?? Get.locale?.languageCode ?? 'vi';

    // Không cần translate nếu đang dùng tiếng Việt (ngôn ngữ gốc)
    if (lang == 'vi') return null;

    // Check cache
    final cacheKey = '$entityType:$entityId:$fieldName:$lang';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      final response = await _supabase
          .from('translations')
          .select('translated_text')
          .eq('entity_type', entityType)
          .eq('entity_id', entityId)
          .eq('field_name', fieldName)
          .eq('language_code', lang)
          .maybeSingle();

      final translatedText = response?['translated_text'] as String?;

      // Lưu vào cache
      if (translatedText != null) {
        _cache[cacheKey] = translatedText;
      }

      return translatedText;
    } catch (e) {
      print('❌ Error loading translation: $e');
      return null;
    }
  }

  /// Load batch translations cho danh sách entities
  Future<Map<String, String>> getBatchTranslations({
    required String entityType,
    required List<String> entityIds,
    required String fieldName,
    String? languageCode,
  }) async {
    final lang = languageCode ?? Get.locale?.languageCode ?? 'vi';

    if (lang == 'vi') return {};

    try {
      final response = await _supabase
          .from('translations')
          .select('entity_id, translated_text')
          .eq('entity_type', entityType)
          .in_('entity_id', entityIds)
          .eq('field_name', fieldName)
          .eq('language_code', lang);

      final Map<String, String> result = {};
      for (var row in response) {
        result[row['entity_id']] = row['translated_text'];
      }

      return result;
    } catch (e) {
      print('❌ Error loading batch translations: $e');
      return {};
    }
  }

  /// Clear cache khi đổi ngôn ngữ
  void clearCache() {
    _cache.clear();
  }
}
```

##### **Bước 3: Sửa Model**

```dart
// lib/core/models/exercise_category.dart
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/services/translation_service.dart';

class ExerciseCategory extends Equatable {
  final String? id;
  final String? titleEx;
  final String? classify;
  // ... các field khác

  // ✅ THÊM: Translation service (singleton)
  static final _translationService = Get.find<TranslationService>();

  // ✅ THÊM: Method async để lấy title đã translate
  Future<String> getLocalizedTitleAsync() async {
    if (id == null || titleEx == null) return 'Unknown';

    final translated = await _translationService.getTranslation(
      entityType: 'exercise_category',
      entityId: id!,
      fieldName: 'title_ex',
    );

    return translated ?? titleEx!;
  }

  // ✅ THÊM: Method async để lấy classify đã translate
  Future<String> getLocalizedClassifyAsync() async {
    if (id == null || classify == null) return 'Unknown';

    final translated = await _translationService.getTranslation(
      entityType: 'exercise_category',
      entityId: id!,
      fieldName: 'classify',
    );

    return translated ?? classify!;
  }

  // ... rest of class
}
```

##### **Bước 4: Inject Service vào App**

```dart
// lib/main.dart
Future<void> main() async {
  // ... existing code

  // ✅ THÊM: Register translation service
  Get.put(TranslationService());

  runApp(MyApp());
}
```

##### **Bước 5: Sử Dụng Trong UI**

```dart
// lib/views/workout_tracker/ui/workout_tracker_view.dart
StreamBuilder<List<ExerciseCategory>>(
  stream: cubit.streamGymCategories(),
  builder: (context, snapshot) {
    final categories = snapshot.data ?? [];

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        return FutureBuilder<String>(
          // ✅ Load bản dịch
          future: category.getLocalizedTitleAsync(),
          builder: (context, titleSnapshot) {
            final title = titleSnapshot.data ?? category.titleEx ?? 'Loading...';

            return ListTile(
              title: Text(title),
            );
          },
        );
      },
    );
  },
);
```

---

### **Giải Pháp 3: Mapping Trong Code (Không Sửa DB)** 💻

#### ✅ **Ưu điểm**:

- Không cần sửa database
- Nhanh chóng implement
- Phù hợp cho dự án nhỏ

#### ❌ **Nhược điểm**:

- Khó maintain khi có nhiều dữ liệu
- Hardcode trong code
- Không linh hoạt

#### 📝 **Cách Thực Hiện**:

##### **Bước 1: Tạo Map Dịch**

```dart
// lib/core/locale/database_translations.dart
class DatabaseTranslations {
  // ✅ Map tên categories từ Việt sang Anh
  static const Map<String, String> categoriesViToEn = {
    'Bài Tập Ngực': 'Chest Workout',
    'Bài Tập Lưng': 'Back Workout',
    'Bài Tập Vai': 'Shoulder Workout',
    'Bài Tập Chân': 'Leg Workout',
    'Bài Tập Bụng': 'Abs Workout',
    'Bài Tập Tay': 'Arm Workout',
    // ... thêm các category khác
  };

  // ✅ Map classify từ Việt sang Anh
  static const Map<String, String> classifyViToEn = {
    'Bài tập tại phòng gym': 'Gym Workout',
    'Bài tập tại nhà': 'Home Workout',
    'gym': 'Gym',
    'home': 'Home',
  };

  // ✅ Map exercises từ Việt sang Anh
  static const Map<String, String> exercisesViToEn = {
    'Đẩy Ngực Với Tạ Đơn': 'Dumbbell Chest Press',
    'Kéo Xà Đơn': 'Pull-up',
    'Squat': 'Squat',
    // ... thêm các exercise khác
  };

  // ✅ Method translate
  static String translateCategoryTitle(String vietnamese, String languageCode) {
    if (languageCode != 'en') return vietnamese;
    return categoriesViToEn[vietnamese] ?? vietnamese;
  }

  static String translateClassify(String vietnamese, String languageCode) {
    if (languageCode != 'en') return vietnamese;
    return classifyViToEn[vietnamese] ?? vietnamese;
  }

  static String translateExerciseTitle(String vietnamese, String languageCode) {
    if (languageCode != 'en') return vietnamese;
    return exercisesViToEn[vietnamese] ?? vietnamese;
  }
}
```

##### **Bước 2: Sửa Model**

```dart
// lib/core/models/exercise_category.dart
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/locale/database_translations.dart';

class ExerciseCategory extends Equatable {
  final String? titleEx;
  final String? classify;
  // ... other fields

  // ✅ THÊM: Method lấy title đã translate
  String getLocalizedTitle() {
    final lang = Get.locale?.languageCode ?? 'vi';
    return DatabaseTranslations.translateCategoryTitle(titleEx ?? '', lang);
  }

  // ✅ THÊM: Method lấy classify đã translate
  String getLocalizedClassify() {
    final lang = Get.locale?.languageCode ?? 'vi';
    return DatabaseTranslations.translateClassify(classify ?? '', lang);
  }

  // ... rest of class
}
```

##### **Bước 3: Sử Dụng Trong UI**

```dart
// lib/views/workout_tracker/ui/workout_tracker_view.dart
StreamBuilder<List<ExerciseCategory>>(
  stream: cubit.streamGymCategories(),
  builder: (context, snapshot) {
    final categories = snapshot.data ?? [];

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        // ✅ Sử dụng method đã translate
        final title = category.getLocalizedTitle();
        final classify = category.getLocalizedClassify();

        return ListTile(
          title: Text(title),
          subtitle: Text(classify),
        );
      },
    );
  },
);
```

---

## 🎯 So Sánh Các Giải Pháp

| Tiêu Chí          | Giải Pháp 1 (Cột DB) | Giải Pháp 2 (Bảng Translation) | Giải Pháp 3 (Hardcode) |
| ----------------- | -------------------- | ------------------------------ | ---------------------- |
| **Độ chính xác**  | ⭐⭐⭐⭐⭐           | ⭐⭐⭐⭐⭐                     | ⭐⭐⭐                 |
| **Performance**   | ⭐⭐⭐⭐⭐           | ⭐⭐⭐                         | ⭐⭐⭐⭐⭐             |
| **Dễ maintain**   | ⭐⭐⭐⭐             | ⭐⭐⭐                         | ⭐⭐                   |
| **Khó implement** | ⭐⭐                 | ⭐⭐⭐⭐                       | ⭐                     |
| **Scalability**   | ⭐⭐⭐⭐             | ⭐⭐⭐⭐⭐                     | ⭐⭐                   |
| **Phù hợp cho**   | Dự án vừa/lớn        | Nhiều ngôn ngữ                 | Dự án nhỏ/prototype    |

---

## 🚀 Khuyến Nghị

### **Nếu bạn mới bắt đầu**:

→ Dùng **Giải Pháp 3** (Hardcode) để test nhanh

### **Nếu dự án production**:

→ Dùng **Giải Pháp 1** (Cột DB) vì đơn giản và hiệu quả

### **Nếu cần hỗ trợ nhiều ngôn ngữ (> 3)**:

→ Dùng **Giải Pháp 2** (Bảng Translation)

---

## 📚 Best Practices

1. **Luôn có fallback**: Nếu không có bản dịch, hiển thị ngôn ngữ gốc
2. **Cache translations**: Giảm số lần query database
3. **Lazy loading**: Chỉ load translation khi cần
4. **Batch loading**: Load nhiều translations cùng lúc thay vì từng cái
5. **Clear cache khi đổi ngôn ngữ**: Đảm bảo hiển thị đúng

---

## 🔧 Ví Dụ Hoàn Chỉnh (Giải Pháp 1)

### File: `lib/core/models/exercise_category.dart`

```dart
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';

class ExerciseCategory extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? imgUrl;

  // Vietnamese (default)
  final String? titleEx;
  final String? classify;

  // English
  final String? titleExEn;
  final String? classifyEn;

  final List<dynamic>? exerciseItems;

  const ExerciseCategory({
    this.id,
    this.createdAt,
    this.imgUrl,
    this.titleEx,
    this.classify,
    this.titleExEn,
    this.classifyEn,
    this.exerciseItems,
  });

  factory ExerciseCategory.fromJson(Map<String, dynamic> json) {
    return ExerciseCategory(
      id: json['id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      imgUrl: json['img_url'] as String?,
      titleEx: json['title_ex'] as String?,
      classify: json['classify'] as String?,
      titleExEn: json['title_ex_en'] as String?,
      classifyEn: json['classify_en'] as String?,
      exerciseItems: json['exercise_items'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt?.toIso8601String(),
    'img_url': imgUrl,
    'title_ex': titleEx,
    'classify': classify,
    'title_ex_en': titleExEn,
    'classify_en': classifyEn,
    'exercise_items': exerciseItems,
  };

  /// Get localized title based on current language
  String get localizedTitle {
    final lang = Get.locale?.languageCode ?? 'vi';
    if (lang == 'en' && titleExEn != null && titleExEn!.isNotEmpty) {
      return titleExEn!;
    }
    return titleEx ?? 'Unknown';
  }

  /// Get localized classify based on current language
  String get localizedClassify {
    final lang = Get.locale?.languageCode ?? 'vi';
    if (lang == 'en' && classifyEn != null && classifyEn!.isNotEmpty) {
      return classifyEn!;
    }
    return classify ?? 'Unknown';
  }

  bool get isGymCategory {
    final classifyValue = classify?.toLowerCase().trim();
    return classifyValue == 'gym' || classifyValue == 'bài tập tại phòng gym';
  }

  bool get isHomeCategory {
    final classifyValue = classify?.toLowerCase().trim();
    return classifyValue == 'home' || classifyValue == 'bài tập tại nhà';
  }

  @override
  List<Object?> get props => [
    id, createdAt, imgUrl, titleEx, classify,
    titleExEn, classifyEn, exerciseItems,
  ];
}
```

### File: `lib/views/workout_tracker/ui/widgets/category_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';

class CategoryCard extends StatelessWidget {
  final ExerciseCategory category;
  final VoidCallback onTap;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            if (category.imgUrl != null)
              Image.network(category.imgUrl!),

            // ✅ Sử dụng localizedTitle thay vì titleEx
            Text(
              category.localizedTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // ✅ Sử dụng localizedClassify thay vì classify
            Text(
              category.localizedClassify,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## ✅ Checklist Implementation

- [ ] Chọn giải pháp phù hợp (1, 2 hoặc 3)
- [ ] Sửa database schema (nếu chọn giải pháp 1 hoặc 2)
- [ ] Cập nhật dữ liệu trong database
- [ ] Sửa Model classes
- [ ] Thêm method getLocalized...
- [ ] Cập nhật UI để sử dụng localized data
- [ ] Test chuyển đổi ngôn ngữ
- [ ] Clear cache khi đổi ngôn ngữ
- [ ] Test với data thật

---

Nếu bạn cần hỗ trợ implement một giải pháp cụ thể, hãy cho tôi biết! 🚀
