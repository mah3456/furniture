import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:stores/domain/usecases/auth/getUserById.dart';
import 'package:stores/domain/usecases/auth/update_user_usecase.dart';
import '../../Domain/repostitories/auth_repository.dart';
import '../../data/datasource/local/authLocal_DataSource.dart';
import '../../data/repostitories/auth_repositoreyImpl.dart';
import '../../Domain/entities/user_entity.dart';
import '../../Domain/usecases/auth/login_usecase.dart';
import '../../Domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/GetCachedUserUseCase.dart';
import '../../main.dart';


// DataSource Provider
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl();
});

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(localDataSource: localDataSource);
});

// UseCase Providers
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository: repository);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository: repository);
});


final updateUserCaseProvider = Provider<UpdateUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return UpdateUserUseCase(repository: repository);
});


final refreshUserProvider = Provider<GetUserById>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetUserById(repository: repository);
});


// في ملف providers/auth_providers.dart

// UseCase Provider للحصول على المستخدم المخزن
final getCachedUserUseCaseProvider = Provider<GetCachedUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCachedUserUseCase(repository: repository);
});


// StateNotifier لإدارة حالة المصادقة
class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error, // مهم: لا تستخدم ?? هنا للسماح بمسح الخطأ
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final AuthRepository authRepository;
  final UpdateUserUseCase updateUserUseCase;
  final GetUserById getUserByid;

  AuthNotifier({
    required this.registerUseCase,
    required this.loginUseCase,
    required this.authRepository,
    required this.updateUserUseCase,
    required this.getUserByid
  }) : super(AuthState()) {
    checkAuthStatus();
  }




  Future<void> refreshUserData() async {
    print('=== بدء تحديث بيانات المستخدم ===');

    // التحقق من وجود مستخدم مسجل
    if (!state.isAuthenticated || state.user == null) {
      // محاولة استعادة المستخدم من التخزين المحلي
      print('⚠️ حالة المصادقة غير صحيحة، محاولة استعادة المستخدم...');
      final cachedUser = await authRepository.getCachedUser();

      if (cachedUser != null) {
        print('✅ تم استعادة المستخدم من التخزين المحلي');
        state = state.copyWith(
          user: cachedUser,
          isAuthenticated: true,
        );
      } else {
        print('❌ لا يوجد مستخدم مسجل لتحديث بياناته');
        return;
      }
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final currentUser = state.user!;
      final userId = currentUser.id;

      if (userId == null) {
        print('❌ معرف المستخدم غير موجود');
        state = state.copyWith(
          isLoading: false,
          error: 'معرف المستخدم غير موجود',
        );
        return;
      }

      // جلب البيانات المحدثة من قاعدة البيانات
      final result = await authRepository.getUserById(id: userId);

      result.fold(
            (failure) {
          print('❌ فشل التحديث: ${failure.message}');
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
            (user) async {
          print('✅ تم تحديث بيانات المستخدم بنجاح');
          print('الاسم: ${user.name}');
          print('البريد: ${user.email}');
          print('الهاتف: ${user.phone}');

          // تحديث التخزين المحلي
          await authRepository.getCachedUser();

          // تحديث حالة المستخدم
          state = state.copyWith(
            isLoading: false,
            user: user,
            isAuthenticated: true,
            error: null,
          );
        },
      );
    } catch (e) {
      print('❌ خطأ أثناء تحديث بيانات المستخدم: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ أثناء تحديث البيانات: $e',
      );
    }

    print('=== انتهاء تحديث بيانات المستخدم ===');
  }




  Future<void> checkAuthStatus() async {
    print('=== التحقق من حالة تسجيل الدخول عند بدء التطبيق ===');

    try {
      final isLoggedIn = await authRepository.isLoggedIn();
      print('حالة تسجيل الدخول: $isLoggedIn');

      if (isLoggedIn) {
        final cachedUser = await authRepository.getCachedUser();
        print('المستخدم المخزن: $cachedUser');

        if (cachedUser != null) {
          state = state.copyWith(
            isAuthenticated: true,
            user: cachedUser,
          );
          print('تم استعادة جلسة المستخدم بنجاح');
        } else {
          // إذا كان isLoggedIn = true لكن لا يوجد مستخدم، نسجل الخروج
          print('بيانات المستخدم غير موجودة، جاري تسجيل الخروج');
          await authRepository.logout();
          state = AuthState();
        }
      }
    } catch (e) {
      print('خطأ في التحقق من حالة تسجيل الدخول: $e');
      state = AuthState();
    }

    print('=== انتهاء التحقق من حالة تسجيل الدخول ===');
  }





  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    print('بدء عملية التسجيل في AuthNotifier');
    print('البيانات: name=$name, phone=$phone, email=$email');

    state = state.copyWith(isLoading: true, error: null);

    final user = UserEntity(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );

    final result = await registerUseCase(RegisterParams(user));

    result.fold((failure) {
        print('فشل التسجيل: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          isAuthenticated: false,
        );
      },

        (user) {
        print('نجاح التسجيل: ${user.email}');
        state = state.copyWith(
          isLoading: false,
          user: user,
          isAuthenticated: true,
          error: null,
        );
      },
    );
  }




  Future<void> login(String email, String password) async {
    print('=== بدء عملية تسجيل الدخول ===');
    print('البريد الإلكتروني: $email');

    state = state.copyWith(isLoading: true, error: null);

    final result = await loginUseCase(LoginParams(email, password));

    result.fold((failure) {
        print('❌ فشل تسجيل الدخول: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          isAuthenticated: false,
        );
      },
          (user) {
        print('✅ تم تسجيل الدخول بنجاح');
        print('المستخدم: ${user.name}');
        print('البريد: ${user.email}');

        state = state.copyWith(
          isLoading: false,
          user: user,
          isAuthenticated: true,
          error: null,
        );

        print('=== انتهاء عملية تسجيل الدخول ===');
      },
    );
  }




  Future<int> update({
    required String name,
    required String phone,
    required String email,
  }) async {
    print('بدء عملية التحديث في AuthNotifier');
    print('البيانات: name=$name, phone=$phone, email=$email');

    state = state.copyWith(isLoading: true, error: null);

    final uid = await shared.getString('user_id');

    // الحصول على المستخدم الحالي للحفاظ على البيانات الأخرى
    final currentUser = state.user;

    final user = UserEntity(
      id: int.tryParse(uid!),
      name: name,
      phone: phone,
      email: email,
      // إذا كان لديك حقل password، احتفظ بالقيمة القديمة
      password: currentUser?.password ?? '',
    );

    final result = await updateUserUseCase(UpdateParams(user));

    return result.fold(
          (failure) {
        print('فشل التحديث: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          isAuthenticated: false,
        );
        return -1;
      },
          (userId) async {
        // بعد نجاح التحديث، قم بتحديث بيانات المستخدم في التخزين المحلي
        print('✅ تم تحديث المستخدم بنجاح، معرف المستخدم: $userId');

        // تحديث المستخدم في التخزين المحلي
        await authRepository.getCachedUser();

        // تحديث حالة المستخدم
        state = state.copyWith(
          isLoading: false,
          user: user,  // تحديث بيانات المستخدم
          isAuthenticated: true,
          error: null,
        );

        print('✅ تم تحديث حالة المستخدم بنجاح');
        return 1;
      },
    );
  }





  Future<void> logout() async {
    print('=== تسجيل الخروج ===');
    await authRepository.logout();
    state = AuthState();
    print('تم تسجيل الخروج بنجاح');
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}



// AuthNotifier Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final registerUseCase = ref.watch(registerUseCaseProvider);
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final updateRepository = ref.watch(updateUserCaseProvider);
  final refreshUser = ref.watch(refreshUserProvider);


  return AuthNotifier(
    registerUseCase: registerUseCase,
    loginUseCase: loginUseCase,
    authRepository: authRepository,
    updateUserUseCase: updateRepository,
    getUserByid: refreshUser
  );
});