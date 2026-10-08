import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/models/recruiter_coordination_model.dart';
import '../data/services/recruiter_coordination_api_service.dart';

// ============================================================================
// EVENTS
// ============================================================================
abstract class RecruiterCoordinationEvent extends Equatable {
  const RecruiterCoordinationEvent();

  @override
  List<Object?> get props => [];
}

class FetchRecruitersEvent extends RecruiterCoordinationEvent {
  const FetchRecruitersEvent();
}

class SearchRecruitersEvent extends RecruiterCoordinationEvent {
  final String query;
  const SearchRecruitersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterByStatusEvent extends RecruiterCoordinationEvent {
  final String status;
  const FilterByStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class SelectPartnerEvent extends RecruiterCoordinationEvent {
  final String partnerId;
  const SelectPartnerEvent(this.partnerId);

  @override
  List<Object?> get props => [partnerId];
}

class ChangePartnerTabEvent extends RecruiterCoordinationEvent {
  final String tab; // 'jobs', 'talent', 'history', 'analytics'
  const ChangePartnerTabEvent(this.tab);

  @override
  List<Object?> get props => [tab];
}

class AddCorporatePartnerEvent extends RecruiterCoordinationEvent {
  final CorporatePartnerModel partner;
  const AddCorporatePartnerEvent(this.partner);

  @override
  List<Object?> get props => [partner];
}

class SendProposalEvent extends RecruiterCoordinationEvent {
  final String partnerId;
  final String companyName;
  final String proposedRole;
  final String packageLPA;
  final String tentativeDates;

  const SendProposalEvent({
    required this.partnerId,
    required this.companyName,
    required this.proposedRole,
    required this.packageLPA,
    required this.tentativeDates,
  });

  @override
  List<Object?> get props => [partnerId, companyName, proposedRole, packageLPA, tentativeDates];
}

class MessageRecruiterEvent extends RecruiterCoordinationEvent {
  final String recruiterEmail;
  final String messageText;

  const MessageRecruiterEvent({
    required this.recruiterEmail,
    required this.messageText,
  });

  @override
  List<Object?> get props => [recruiterEmail, messageText];
}

class RefreshRecruitersEvent extends RecruiterCoordinationEvent {
  const RefreshRecruitersEvent();
}

class ClearActionMessageEvent extends RecruiterCoordinationEvent {
  const ClearActionMessageEvent();
}

// ============================================================================
// STATES
// ============================================================================
abstract class RecruiterCoordinationState extends Equatable {
  const RecruiterCoordinationState();

  @override
  List<Object?> get props => [];
}

class RecruiterCoordinationInitial extends RecruiterCoordinationState {}

class RecruiterCoordinationLoading extends RecruiterCoordinationState {}

class RecruiterCoordinationLoaded extends RecruiterCoordinationState {
  final RecruiterCoordinationData rawData;
  final List<CorporatePartnerModel> customPartners;
  final String selectedPartnerId;
  final String activeTab; // 'jobs', 'talent', 'history', 'analytics'
  final String searchQuery;
  final String selectedStatus;
  final bool isSubmitting;
  final String? actionMessage;
  final bool isSuccessMessage;

  const RecruiterCoordinationLoaded({
    required this.rawData,
    this.customPartners = const [],
    this.selectedPartnerId = '',
    this.activeTab = 'jobs',
    this.searchQuery = '',
    this.selectedStatus = 'All',
    this.isSubmitting = false,
    this.actionMessage,
    this.isSuccessMessage = true,
  });

  List<CorporatePartnerModel> get allPartners {
    return [...customPartners, ...rawData.partners];
  }

  List<CorporatePartnerModel> get filteredPartners {
    final q = searchQuery.toLowerCase().trim();
    return allPartners.where((p) {
      final matchesQuery = q.isEmpty ||
          p.companyName.toLowerCase().contains(q) ||
          p.industry.toLowerCase().contains(q) ||
          p.contactName.toLowerCase().contains(q) ||
          p.location.toLowerCase().contains(q);

      final matchesStatus = selectedStatus == 'All' ||
          p.statusBadge.toLowerCase().contains(selectedStatus.replaceAll(RegExp(r'[^\w\s]'), '').trim().toLowerCase());

      return matchesQuery && matchesStatus;
    }).toList();
  }

  CorporatePartnerModel? get selectedPartner {
    if (allPartners.isEmpty) return null;
    return allPartners.firstWhere(
      (p) => p.id == selectedPartnerId,
      orElse: () => allPartners.first,
    );
  }

  RecruiterCoordinationLoaded copyWith({
    RecruiterCoordinationData? rawData,
    List<CorporatePartnerModel>? customPartners,
    String? selectedPartnerId,
    String? activeTab,
    String? searchQuery,
    String? selectedStatus,
    bool? isSubmitting,
    String? actionMessage,
    bool? isSuccessMessage,
  }) {
    return RecruiterCoordinationLoaded(
      rawData: rawData ?? this.rawData,
      customPartners: customPartners ?? this.customPartners,
      selectedPartnerId: selectedPartnerId ?? this.selectedPartnerId,
      activeTab: activeTab ?? this.activeTab,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionMessage: actionMessage,
      isSuccessMessage: isSuccessMessage ?? this.isSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
    rawData,
    customPartners,
    selectedPartnerId,
    activeTab,
    searchQuery,
    selectedStatus,
    isSubmitting,
    actionMessage,
    isSuccessMessage,
  ];
}

class RecruiterCoordinationError extends RecruiterCoordinationState {
  final String message;
  const RecruiterCoordinationError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================================
// BLOC
// ============================================================================
class RecruiterCoordinationBloc
    extends Bloc<RecruiterCoordinationEvent, RecruiterCoordinationState> {
  final RecruiterCoordinationApiService _apiService;

  RecruiterCoordinationBloc({RecruiterCoordinationApiService? apiService})
      : _apiService = apiService ?? RecruiterCoordinationApiService(),
        super(RecruiterCoordinationInitial()) {
    on<FetchRecruitersEvent>(_onFetchRecruiters);
    on<SearchRecruitersEvent>(_onSearchRecruiters);
    on<FilterByStatusEvent>(_onFilterByStatus);
    on<SelectPartnerEvent>(_onSelectPartner);
    on<ChangePartnerTabEvent>(_onChangePartnerTab);
    on<AddCorporatePartnerEvent>(_onAddCorporatePartner);
    on<SendProposalEvent>(_onSendProposal);
    on<MessageRecruiterEvent>(_onMessageRecruiter);
    on<RefreshRecruitersEvent>(_onRefreshRecruiters);
    on<ClearActionMessageEvent>(_onClearActionMessage);
  }

  void _onFilterByStatus(
    FilterByStatusEvent event,
    Emitter<RecruiterCoordinationState> emit,
  ) {
    if (state is RecruiterCoordinationLoaded) {
      final loaded = state as RecruiterCoordinationLoaded;
      emit(loaded.copyWith(selectedStatus: event.status));
    }
  }

  Future<void> _onFetchRecruiters(
    FetchRecruitersEvent event,
    Emitter<RecruiterCoordinationState> emit,
  ) async {
    emit(RecruiterCoordinationLoading());
    try {
      final data = await _apiService.fetchRecruiters();
      final initialId = data.partners.isNotEmpty ? data.partners.first.id : '';
      emit(RecruiterCoordinationLoaded(
        rawData: data,
        selectedPartnerId: initialId,
      ));
    } catch (e) {
      emit(RecruiterCoordinationError('Failed to load corporate partners: $e'));
    }
  }

  void _onSearchRecruiters(
    SearchRecruitersEvent event,
    Emitter<RecruiterCoordinationState> emit,
  ) {
    if (state is RecruiterCoordinationLoaded) {
      final loaded = state as RecruiterCoordinationLoaded;
      emit(loaded.copyWith(searchQuery: event.query));
    }
  }

  void _onSelectPartner(
    SelectPartnerEvent event,
    Emitter<RecruiterCoordinationState> emit,
  ) {
    if (state is RecruiterCoordinationLoaded) {
      final loaded = state as RecruiterCoordinationLoaded;
      emit(loaded.copyWith(selectedPartnerId: event.partnerId));
    }
  }

  void _onChangePartnerTab(
    ChangePartnerTabEvent event,
    Emitter<RecruiterCoordinationState> emit,
  ) {
    if (state is RecruiterCoordinationLoaded) {
      final loaded = state as RecruiterCoordinationLoaded;
      emit(loaded.copyWith(activeTab: event.tab));
    }
  }

  Future<void> _onAddCorporatePartner(
    AddCorporatePartnerEvent event,
    Emitter<RecruiterCoordinationState> emit,
  ) async {
    if (state is RecruiterCoordinationLoaded) {
      final loaded = state as RecruiterCoordinationLoaded;
      emit(loaded.copyWith(isSubmitting: true));

      await _apiService.addCorporatePartner(event.partner);

      final updatedList = [event.partner, ...loaded.customPartners];
      final currentTotal = loaded.rawData.totalPartners;
      final isDrive = event.partner.statusBadge.contains('Active Drive');
      final updatedRawData = loaded.rawData.copyWith(
        totalPartners: currentTotal + 1,
        activeDrives: isDrive ? loaded.rawData.activeDrives + 1 : loaded.rawData.activeDrives,
      );

      emit(loaded.copyWith(
        rawData: updatedRawData,
        customPartners: updatedList,
        selectedPartnerId: event.partner.id,
        isSubmitting: false,
        actionMessage: 'Partner ${event.partner.companyName} onboarded successfully!',
        isSuccessMessage: true,
      ));
    }
  }

  Future<void> _onSendProposal(
    SendProposalEvent event,
    Emitter<RecruiterCoordinationState> emit,
  ) async {
    if (state is RecruiterCoordinationLoaded) {
      final loaded = state as RecruiterCoordinationLoaded;
      emit(loaded.copyWith(isSubmitting: true));

      await _apiService.sendDriveProposal(
        partnerId: event.partnerId,
        companyName: event.companyName,
        proposedRole: event.proposedRole,
        packageLPA: event.packageLPA,
        tentativeDates: event.tentativeDates,
      );

      emit(loaded.copyWith(
        isSubmitting: false,
        actionMessage: 'Drive proposal sent to ${event.companyName} recruitment team.',
        isSuccessMessage: true,
      ));
    }
  }

  Future<void> _onMessageRecruiter(
    MessageRecruiterEvent event,
    Emitter<RecruiterCoordinationState> emit,
  ) async {
    if (state is RecruiterCoordinationLoaded) {
      final loaded = state as RecruiterCoordinationLoaded;
      await _apiService.messageRecruiter(
        recruiterEmail: event.recruiterEmail,
        messageText: event.messageText,
      );
      emit(loaded.copyWith(
        actionMessage: 'Message dispatched to ${event.recruiterEmail}.',
        isSuccessMessage: true,
      ));
    }
  }

  Future<void> _onRefreshRecruiters(
    RefreshRecruitersEvent event,
    Emitter<RecruiterCoordinationState> emit,
  ) async {
    try {
      final data = await _apiService.fetchRecruiters();
      if (state is RecruiterCoordinationLoaded) {
        final loaded = state as RecruiterCoordinationLoaded;
        emit(loaded.copyWith(rawData: data));
      } else {
        emit(RecruiterCoordinationLoaded(
          rawData: data,
          selectedPartnerId: data.partners.isNotEmpty ? data.partners.first.id : '',
        ));
      }
    } catch (_) {}
  }

  void _onClearActionMessage(
    ClearActionMessageEvent event,
    Emitter<RecruiterCoordinationState> emit,
  ) {
    if (state is RecruiterCoordinationLoaded) {
      final loaded = state as RecruiterCoordinationLoaded;
      emit(loaded.copyWith(actionMessage: null));
    }
  }
}
