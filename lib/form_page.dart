import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const List<String> kGenders = ['Male', 'Female', 'Other'];
const List<String> kCivilStatuses = [
  'Single',
  'Married',
  'Widowed',
  'Separated',
];

class FormDraft {
  final Map<String, TextEditingController> _text = {};
  final Map<String, String> _choice = {};

  TextEditingController ctrl(String label) =>
      _text.putIfAbsent(label, () => TextEditingController());

  String textOf(String label) => _text[label]?.text.trim() ?? '';
  String choiceOf(String label) => _choice[label] ?? '';

  void setChoice(String label, String? value) {
    if (value != null) _choice[label] = value;
  }

  bool isFilled(String label) => value(label).isNotEmpty;

  String value(String label) =>
      _choice.containsKey(label) ? _choice[label]! : textOf(label);

  Map<String, String> toMap() => {
        for (final e in _text.entries) e.key: e.value.text.trim(),
        ..._choice,
      };

  void clear() {
    for (final c in _text.values) {
      c.clear();
    }
    _choice.clear();
  }

  void dispose() {
    for (final c in _text.values) {
      c.dispose();
    }
    _text.clear();
    _choice.clear();
  }
}

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final FormDraft draft = FormDraft();

  @override
  void dispose() {
    draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PersonalDataPage1(draft: draft);
  }
}

// ---------------------------------------------------------------------------
// Shared field widgets
// ---------------------------------------------------------------------------

Widget gap([double height = 14]) => SizedBox(height: height);

Widget row(Widget left, Widget right) => Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );

Widget textField(
  FormDraft draft,
  String label, {
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
}) {
  return TextField(
    controller: draft.ctrl(label),
    keyboardType: keyboardType,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}

Widget dateField(BuildContext context, FormDraft draft, String label) {
  return TextField(
    controller: draft.ctrl(label),
    readOnly: true,
    onTap: () async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(1930, 1, 1),
        lastDate: now,
      );
      if (picked != null) {
        draft.ctrl(label).text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      }
    },
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      suffixIcon: const Icon(Icons.calendar_today_outlined),
    ),
  );
}

Widget choiceField(
  FormDraft draft,
  String label,
  List<String> options,
) {
  final selected = draft.choiceOf(label);
  return DropdownButtonFormField<String>(
    initialValue: selected.isEmpty ? null : selected,
    items: options
        .map((o) => DropdownMenuItem(value: o, child: Text(o)))
        .toList(),
    onChanged: (v) => draft.setChoice(label, v),
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}

Widget sectionTitle(String title) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );

bool ensureFilled(BuildContext context, FormDraft draft, List<String> labels) {
  for (final label in labels) {
    if (!draft.isFilled(label)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in: $label')),
      );
      return false;
    }
  }
  return true;
}

class PageShell extends StatelessWidget {
  const PageShell({
    super.key,
    required this.title,
    required this.step,
    required this.content,
    required this.footer,
  });

  final String title;
  final int step;
  final List<Widget> content;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(value: step / 3),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: content,
                ),
              ),
            ),
            footer,
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SCREEN 1 - Personal Data (part 1)
// ---------------------------------------------------------------------------

class PersonalDataPage1 extends StatelessWidget {
  const PersonalDataPage1({super.key, required this.draft});

  final FormDraft draft;

  static const List<String> requiredLabels = [
    'Name',
    'Gender',
    'Civil Status',
    'Date of Birth',
    'Age',
    'Place of Birth',
    'Date',
    'Citizenship',
    'Religion',
    'Height',
    'Weight',
    'Occupation',
    'Telephone',
    'Cellphone',
    'Email',
    'Current Address',
    'Permanent Address',
  ];

  @override
  Widget build(BuildContext context) {
    return PageShell(
      title: 'Personal Data (1 of 3)',
      step: 1,
      content: [
        sectionTitle('BIO-DATA'),
        textField(draft, 'Name'),
        gap(),
        row(
          choiceField(draft, 'Gender', kGenders),
          choiceField(draft, 'Civil Status', kCivilStatuses),
        ),
        gap(),
        row(
          dateField(context, draft, 'Date of Birth'),
          textField(draft, 'Age', keyboardType: TextInputType.number),
        ),
        gap(),
        row(
          textField(draft, 'Place of Birth'),
          dateField(context, draft, 'Date'),
        ),
        gap(),
        row(
          textField(draft, 'Citizenship'),
          textField(draft, 'Religion'),
        ),
        gap(),
        row(
          textField(draft, 'Height', keyboardType: TextInputType.number),
          textField(draft, 'Weight', keyboardType: TextInputType.number),
        ),
        gap(),
        row(
          textField(draft, 'Occupation'),
          textField(
            draft,
            'Telephone',
            keyboardType: TextInputType.phone,
          ),
        ),
        gap(),
        row(
          textField(
            draft,
            'Cellphone',
            keyboardType: TextInputType.phone,
          ),
          textField(
            draft,
            'Email',
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        gap(),
        textField(draft, 'Current Address', maxLines: 2),
        gap(),
        textField(draft, 'Permanent Address', maxLines: 2),
      ],
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ElevatedButton(
          onPressed: () {
            if (!ensureFilled(context, draft, requiredLabels)) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PersonalDataPage2(draft: draft),
              ),
            );
          },
          child: const Text('Next'),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SCREEN 2 - Personal Data (part 2): family + emergency contact
// ---------------------------------------------------------------------------

class PersonalDataPage2 extends StatelessWidget {
  const PersonalDataPage2({super.key, required this.draft});

  final FormDraft draft;

  static const List<String> requiredLabels = [
    'Language or Dialect Spoken',
    "Father's Name",
    "Father's Occupation",
    "Mother's Name",
    "Mother's Occupation",
    'Person to be Contacted in Case of Emergency',
    'Emergency Contact Address',
    'Emergency Contact Number',
  ];

  @override
  Widget build(BuildContext context) {
    return PageShell(
      title: 'Personal Data (2 of 3)',
      step: 2,
      content: [
        sectionTitle('FAMILY & EMERGENCY CONTACT'),
        textField(draft, 'Language or Dialect Spoken'),
        gap(),
        row(
          textField(draft, "Father's Name"),
          textField(draft, "Father's Occupation"),
        ),
        gap(),
        row(
          textField(draft, "Mother's Name"),
          textField(draft, "Mother's Occupation"),
        ),
        gap(),
        sectionTitle('EMERGENCY CONTACT'),
        textField(draft, 'Person to be Contacted in Case of Emergency'),
        gap(),
        textField(draft, 'Emergency Contact Address', maxLines: 2),
        gap(),
        textField(
          draft,
          'Emergency Contact Number',
          keyboardType: TextInputType.phone,
        ),
      ],
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (!ensureFilled(context, draft, requiredLabels)) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EducationPage(draft: draft),
                    ),
                  );
                },
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SCREEN 3 - Educational Background + save
// ---------------------------------------------------------------------------

class EducationPage extends StatefulWidget {
  const EducationPage({super.key, required this.draft});

  final FormDraft draft;

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  bool saving = false;

  static const List<String> requiredLabels = [
    'Elementary School',
    'Elementary Year Graduated',
    'High School',
    'High School Year Graduated',
    'College',
    'College Year Graduated',
  ];

  Future<void> saveData() async {
    final draft = widget.draft;
    if (!ensureFilled(context, draft, requiredLabels)) return;

    setState(() => saving = true);

    try {
      await FirebaseFirestore.instance.collection('students').add({
        ...draft.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saved successfully')),
      );

      draft.clear();
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save data')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return PageShell(
      title: 'Educational Background (3 of 3)',
      step: 3,
      content: [
        sectionTitle('EDUCATIONAL BACKGROUND'),
        textField(draft, 'Elementary School'),
        gap(),
        textField(
          draft,
          'Elementary Year Graduated',
          keyboardType: TextInputType.number,
        ),
        gap(),
        textField(draft, 'High School'),
        gap(),
        textField(
          draft,
          'High School Year Graduated',
          keyboardType: TextInputType.number,
        ),
        gap(),
        textField(draft, 'College'),
        gap(),
        textField(
          draft,
          'College Year Graduated',
          keyboardType: TextInputType.number,
        ),
      ],
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: saving ? null : saveData,
                child: saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save to Firebase'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}