import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ChatHomeScreen extends StatelessWidget {
  const ChatHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        elevation: 0,
        title: const Text('9:41',
            style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.blue,
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Messages',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_square,
                      color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        _buildStoryNewGroup(),
                        const SizedBox(width: 12),
                        _buildStoryItem('Family', 'F', AppColors.blue, true),
                        const SizedBox(width: 12),
                        _buildStoryItem('Sarah', 'SC', AppColors.purple, true),
                        const SizedBox(width: 12),
                        _buildStoryItem('James', 'JC', AppColors.orange, false),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.g200),
                  _buildChatItem(
                      'Family Group',
                      'James: Can someone pick up milk?',
                      '10:42 AM',
                      'F',
                      AppColors.blue,
                      3,
                      true), // Replace navigation with dummy for now
                  _buildChatItem('Sarah', 'I will be home in 10 mins',
                      '9:15 AM', 'SC', AppColors.purple, 0, false),
                  _buildChatItem(
                      'Famory AI Assistant',
                      'I found 3 recipes for dinner tonight.',
                      'Yesterday',
                      'AI',
                      AppColors.teal,
                      1,
                      false),
                  _buildChatItem('James', 'Don\'t forget the tickets!',
                      'Yesterday', 'JC', AppColors.orange, 0, false),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStoryNewGroup() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.g100,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: AppColors.g300,
                width: 2,
                style: BorderStyle
                    .none), // Simulated dashed via transparent for now
          ),
          child: const Icon(Icons.add, color: AppColors.g400),
        ),
        const SizedBox(height: 6),
        const Text('New Group',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.g500)),
      ],
    );
  }

  Widget _buildStoryItem(
      String name, String initials, Color color, bool hasUnread) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: hasUnread ? AppColors.blue : Colors.transparent,
                width: 2),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
                child: Text(initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700))),
          ),
        ),
        const SizedBox(height: 6),
        Text(name,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.g800)),
      ],
    );
  }

  Widget _buildChatItem(String name, String lastMessage, String time,
      String initials, Color color, int unreadCount, bool isGroup) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(isGroup ? 16 : 26),
              ),
              child: Center(
                  child: Text(initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.g800)),
                      Text(time,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: unreadCount > 0
                                  ? AppColors.blue
                                  : AppColors.g400)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: TextStyle(
                              fontSize: 13,
                              color: unreadCount > 0
                                  ? AppColors.g800
                                  : AppColors.g500,
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: AppColors.blue,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(unreadCount.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
