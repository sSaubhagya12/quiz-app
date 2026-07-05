import 'package:cloud_firestore/cloud_firestore.dart';

const String englishSubjectId = 'english';

Future<void> seedEnglishQuestions() async {
  final db = FirebaseFirestore.instance;

  // Subject details set / update
  await db.collection('subjects').doc(englishSubjectId).set({
    'name': 'English',
    'iconName': 'menu_book', // Suitable icon key
    'totalQuestions': 30,
    'completedRate': 0.0,
  }, SetOptions(merge: true));

  final questions = [
    {
      'questionText': 'She ______ her homework before her mother arrived.',
      'option1': 'has finished',
      'option2': 'had finished',
      'option3': 'finishes',
      'option4': 'finishing',
      'correctOption': 2,
      'explanation':
          'The Past Perfect tense ("had finished") is used to describe an action completed before another past action ("arrived").',
    },
    {
      'questionText': 'If I ______ you, I would accept the invitation.',
      'option1': 'am',
      'option2': 'was',
      'option3': 'were',
      'option4': 'be',
      'correctOption': 3,
      'explanation':
          'In subjunctive mood (hypothetical situations), "were" is used for all subjects including "I".',
    },
    {
      'questionText':
          'The principal, along with the teachers, ______ attending the meeting today.',
      'option1': 'is',
      'option2': 'are',
      'option3': 'were',
      'option4': 'have been',
      'correctOption': 1,
      'explanation':
          'When a singular subject ("The principal") is accompanied by "along with", the verb remains singular ("is").',
    },
    {
      'questionText': 'We have been living in this town ______ ten years.',
      'option1': 'since',
      'option2': 'for',
      'option3': 'during',
      'option4': 'until',
      'correctOption': 2,
      'explanation':
          '"For" is used to denote a duration/period of time ("ten years"), whereas "since" is used for a specific starting point.',
    },
    {
      'questionText': 'He is very good ______ playing the guitar.',
      'option1': 'in',
      'option2': 'on',
      'option3': 'at',
      'option4': 'with',
      'correctOption': 3,
      'explanation':
          'The adjective phrase "good at" is the correct idiomatic collocation for skills or abilities.',
    },
    {
      'questionText':
          'Neither Nimal ______ Kamal attended the extra class yesterday.',
      'option1': 'or',
      'option2': 'nor',
      'option3': 'and',
      'option4': 'but',
      'correctOption': 2,
      'explanation':
          'The correlative conjunction "neither" always pairs with "nor".',
    },
    {
      'questionText': 'The book ______ you lent me was very interesting.',
      'option1': 'who',
      'option2': 'whom',
      'option3': 'which',
      'option4': 'whose',
      'correctOption': 3,
      'explanation':
          'The relative pronoun "which" (or "that") is used to refer to inanimate objects ("the book").',
    },
    {
      'questionText': 'By the time we reached the station, the train ______.',
      'option1': 'left',
      'option2': 'has left',
      'option3': 'had left',
      'option4': 'leaves',
      'correctOption': 3,
      'explanation':
          'The train leaving happened before we reached, requiring the Past Perfect tense ("had left").',
    },
    {
      'questionText': "Can you please ______ the light? It's very dark here.",
      'option1': 'turn off',
      'option2': 'turn on',
      'option3': 'turn down',
      'option4': 'turn over',
      'correctOption': 2,
      'explanation':
          '"Turn on" means to start the operation of a device or light, making it suitable for dark places.',
    },
    {
      'questionText': 'She speaks English ______ than her sister.',
      'option1': 'more fluently',
      'option2': 'most fluently',
      'option3': 'fluently',
      'option4': 'as fluently',
      'correctOption': 1,
      'explanation':
          'When comparing two people, the comparative form of the adverb ("more fluently") is used.',
    },
    {
      'questionText':
          'Although it was raining heavily, ______ they went for the match.',
      'option1': 'but',
      'option2': 'so',
      'option3': 'yet',
      'option4': '(no word needed)',
      'correctOption': 4,
      'explanation':
          'In modern English, starting a clause with "Although" makes coordinating conjunctions like "but" or "so" redundant in the main clause.',
    },
    {
      'questionText': 'The heavy rain ______ the cricket match for two hours.',
      'option1': 'called off',
      'option2': 'put off',
      'option3': 'brought up',
      'option4': 'looked into',
      'correctOption': 2,
      'explanation':
          '"Put off" is a phrasal verb meaning to postpone/delay, while "called off" means cancelled.',
    },
    {
      'questionText': 'This is the ______ building in the city.',
      'option1': 'oldest',
      'option2': 'elder',
      'option3': 'older',
      'option4': 'more old',
      'correctOption': 1,
      'explanation':
          'The superlative form "oldest" is used to compare more than two entities or refer to the top extreme.',
    },
    {
      'questionText':
          'Statistics ______ a difficult subject for many students.',
      'option1': 'are',
      'option2': 'is',
      'option3': 'were',
      'option4': 'have been',
      'correctOption': 2,
      'explanation':
          'Subjects ending in "-ics" like Statistics or Physics take a singular verb ("is") when referring to the discipline.',
    },
    {
      'questionText': 'He did not pass the exam ______ he worked hard.',
      'option1': 'because',
      'option2': 'since',
      'option3': 'although',
      'option4': 'as',
      'correctOption': 3,
      'explanation':
          '"Although" is used to introduce concession or contrast (despite the fact that he worked hard).',
    },
    {
      'questionText':
          'I am looking forward to ______ my old school friends next week.',
      'option1': 'meet',
      'option2': 'meeting',
      'option3': 'met',
      'option4': 'have met',
      'correctOption': 2,
      'explanation':
          'The prepositional phrase "looking forward to" must be followed by a gerund ("meeting").',
    },
    {
      'questionText':
          'The teacher made the students ______ the entire essay again.',
      'option1': 'write',
      'option2': 'to write',
      'option3': 'writing',
      'option4': 'written',
      'correctOption': 1,
      'explanation':
          'The causative verb "make" takes a bare infinitive ("write") without "to".',
    },
    {
      'questionText':
          'You ______ bring an umbrella; it looks like it\'s going to rain.',
      'option1': 'should',
      'option2': 'would',
      'option3': 'might',
      'option4': 'could',
      'correctOption': 1,
      'explanation':
          '"Should" is used to give recommendations, advice, or suggestions.',
    },
    {
      'questionText':
          'The driver lost control of the vehicle because the brakes ______.',
      'option1': 'failed',
      'option2': 'had failed',
      'option3': 'fail',
      'option4': 'are failing',
      'correctOption': 2,
      'explanation':
          'The failure of the brakes occurred prior to losing control, so Past Perfect ("had failed") is appropriate.',
    },
    {
      'questionText': 'This beautiful picture ______ by my sister last year.',
      'option1': 'painted',
      'option2': 'was painted',
      'option3': 'is painted',
      'option4': 'has painted',
      'correctOption': 2,
      'explanation':
          'Since "last year" denotes past time, passive voice requires Simple Past tense ("was painted").',
    },
    {
      'questionText': 'He prefers tea ______ coffee in the morning.',
      'option1': 'than',
      'option2': 'to',
      'option3': 'for',
      'option4': 'against',
      'correctOption': 2,
      'explanation':
          'The verb "prefer" is followed by the preposition "to" to indicate choice.',
    },
    {
      'questionText': 'The patient is ______ weak to walk without support.',
      'option1': 'too',
      'option2': 'very',
      'option3': 'so',
      'option4': 'much',
      'correctOption': 1,
      'explanation':
          'The adverb "too" expresses excessiveness in the pattern "too + adjective + to + infinitive".',
    },
    {
      'questionText':
          'Unless you ______ hard, you will not pass the examination.',
      'option1': 'work',
      'option2': 'will work',
      'option3': 'worked',
      'option4': 'don\'t work',
      'correctOption': 1,
      'explanation':
          '"Unless" means "if not", so the clause takes a positive verb ("work") to avoid a double negative.',
    },
    {
      'questionText':
          'The news about the accident ______ shocking to everyone.',
      'option1': 'were',
      'option2': 'was',
      'option3': 'are',
      'option4': 'have been',
      'correctOption': 2,
      'explanation':
          'The noun "news" is always uncountable and takes a singular verb ("was").',
    },
    {
      'questionText': 'My uncle, ______ lives in Colombo, is a famous doctor.',
      'option1': 'which',
      'option2': 'who',
      'option3': 'whom',
      'option4': 'whose',
      'correctOption': 2,
      'explanation':
          '"Who" is the subject pronoun used to refer to a person ("My uncle").',
    },
    {
      'questionText': 'We ______ English since 2018 in this school.',
      'option1': 'are learning',
      'option2': 'have been learning',
      'option3': 'learnt',
      'option4': 'will learn',
      'correctOption': 2,
      'explanation':
          'An action starting in the past and continuing up to the present uses Present Perfect Continuous ("have been learning").',
    },
    {
      'questionText': 'The thief entered the house ______ anyone noticing him.',
      'option1': 'without',
      'option2': 'with',
      'option3': 'by',
      'option4': 'through',
      'correctOption': 1,
      'explanation':
          '"Without" is used here to indicate the absence of an action (no one noticing).',
    },
    {
      'questionText':
          '"Don\'t make a noise," the mother ______ to her children.',
      'option1': 'said',
      'option2': 'told',
      'option3': 'spoke',
      'option4': 'asked',
      'correctOption': 1,
      'explanation':
          '"Said" is used for direct speech, whereas "told" would require a direct object without "to" ("told her children").',
    },
    {
      'questionText': 'He cut the apple ______ a sharp knife.',
      'option1': 'by',
      'option2': 'with',
      'option3': 'from',
      'option4': 'in',
      'correctOption': 2,
      'explanation':
          'We use "with" to denote the instrument or tool used to perform an action.',
    },
    {
      'questionText': 'It has been raining ______ 7 o\'clock this morning.',
      'option1': 'for',
      'option2': 'since',
      'option3': 'from',
      'option4': 'during',
      'correctOption': 2,
      'explanation':
          'We use "since" to denote the specific starting point of an ongoing action.',
    },
  ];

  final subjectRef = db.collection('subjects').doc(englishSubjectId);
  for (int i = 0; i < questions.length; i++) {
    final docId = 'q${(i + 1).toString().padLeft(2, '0')}';
    await subjectRef.collection('questions').doc(docId).set(questions[i]);
    print('✅ Added: $docId');
  }
  print('🎉 English 30 questions upload complete!');
}
