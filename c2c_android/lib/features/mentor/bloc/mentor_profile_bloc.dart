import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/mentor_repository.dart';
import 'mentor_profile_event.dart';
import 'mentor_profile_state.dart';

class MentorProfileBloc extends Bloc<MentorProfileEvent, MentorProfileState> {
  final MentorRepository _repository;

  MentorProfileBloc({MentorRepository? repository})
      : _repository = repository ?? MentorRepository(),
        super(const MentorProfileInitial()) {
    on<FetchMentorProfileEvent>(_onFetchProfile);
    on<UpdateMentorProfileEvent>(_onUpdateProfile);
    on<ToggleAvailabilityEvent>(_onToggleAvailability);
    on<AddExpertiseTagEvent>(_onAddExpertiseTag);
    on<RemoveExpertiseTagEvent>(_onRemoveExpertiseTag);
  }

  Future<void> _onFetchProfile(
    FetchMentorProfileEvent event,
    Emitter<MentorProfileState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const MentorProfileLoading());
    }

    try {
      final profile = await _repository.getMentorProfile();
      emit(MentorProfileLoaded(
        profile: profile,
        toastMessage: event.isRefresh ? 'Profile credentials refreshed' : null,
      ));
    } catch (e) {
      emit(MentorProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateMentorProfileEvent event,
    Emitter<MentorProfileState> emit,
  ) async {
    if (state is! MentorProfileLoaded) return;
    final current = state as MentorProfileLoaded;

    emit(current.copyWith(isSaving: true, toastMessage: null));

    try {
      final updated = await _repository.updateMentorProfile(event.updatedProfile);
      emit(MentorProfileLoaded(
        profile: updated,
        isSaving: false,
        toastMessage: 'Profile credentials updated successfully',
      ));
    } catch (_) {
      // Optimistic fallback
      emit(MentorProfileLoaded(
        profile: event.updatedProfile.copyWith(isMock: true),
        isSaving: false,
        toastMessage: 'Profile updated locally (offline mode)',
      ));
    }
  }

  Future<void> _onToggleAvailability(
    ToggleAvailabilityEvent event,
    Emitter<MentorProfileState> emit,
  ) async {
    if (state is! MentorProfileLoaded) return;
    final current = state as MentorProfileLoaded;

    final newVal = !current.profile.availabilitySwitch;
    final optimisticProfile = current.profile.copyWith(availabilitySwitch: newVal);

    emit(current.copyWith(
      profile: optimisticProfile,
      toastMessage: newVal ? 'Availability booking activated' : 'Availability booking paused',
    ));

    try {
      final serverVal = await _repository.toggleMentorAvailability(current.profile.availabilitySwitch);
      if (serverVal != newVal) {
        emit(current.copyWith(
          profile: current.profile.copyWith(availabilitySwitch: serverVal),
        ));
      }
    } catch (_) {
      // Keep optimistic value
    }
  }

  Future<void> _onAddExpertiseTag(
    AddExpertiseTagEvent event,
    Emitter<MentorProfileState> emit,
  ) async {
    if (state is! MentorProfileLoaded) return;
    final current = state as MentorProfileLoaded;
    final trimmed = event.tag.trim();
    if (trimmed.isEmpty || current.profile.expertiseTags.contains(trimmed)) return;

    final updatedTags = List<String>.from(current.profile.expertiseTags)..add(trimmed);
    final updatedProfile = current.profile.copyWith(expertiseTags: updatedTags);

    emit(current.copyWith(
      profile: updatedProfile,
      toastMessage: 'Added "$trimmed" to expertise tags',
    ));

    try {
      await _repository.updateMentorProfile(updatedProfile);
    } catch (_) {}
  }

  Future<void> _onRemoveExpertiseTag(
    RemoveExpertiseTagEvent event,
    Emitter<MentorProfileState> emit,
  ) async {
    if (state is! MentorProfileLoaded) return;
    final current = state as MentorProfileLoaded;
    final trimmed = event.tag.trim();

    final updatedTags = List<String>.from(current.profile.expertiseTags)..remove(trimmed);
    final updatedProfile = current.profile.copyWith(expertiseTags: updatedTags);

    emit(current.copyWith(
      profile: updatedProfile,
      toastMessage: 'Removed "$trimmed" tag',
    ));

    try {
      await _repository.updateMentorProfile(updatedProfile);
    } catch (_) {}
  }
}
