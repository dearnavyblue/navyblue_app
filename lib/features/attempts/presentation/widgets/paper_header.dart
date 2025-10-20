import 'package:flutter/material.dart';
import 'package:navyblue_app/core/theme/app_theme.dart';
import 'paper_header_data.dart';

class PaperHeader extends StatelessWidget {
  final PaperHeaderData data;
  final int pageNumber;
  
  const PaperHeader({super.key, required this.data, required this.pageNumber});

  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txt = theme.extension<AppTextStyles>()!;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Left & Right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      data.leftTitle,
                      style:  txt.extraExtraSmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        data.rightTitle,
                        style:  txt.extraExtraSmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),

              // Center page number + grade
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$pageNumber',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (data.centerSubtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      data.centerSubtitle!,
                      style:  txt.extraExtraSmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
