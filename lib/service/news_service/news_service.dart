import 'package:teamxperience/service/news_service/upload_news_images.dart';

import '../../backend/repo/stire_repo.dart';
import '../../exceptions/news_exceptions.dart';
import '../../model/stire.dart';

class NewsService {
  final StireRepo _stireRepo = StireRepo();
  final UploadNewsImagesHelper _uploadImagesHelper = UploadNewsImagesHelper();

  Future<List<Stire>> getAllStire() async {
    try {
      return await _stireRepo.getAllStire();
    } catch (e) {
      throw StireServiceException('Failed to load news: $e');
    }
  }

  Future<Stire> createStire(Stire stire) async {
    try {
      // Generate ID if needed
      if (stire.id == null || stire.id!.isEmpty) {
        stire.id = await _stireRepo.getNewStireId();
      }

      // Upload images
      stire = await _uploadImagesHelper.uploadNewsImages(stire);

      // Save to repository
      await _stireRepo.createStire(stire);

      return stire;
    } catch (e) {
      throw StireServiceException('Failed to create news: $e');
    }
  }

  Future<Stire> updateStire(Stire stire) async {
    try {
      // Upload images if needed
      stire = await _uploadImagesHelper.uploadNewsImages(stire);

      // Update in repository
      await _stireRepo.createStire(stire);

      return stire;
    } catch (e) {
      throw StireServiceException('Failed to update news: $e');
    }
  }

}