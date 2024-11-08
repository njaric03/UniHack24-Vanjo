import 'package:flutter/material.dart';
import 'package:unihack24_vanjo/models/user.dart';

import '../../models/review.dart';

class ProfileScreen extends StatelessWidget {
  final SkillCycleUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildProfileField('Email', user.email),
            _buildProfileField('First Name', user.firstName),
            _buildProfileField('Last Name', user.lastName),
            _buildProfileField('Username', user.username),
            _buildProfileField('Credits', user.credits.toString()),
            _buildProfileField('Hours Teaching', user.hoursTeaching.toString()),
            _buildProfileField(
                'Rating Average', user.ratingAvg.toStringAsFixed(1)),
            _buildProfileField(
                'Learning Subjects', user.learningSubjects?.join(', ')),
            _buildProfileField(
                'Teaching Subjects', user.teachingSubjects?.join(', ')),
            _buildReviewsField('Reviews', user.reviews),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to the profile modification screen
              },
              child: Text('Modify Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsField(String label, List<Review>? reviews) {
    if (reviews == null || reviews.isEmpty) {
      return _buildProfileField(label, 'No reviews');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...reviews.map((review) => _buildReview(review)),
        ],
      ),
    );
  }

  Widget _buildReview(Review review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          _buildRatingStars(review.rating ?? 0),
          SizedBox(width: 8),
          Expanded(child: Text(review.text ?? 'No review text')),
        ],
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    int fullStars = rating.floor(); // Full stars to display
    bool hasHalfStar = (rating - fullStars) >= 0.5; // Check for a half star

    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: Colors.amber);
        } else if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half, color: Colors.amber);
        } else {
          return Icon(Icons.star_border, color: Colors.amber);
        }
      }),
    );
  }
}
