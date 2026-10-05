import 'package:flutter/material.dart';

import '../../../profile/domain/entities/profile_entity.dart';

/// Searches only the profiles already available in the discovery feed.
class PeopleSearch extends SearchDelegate<ProfileEntity?> {
  final List<ProfileEntity> profiles;
  PeopleSearch(this.profiles)
    : super(searchFieldLabel: 'Search people or interests');

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      tooltip: 'Clear search',
      icon: const Icon(Icons.close),
      onPressed: () => query = '',
    ),
  ];
  @override
  Widget buildLeading(BuildContext context) => IconButton(
    tooltip: 'Back',
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );
  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
  @override
  Widget buildSuggestions(BuildContext context) {
    final term = query.trim().toLowerCase();
    final results = profiles
        .where(
          (p) => [
            p.displayName,
            p.locationCity ?? '',
            ...p.interests,
          ].any((s) => s.toLowerCase().contains(term)),
        )
        .toList();
    if (results.isEmpty) {
      return const Center(
        child: Text('No matching profiles in your current feed.'),
      );
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final profile = results[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text(profile.displayName),
          subtitle: Text(
            [
              if (profile.locationCity != null) profile.locationCity!,
              ...profile.interests.take(2),
            ].join(' · '),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => close(context, profile),
        );
      },
    );
  }
}
