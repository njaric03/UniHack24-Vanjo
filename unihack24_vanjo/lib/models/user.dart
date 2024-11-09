// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unihack24_vanjo/models/review.dart';

class SkillCycleUser {
  String? email;
  String? firstName;
  String? lastName;
  String? username;
  int credits;
  int hoursTeaching;
  double ratingAvg;
  int? avatarId;
  List<String>? learningSubjects;
  List<String>? teachingSubjects;
  List<Review>? reviews;

  SkillCycleUser({
    this.email,
    this.firstName,
    this.lastName,
    this.username,
    this.credits = 0,
    this.hoursTeaching = 0,
    this.ratingAvg = 0.0,
    this.avatarId,
    this.learningSubjects,
    this.teachingSubjects,
    this.reviews,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'credits': credits,
      'hours_teaching': hoursTeaching,
      'rating_avg': ratingAvg,
      'avatar_id': avatarId,
      'learning_subject': learningSubjects ?? [],
      'teaching_subject': teachingSubjects ?? [],
      'reviews': reviews?.map((review) => review.toMap()).toList() ?? [],
    };
  }

  static Future<List<Review>> _loadReviews(List<dynamic> references) async {
    List<Review> reviews = [];
    for (var ref in references) {
      if (ref is DocumentReference) {
        DocumentSnapshot reviewDoc = await ref.get();
        if (reviewDoc.exists) {
          reviews.add(Review.fromMap(reviewDoc.data() as Map<String, dynamic>));
        }
      }
    }
    return reviews;
  }

  static Future<SkillCycleUser> fromMap(Map<String, dynamic> map) async {
    List<String> extractReferenceIds(dynamic field) {
      if (field is List) {
        return field
            .map(
                (item) => item is DocumentReference ? item.id : item.toString())
            .toList();
      }
      return [];
    }

    List<Review>? reviews;
    if (map['reviews'] is List) {
      reviews = await _loadReviews(map['reviews']);
    }

    return SkillCycleUser(
      email: map['email'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      username: map['username'],
      credits: map['credits'] ?? 0,
      hoursTeaching: map['hours_teaching'] ?? 0,
      ratingAvg: map['rating_avg']?.toDouble() ?? 0.0,
      avatarId: map['avatar_id'],
      learningSubjects: extractReferenceIds(map['learning_subject']),
      teachingSubjects: extractReferenceIds(map['teaching_subject']),
      reviews: reviews,
    );
  }

  static Future<SkillCycleUser?> getUserById(String userID) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .get();

      if (doc.exists) {
        return await SkillCycleUser.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print('User not found');
        return null;
      }
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
}
