class SkillCycleUser {
  String? uid;
  String? email;
  String? name;
  List<String>? skills;
  List<String>? needs;
  int credits;

  SkillCycleUser({
    this.uid,
    this.email,
    this.name,
    this.skills,
    this.needs,
    this.credits = 0,
  });

  // Convert SkillCycleUser object to a Map (for Firebase Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'skills': skills ?? [],
      'needs': needs ?? [],
      'credits': credits,
    };
  }

  // Create a SkillCycleUser object from a Map (for Firestore retrieval)
  factory SkillCycleUser.fromMap(Map<String, dynamic> map) {
    return SkillCycleUser(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      skills: List<String>.from(map['skills'] ?? []),
      needs: List<String>.from(map['needs'] ?? []),
      credits: map['credits'] ?? 0,
    );
  }
}
