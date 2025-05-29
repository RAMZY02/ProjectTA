import 'package:flutter/material.dart';

class SegmentedProgressBar extends StatelessWidget {
  final Map<String, double> segments;
  final double height;
  final BorderRadius? borderRadius;
  final bool showPercentage;

  const SegmentedProgressBar({
    super.key,
    required this.segments,
    this.height = 24,
    this.borderRadius,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final total = segments.values.fold(0.0, (sum, value) => sum + value);
    if (total == 0) return const SizedBox();

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final segmentWidths = segments.map((key, value) =>
                MapEntry(key, constraints.maxWidth * (value / total)));

            return Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
                color: Colors.grey[200],
              ),
              child: Stack(
                children: [
                  // Background segments
                  Row(
                    children: segments.entries.map((entry) {
                      final width = segmentWidths[entry.key]!;
                      return _buildSegmentBackground(width, entry.key);
                    }).toList(),
                  ),
                  // Percentage texts centered in each segment
                  Positioned.fill(
                    child: Row(
                      children: segmentWidths.entries.map((entry) {
                        final width = entry.value;
                        final percentage = (segments[entry.key]! / total * 100);
                        return SizedBox(
                          width: width,
                          child: Center(
                            child: _buildPercentageText(
                              entry.key,
                              percentage,
                              width > 30, // Only show if segment is wide enough
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (showPercentage)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildPercentageLabels(segments, total),
          ),
      ],
    );
  }

  Widget _buildSegmentBackground(double width, String type) {
    if (width <= 0) return const SizedBox();

    Color color;
    switch (type) {
      case 'Pilihan Ganda':
        color = Colors.blue;
        break;
      case 'Isian':
        color = Colors.orange;
        break;
      case 'Upload File':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.horizontal(
          left: type == 'Pilihan Ganda'
              ? const Radius.circular(12)
              : Radius.zero,
          right: type == 'Upload File'
              ? const Radius.circular(12)
              : Radius.zero,
        ),
      ),
    );
  }

  Widget _buildPercentageText(String type, double percentage, bool showText) {
    if (!showText) return const SizedBox();

    return Text(
      '${percentage.toStringAsFixed(1)}%',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 2,
            color: Colors.black,
          )
        ],
      ),
    );
  }

  Widget _buildPercentageLabels(Map<String, double> segments, double total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: segments.entries.map((entry) {
        final percentage = (entry.value / total * 100);
        return _buildPercentageLabel(entry.key, percentage);
      }).toList(),
    );
  }

  Widget _buildPercentageLabel(String type, double percentage) {
    Color color;
    switch (type) {
      case 'Pilihan Ganda':
        color = Colors.blue;
        break;
      case 'Isian':
        color = Colors.orange;
        break;
      case 'Upload File':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              type,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}