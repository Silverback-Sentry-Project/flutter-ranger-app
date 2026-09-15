import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/repositories/incident_repository.dart';
import '../../../../core/domain/repositories/location_repository.dart';
import '../../../../core/domain/repositories/notification_repository.dart';
import '../../../../core/models/domain_enums.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/theme/app_theme.dart';

class ReportIncidentScreen extends StatefulWidget {
  final String? draftId;
  const ReportIncidentScreen({super.key, this.draftId});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _descriptionController = TextEditingController();
  final _speciesController = TextEditingController();

  IncidentType _type = IncidentType.sighting;
  IncidentSeverity _severity = IncidentSeverity.medium;
  final List<String> _photos = [];
  String? _locationName;
  double _lat = 0;
  double _lng = 0;
  Park _park = Park.bwindiImpenetrable;
  bool _isLocationLoading = false;
  String? _locationError;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _isLocationLoading = true;
      _locationError = null;
    });
    final result = await sl<LocationRepository>().getCurrentLocation();
    result.fold(
      (failure) {
        setState(() {
          _isLocationLoading = false;
          _locationError = failure.message;
        });
      },
      (location) async {
        final name = await sl<LocationRepository>()
            .reverseGeocode(location.latitude, location.longitude);
        final detected = sl<LocationRepository>()
            .getParkFromLocation(location.latitude, location.longitude);
        if (!mounted) return;
        setState(() {
          _lat = location.latitude;
          _lng = location.longitude;
          _locationName = name;
          _park = Park.fromWire(detected);
          _isLocationLoading = false;
        });
      },
    );
  }

  bool get _canSubmit =>
      _descriptionController.text.trim().isNotEmpty &&
      (_type != IncidentType.sighting ||
          _speciesController.text.trim().isNotEmpty);

  Future<void> _takePhoto() async {
    final paths = await context.push<List<String>>('/report/camera');
    if (paths != null && paths.isNotEmpty) {
      setState(() => _photos.addAll(paths));
    }
  }

  Future<void> _save({bool asDraft = false}) async {
    setState(() {
      _isSaving = true;
      _saveError = null;
    });
    final details = NewIncidentDetails(
      type: _type,
      park: _park,
      community: _locationName ?? 'Unknown',
      species: _type == IncidentType.sighting
          ? (_speciesController.text.trim().isEmpty
              ? 'Unknown'
              : _speciesController.text.trim())
          : 'N/A',
      severity: _severity,
      summary: _descriptionController.text.trim(),
      lat: _lat,
      lng: _lng,
      locationName: _locationName,
      localImageUris: _photos,
    );

    String incidentId;
    if (widget.draftId != null) {
      await sl<IncidentRepository>().update(widget.draftId!, details,
          asDraft: asDraft);
      incidentId = widget.draftId!;
    } else {
      final result = await sl<IncidentRepository>().create(details,
          asDraft: asDraft);
      incidentId = result.fold((f) => f.message, (incident) => incident.id);
      if (result.isLeft()) {
        setState(() {
          _isSaving = false;
          _saveError = 'Failed to save report';
        });
        return;
      }
    }

    if (!asDraft) {
      await sl<NotificationRepository>().notifyPendingSync(incidentId);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (asDraft) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft saved')),
      );
    } else {
      context.pushReplacement('/report/submitted',
          extra: {'id': incidentId, 'online': true});
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _speciesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Report Incident')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Type', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: IncidentType.values.map((type) {
                final selected = type == _type;
                return ChoiceChip(
                  label: Text(_typeLabel(type)),
                  selected: selected,
                  onSelected: (_) => setState(() => _type = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Severity', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: IncidentSeverity.values.map((severity) {
                final selected = severity == _severity;
                return ChoiceChip(
                  label: Text(severity.wire.toLowerCase()),
                  selected: selected,
                  onSelected: (_) => setState(() => _severity = severity),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (_type == IncidentType.sighting) ...[
              TextField(
                controller: _speciesController,
                decoration: const InputDecoration(
                  hintText: 'Species (e.g. Elephant)',
                  labelText: 'Species',
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe what you saw...',
                labelText: 'Description',
              ),
            ),
            const SizedBox(height: 12),
            _locationSection(scheme),
            const SizedBox(height: 16),
            Text('Photos', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (_photos.isNotEmpty)
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) return _addPhotoButton();
                    final path = _photos[index - 1];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(path),
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _photos.remove(path)),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: AppThemeColors.destructive,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            else
              _addPhotoButton(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => _save(asDraft: true),
                    child: const Text('Save Draft'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isSaving
                        ? null
                        : (_canSubmit ? () => _save() : null),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit'),
                  ),
                ),
              ],
            ),
            if (_saveError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _saveError!,
                  style: TextStyle(color: scheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _locationSection(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _isLocationLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  Icons.location_on_outlined,
                  color: _locationError == null
                      ? scheme.primary
                      : scheme.error,
                ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _locationError ??
                  (_locationName ?? 'Detecting location...'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addPhotoButton() {
    return InkWell(
      onTap: _takePhoto,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.camera_alt_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _typeLabel(IncidentType type) {
    switch (type) {
      case IncidentType.sighting:
        return 'Sighting';
      case IncidentType.conflict:
        return 'Conflict';
      case IncidentType.emergency:
        return 'Emergency';
      case IncidentType.poaching:
        return 'Poaching';
      case IncidentType.snare:
        return 'Snare';
      case IncidentType.sos:
        return 'SOS';
    }
  }
}