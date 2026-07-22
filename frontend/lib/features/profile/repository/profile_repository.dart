import '../model/participant_profile.dart';
import '../service/profile_service.dart';

class ProfileRepository {
  ProfileRepository(this._service);
  final ProfileService _service;

  Future<ParticipantProfile> getProfile() async =>
      ParticipantProfile.fromResponse(await _service.fetchProfile());

  Future<void> updateProfile({required String name, required String email}) =>
      _service.updateProfile(name: name, email: email);

  Future<void> updatePassword({required String currentPassword, required String password, required String confirmation}) =>
      _service.updatePassword(currentPassword: currentPassword, password: password, confirmation: confirmation);

  Future<void> uploadPhoto({required List<int> bytes, required String filename}) =>
      _service.uploadPhoto(bytes: bytes, filename: filename);

  Future<void> logout() => _service.logout();
}
