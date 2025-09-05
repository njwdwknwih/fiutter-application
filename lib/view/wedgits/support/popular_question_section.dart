import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/wedgits/support/question_card.dart';
import 'package:flutter/material.dart';

class PopularQuestionSection extends StatelessWidget {
  const PopularQuestionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Questions',
            style: AppTextStyle.withColor(
              AppTextStyle.h3,
              Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          const SizedBox(height: 16,),
          QuestionCard(
            title: 'How to track my order?',
            icon: Icons.local_shipping_outlined,
          ),
          const SizedBox(height: 12,),
           QuestionCard(
            title: 'How to return an item?',
            icon: Icons.assignment_return_outlined,
          ),
        ],
      ),
      );
  }
}