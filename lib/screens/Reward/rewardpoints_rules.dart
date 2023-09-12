import 'package:flutter/material.dart';

class RewardPointRulesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 25,
            ),
            SizedBox(
              width: 5,
            ),
            Text('Reward Point Schemes'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shadowColor: Colors.deepOrangeAccent,
              color: Colors.white54,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.card_giftcard_outlined,
                          size: 25,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Reward Point Earning Criteria',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    BulletPoint(
                        text:
                            'Earn 20 Reward points for first Food purchase from any Restaurant.'),
                    BulletPoint(
                        text:
                            'Earn 10 Reward points for every Rs.1000 or less than Rs.1000 worth food purchasing from any Restaurant.'),
                    BulletPoint(
                        text:
                            'Earn 20 Reward points for every more than Rs.1000 or less than Rs.4000 worth food purchase from any Restaurant.'),
                    BulletPoint(
                        text:
                            'Earn 50 Reward points for every more than Rs.4000 worth food purchase from any Restaurant.'),

                    BulletPoint(
                        text:
                            'Refer a friend and earn 50 Reward points of each for first food purchase.'),
                    // Add more bullet points for earning criteria
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              shadowColor: Colors.deepOrangeAccent,
              color: Colors.white54,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.card_giftcard_outlined,
                          size: 25,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Reward Point Redeeming Criteria',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    BulletPoint(
                        text:
                            'Redeem 200 points for a free chicken cheese pizza coupon worth Rs.500.'),
                    BulletPoint(
                        text:
                            'Redeem 400 points for a free crunchy fried chicken coupon worth Rs.1100.'),
                    BulletPoint(
                        text:
                            'Redeem 800 points for a free meal coupon worth Rs.2500 for couple.'),
                    BulletPoint(
                        text:
                            'Redeem 1600 points for a free birthday food(including cake) coupon worth Rs.5500 for 5 people.'),

                    // Add more bullet points for redeeming criteria
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 8,
            height: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
