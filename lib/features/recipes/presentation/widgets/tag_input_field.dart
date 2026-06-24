import 'package:flutter/material.dart';

class TagInputField extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  const TagInputField({
    super.key,
    required this.tags,
    required this.onChanged,
  });

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final _controller = TextEditingController();

  void _addTag() {
    final tag = _controller.text.trim();
    if (tag.isEmpty || widget.tags.contains(tag)) return;
    widget.onChanged([...widget.tags, tag]);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Add tag',
                  hintText: 'e.g., breakfast, quick, healthy',
                  isDense: true,
                ),
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addTag,
              icon: const Icon(Icons.add_circle),
            ),
          ],
        ),
        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.tags
                .map((tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      onDeleted: () => widget.onChanged(
                          widget.tags.where((t) => t != tag).toList()),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}
