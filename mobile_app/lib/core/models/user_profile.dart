class UserProfile {
  final String name;
  final String location;
  final String avatarUrl;
  final int reliabilityScore;
  final List<String> tags;

  UserProfile({
    required this.name,
    required this.location,
    required this.avatarUrl,
    required this.reliabilityScore,
    required this.tags,
  });
}
