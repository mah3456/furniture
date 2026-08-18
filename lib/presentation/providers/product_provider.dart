import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:stores/main.dart';
import '../../Domain/entities/product_entity.dart';
import '../../Domain/repostitories/product_Repository.dart';
import '../../core/usecases/usecase.dart';
import '../../data/datasource/local/productLocal_DataSource.dart';
import '../../data/repostitories/product_RepositoryImpl.dart';
import '../../Domain/usecases/product/addProduct_UseCase.dart';
import '../../Domain/usecases/product/getProducts_UseCase.dart';
import '../../Domain/usecases/product/getUser_products.dart';


// DataSource Provider
final productLocalDataSourceProvider = Provider<ProductLocalDataSource>((ref) {
  return ProductLocalDataSourceImpl();
});

// Repository Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final localDataSource = ref.watch(productLocalDataSourceProvider);
  return ProductRepositoryImpl(localDataSource: localDataSource);
});

// UseCase Providers
final addProductUseCaseProvider = Provider<AddProductUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return AddProductUseCase(repository: repository);
});

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductsUseCase(repository: repository);
});


final getUserProductsUseCaseProvider = Provider<GetUserProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetUserProductsUseCase(repository: repository);
});


// Product State
class ProductState {
  final bool isLoading;
  final List<Product> products;
  final String? error;

  ProductState({
    this.isLoading = false,
    this.products = const [],
    this.error,
  });

  ProductState copyWith({
    bool? isLoading,
    List<Product>? products,
    String? error,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      error: error,
    );
  }
}

// Product Notifier
class ProductNotifier extends StateNotifier<ProductState> {
  final AddProductUseCase addProductUseCase;
  final GetProductsUseCase getProductsUseCase;
  final GetUserProductsUseCase getUserProductsUseCase;


  ProductNotifier({
    required this.addProductUseCase,
    required this.getProductsUseCase,
    required this.getUserProductsUseCase
  }) : super(ProductState()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getProductsUseCase(NoParams());

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
          (products) {
        state = state.copyWith(
          isLoading: false,
          products: products,
        );
      },
    );
  }

  Future<void> loadUserProducts({required String userId}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getUserProductsUseCase(UserParams(userId));

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },


       (products) {
        state = state.copyWith(
          isLoading: false,
          products: products,
        );
      },
    );
  }

  Future<void> addProduct({required String name,required String type,required double price , required String description}) async {
    state = state.copyWith(isLoading: true, error: null);

    final uid = await shared.getString('user_id');


    final product = Product(Userid: uid, description: description, name: name, type: type, price: price);
    final result = await addProductUseCase(AddProductParams(product));

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
          (product) {
        // إعادة تحميل القائمة بعد الإضافة
        loadProducts();
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Product Provider
final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final addProductUseCase = ref.watch(addProductUseCaseProvider);
  final getProductsUseCase = ref.watch(getProductsUseCaseProvider);
  final getUserProductsUseCase = ref.watch(getUserProductsUseCaseProvider);


  return ProductNotifier(
    addProductUseCase: addProductUseCase,
    getProductsUseCase: getProductsUseCase,
    getUserProductsUseCase :getUserProductsUseCase
  );
});