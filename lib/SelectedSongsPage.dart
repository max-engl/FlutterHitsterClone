import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'dart:math' as math;

class SelectedSongsPage extends StatelessWidget {
  const SelectedSongsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tracks = Logicservice().tracks ?? [];
    final playlistName = Logicservice().playlist?.name ?? 'Songs';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          playlistName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9A7BFF), Color(0xFF7A5EFF), Color(0xFF5A3EFF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: tracks.isEmpty
                  ? const Center(
                      child: Text(
                        'Keine Songs',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: tracks.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, thickness: 0.5),
                      itemBuilder: (context, index) {
                        final t = tracks[index];
                        final title = t.name;
                        final artist = (t.artists.isNotEmpty)
                            ? t.artists.first
                            : '';
                        final image = t.albumImageUrl;

                        final end = math.min(index + 8, tracks.length - 1);
                        for (int i = index + 1; i <= end; i++) {
                          final nextImage = tracks[i].albumImageUrl;
                          if (nextImage != null && nextImage.isNotEmpty) {
                            precacheImage(NetworkImage(nextImage), context);
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: (image != null && image.isNotEmpty)
                                    ? Image.network(
                                        image,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        gaplessPlayback: true,
                                      )
                                    : Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        color: const Color(0xFFE5E7EB),
                                        child: Text(
                                          (title.isNotEmpty ? title[0] : '?')
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      artist,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
