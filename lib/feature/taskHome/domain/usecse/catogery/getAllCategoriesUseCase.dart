
import '../../../data/model/categoryModel.dart';
import '../../repo_interface/repoCatogery.dart';

class GetAllCategoriesUseCase {
  final CategoryRepository categoryRepository;

  GetAllCategoriesUseCase(this.categoryRepository);


  Future<List<CategoryModel>> call() async {
    return await categoryRepository.getAllCategories();
  }
}
