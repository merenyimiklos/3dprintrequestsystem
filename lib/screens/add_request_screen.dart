import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/print_request.dart';
import '../models/enums.dart';
import '../providers/request_provider.dart';
import '../utils/app_constants.dart';
import '../utils/enum_helpers.dart';

/// Form screen for submitting a new 3D print request.
class AddRequestScreen extends StatefulWidget {
  const AddRequestScreen({super.key});

  @override
  State<AddRequestScreen> createState() => _AddRequestScreenState();
}

class _AddRequestScreenState extends State<AddRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _requesterNameController = TextEditingController();
  final _classGroupController = TextEditingController();
  final _projectNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController();
  final _estimatedTimeController = TextEditingController();
  final _notesController = TextEditingController();

  // Dropdown selections
  PrinterType? _selectedPrinter;
  MaterialType? _selectedMaterial;
  Priority _selectedPriority = Priority.normal;

  bool _isSaving = false;

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<RequestProvider>();
    final now = DateTime.now();

    final request = PrintRequest(
      id: provider.generateId(),
      requesterName: _requesterNameController.text.trim(),
      classGroup: _classGroupController.text.trim(),
      projectName: _projectNameController.text.trim(),
      description: _descriptionController.text.trim(),
      printer: _selectedPrinter!,
      material: _selectedMaterial!,
      color: _colorController.text.trim(),
      estimatedPrintTime: double.parse(_estimatedTimeController.text.trim()),
      priority: _selectedPriority,
      status: PrintStatus.pending,
      notes: _notesController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await provider.addRequest(request);

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Request submitted successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Print Request')),
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
              validator: _requiredValidator('requester name'),
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
              validator: _requiredValidator('project name'),
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
              validator: _positiveNumberValidator,
            ),
            const SizedBox(height: 24),

            // ── Additional settings ──────────────────────────────────────
            const _SectionHeader(title: 'Additional Settings'),
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

            // Submit button
            FilledButton.icon(
              onPressed: _isSaving ? null : _submit,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(_isSaving ? 'Submitting…' : 'Submit Request'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String? Function(String?) _requiredValidator(String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter the $fieldName';
      }
      return null;
    };
  }

  String? _positiveNumberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter estimated print time';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Please enter a valid number';
    if (parsed <= 0) return 'Time must be greater than 0';
    return null;
  }
}

/// Section header with a title and a divider below it.
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
