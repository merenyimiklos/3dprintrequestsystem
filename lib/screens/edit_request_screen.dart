import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/enums.dart';
import '../providers/request_provider.dart';
import '../utils/app_constants.dart';
import '../utils/enum_helpers.dart';

/// Pre-filled form for editing an existing print request.
class EditRequestScreen extends StatefulWidget {
  final String requestId;

  const EditRequestScreen({super.key, required this.requestId});

  @override
  State<EditRequestScreen> createState() => _EditRequestScreenState();
}

class _EditRequestScreenState extends State<EditRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _requesterNameController = TextEditingController();
  final _classGroupController = TextEditingController();
  final _projectNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController();
  final _estimatedTimeController = TextEditingController();
  final _notesController = TextEditingController();

  // Dropdown values
  PrinterType? _selectedPrinter;
  MaterialType? _selectedMaterial;
  Priority _selectedPriority = Priority.normal;
  PrintStatus _selectedStatus = PrintStatus.pending;

  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _requesterNameController.dispose();
    _classGroupController.dispose();
    _projectNameController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _estimatedTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Populate controllers from the existing request on first build.
  void _initForm(BuildContext context) {
    if (_initialized) return;
    _initialized = true;

    final provider = context.read<RequestProvider>();
    final request = provider.allRequests.firstWhere(
      (r) => r.id == widget.requestId,
    );

    _requesterNameController.text = request.requesterName;
    _classGroupController.text = request.classGroup;
    _projectNameController.text = request.projectName;
    _descriptionController.text = request.description;
    _colorController.text = request.color;
    _estimatedTimeController.text = request.estimatedPrintTime.toString();
    _notesController.text = request.notes;
    _selectedPrinter = request.printer;
    _selectedMaterial = request.material;
    _selectedPriority = request.priority;
    _selectedStatus = request.status;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<RequestProvider>();
    final existing = provider.allRequests.firstWhere(
      (r) => r.id == widget.requestId,
    );

    final updated = existing.copyWith(
      requesterName: _requesterNameController.text.trim(),
      classGroup: _classGroupController.text.trim(),
      projectName: _projectNameController.text.trim(),
      description: _descriptionController.text.trim(),
      printer: _selectedPrinter,
      material: _selectedMaterial,
      color: _colorController.text.trim(),
      estimatedPrintTime: double.parse(_estimatedTimeController.text.trim()),
      priority: _selectedPriority,
      status: _selectedStatus,
      notes: _notesController.text.trim(),
      updatedAt: DateTime.now(),
    );

    await provider.updateRequest(updated);

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Request updated successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _initForm(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Request')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            // ── Requester information ────────────────────────────────────
            const _SectionHeader(title: 'Requester Information'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _requesterNameController,
              decoration: const InputDecoration(
                labelText: 'Requester Name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: _required('requester name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _classGroupController,
              decoration: const InputDecoration(
                labelText: 'Class / Group',
                prefixIcon: Icon(Icons.group_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),

            // ── Project information ──────────────────────────────────────
            const _SectionHeader(title: 'Project Information'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _projectNameController,
              decoration: const InputDecoration(
                labelText: 'Project Name *',
                prefixIcon: Icon(Icons.folder_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: _required('project name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // ── Print settings ───────────────────────────────────────────
            const _SectionHeader(title: 'Print Settings'),
            const SizedBox(height: 12),
            DropdownButtonFormField<PrinterType>(
              value: _selectedPrinter,
              decoration: const InputDecoration(
                labelText: 'Printer *',
                prefixIcon: Icon(Icons.print_outlined),
              ),
              items: PrinterType.values
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(printerLabel(p)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedPrinter = v),
              validator: (v) => v == null ? 'Please select a printer' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MaterialType>(
              value: _selectedMaterial,
              decoration: const InputDecoration(
                labelText: 'Material *',
                prefixIcon: Icon(Icons.science_outlined),
              ),
              items: MaterialType.values
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(materialLabel(m)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedMaterial = v),
              validator: (v) => v == null ? 'Please select a material' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Color',
                prefixIcon: Icon(Icons.palette_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _estimatedTimeController,
              decoration: const InputDecoration(
                labelText: 'Estimated Print Time (hours) *',
                prefixIcon: Icon(Icons.timer_outlined),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: _positiveNumber,
            ),
            const SizedBox(height: 24),

            // ── Status & priority ────────────────────────────────────────
            const _SectionHeader(title: 'Status & Priority'),
            const SizedBox(height: 12),
            DropdownButtonFormField<PrintStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.info_outline),
              ),
              items: PrintStatus.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(printStatusLabel(s)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedStatus = v);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Priority>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: Priority.values
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(priorityLabel(p)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedPriority = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.note_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),

            // Save button
            FilledButton.icon(
              onPressed: _isSaving ? null : _submit,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Saving…' : 'Save Changes'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String? Function(String?) _required(String field) => (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the $field';
        }
        return null;
      };

  String? _positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter estimated print time';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Please enter a valid number';
    if (parsed <= 0) return 'Time must be greater than 0';
    return null;
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const Divider(),
      ],
    );
  }
}
