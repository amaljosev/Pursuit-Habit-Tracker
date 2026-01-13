import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void _showSearchDialog() {
      showSearch(
        context: context,
        delegate: FAQSearchDelegate(faqs: faqs),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FAQ',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => _showSearchDialog(),
            icon: Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return FAQExpansionTile(faq: faqs[index]);
        },
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final IconData icon;

  FAQItem({required this.question, required this.answer, required this.icon});
}

class FAQExpansionTile extends StatefulWidget {
  final FAQItem faq;

  const FAQExpansionTile({super.key, required this.faq});

  @override
  State<FAQExpansionTile> createState() => _FAQExpansionTileState();
}

class _FAQExpansionTileState extends State<FAQExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white10
          : null,
      elevation: 1,
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Icon(widget.faq.icon, color: Theme.of(context).primaryColor),
          title: Text(
            widget.faq.question,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Theme.of(context).primaryColor,
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(
                widget.faq.answer,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQSearchDelegate extends SearchDelegate<String> {
  final List<FAQItem> faqs;

  FAQSearchDelegate({required this.faqs});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<FAQItem> results = faqs
        .where(
          (faq) =>
              faq.question.toLowerCase().contains(query.toLowerCase()) ||
              faq.answer.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(results[index].icon),
          title: Text(results[index].question),
          subtitle: Text(
            results[index].answer,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(results[index].question),
                content: Text(results[index].answer),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<FAQItem> suggestions = faqs
        .where(
          (faq) => faq.question.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(suggestions[index].icon),
          title: Text(suggestions[index].question),
          onTap: () {
            query = suggestions[index].question;
            showResults(context);
          },
        );
      },
    );
  }
}

final List<FAQItem> faqs = [
  FAQItem(
    question: "What are 'Goals' in this app?",
    answer:
        "In our app, we use the term 'Goals' instead of 'Habits'. A Goal represents a daily target you want to achieve, like drinking water, exercising, or reading.",
    icon: Icons.flag,
  ),
  FAQItem(
    question: "How do I create a new Goal?",
    answer:
        "Tap the + icon on the home screen to create a new Goal. You'll be able to set the Goal name, target value, and other preferences.",
    icon: Icons.add_circle,
  ),
  FAQItem(
    question: "What is 'Goal Value'?",
    answer:
        "Goal Value is the target count you need to complete for a Goal each day. For example: 8 glasses of water, 30 minutes of exercise, or 10 pages of reading.",
    icon: Icons.track_changes,
  ),
  FAQItem(
    question: "How do I track my progress?",
    answer:
        "You can see your progress in two ways:\n1. On the home screen - each Goal tile shows completion status\n2. On the Goal Detail screen - tap any Goal to see detailed progress charts and history",
    icon: Icons.timeline,
  ),
  FAQItem(
    question: "How do I complete a Goal for today?",
    answer:
        "You have two options:\n1. On home screen - swipe the Goal tile left to mark as complete\n2. On Goal Detail screen - use the Add button to manually increment progress",
    icon: Icons.check_circle,
  ),
  FAQItem(
    question: "How do I change a Goal's theme or settings?",
    answer:
        "Navigate to the Goal Detail screen by tapping on the Goal, then tap the Edit icon (pencil) to modify the theme, target value, or other settings.",
    icon: Icons.palette,
  ),
  FAQItem(
    question: "What does 'Reset Habit' do?",
    answer:
        "Reset does NOT delete your progress history. It only resets today's completion status so you can track a new day. Your historical data remains intact.",
    icon: Icons.restart_alt,
  ),
  FAQItem(
    question: "How do I add manual values to complete a Goal?",
    answer:
        "Go to the Goal Detail screen and tap the 'Add' button. This lets you increment your progress manually, useful for tracking partial completion.",
    icon: Icons.exposure_plus_1,
  ),
  FAQItem(
    question: "Can I see my long-term progress?",
    answer:
        "Yes! Each Goal Detail screen includes progress charts showing your completion history over days, weeks, and months.",
    icon: Icons.insights,
  ),
];
