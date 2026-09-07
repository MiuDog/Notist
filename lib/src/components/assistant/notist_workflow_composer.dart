/// Notist 專案模組。
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kallopis/kallopis_foundation.dart';

/// 由產品提供的附件呈現資料；Kallopis 不擁有附件內容。
@immutable
class NotistAttachmentData {
  const NotistAttachmentData({
    required this.id,
    required this.label,
    this.detail,
  });

  final String id;
  final String label;
  final String? detail;
}

/// 顯示並移除目前提示範圍內的附件。
class NotistAttachmentTray extends StatelessWidget {
  const NotistAttachmentTray({
    super.key,
    required this.attachments,
    required this.removeLabel,
    this.onRemove,
  });

  final List<NotistAttachmentData> attachments;
  final String removeLabel;
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: context.klp.space.actionGap,
    runSpacing: context.klp.space.tight,
    children: [
      for (final attachment in attachments)
        Semantics(
          label: [
            attachment.label,
            attachment.detail,
            if (onRemove != null) removeLabel,
          ].whereType<String>().join(', '),
          child: KlpTag(
            label: attachment.label,
            prefix: attachment.detail,
            onRemove: onRemove == null ? null : () => onRemove!(attachment.id),
          ),
        ),
    ],
  );
}

/// 提示範例只回填草稿，不代表提交或產品預設值。
class NotistPromptExamples extends StatelessWidget {
  const NotistPromptExamples({
    super.key,
    required this.examples,
    required this.onSelected,
  });

  final List<String> examples;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: context.klp.space.tight,
    runSpacing: context.klp.space.tight,
    children: [
      for (final example in examples)
        KlpButton(
          label: example,
          tone: KlpButtonTone.dashed,
          compact: true,
          onPressed: () => onSelected(example),
        ),
    ],
  );
}

/// 多行提示欄位；Enter 提交，Shift+Enter 保留給換行。
class NotistPromptTextField extends StatelessWidget {
  const NotistPromptTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.onChanged,
    this.onSubmit,
    this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String placeholder;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.enter): () {
        if (onSubmit != null) onSubmit!();
      },
    },
    child: TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      minLines: null,
      maxLines: null,
      onChanged: onChanged,
      decoration: InputDecoration(hintText: placeholder),
    ),
  );
}

/// 對話輸入器的產品中立組合；草稿與附件的權威狀態由呼叫端保存。
class NotistWorkflowComposer extends StatelessWidget {
  const NotistWorkflowComposer({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.sendLabel,
    required this.attachLabel,
    required this.removeAttachmentLabel,
    required this.onChanged,
    this.onSend,
    this.onAttach,
    this.attachments = const [],
    this.examples = const [],
    this.onRemoveAttachment,
    this.onExampleSelected,
  });

  final TextEditingController controller;
  final String placeholder;
  final String sendLabel;
  final String attachLabel;
  final String removeAttachmentLabel;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSend;
  final VoidCallback? onAttach;
  final List<NotistAttachmentData> attachments;
  final List<String> examples;
  final ValueChanged<String>? onRemoveAttachment;
  final ValueChanged<String>? onExampleSelected;

  @override
  Widget build(BuildContext context) => KlpSurface(
    tone: KlpSurfaceTone.muted,
    padding: EdgeInsets.all(context.klp.space.base),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (attachments.isNotEmpty) ...[
          NotistAttachmentTray(
            attachments: attachments,
            removeLabel: removeAttachmentLabel,
            onRemove: onRemoveAttachment,
          ),
          SizedBox(height: context.klp.space.contentStackGap),
        ],
        NotistPromptTextField(
          controller: controller,
          placeholder: placeholder,
          onChanged: onChanged,
          onSubmit: onSend,
        ),
        if (examples.isNotEmpty && onExampleSelected != null) ...[
          SizedBox(height: context.klp.space.contentStackGap),
          NotistPromptExamples(
            examples: examples,
            onSelected: onExampleSelected!,
          ),
        ],
        SizedBox(height: context.klp.space.contentStackGap),
        Row(
          children: [
            KlpIconButton(
              icon: KlpIcons.folderPlus,
              label: attachLabel,
              onPressed: onAttach,
            ),
            const Spacer(),
            KlpButton(label: sendLabel, compact: true, onPressed: onSend),
          ],
        ),
      ],
    ),
  );
}
