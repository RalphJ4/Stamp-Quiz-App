import '../models/question_model.dart';

class LocalQuestionDataSource {
  Future<List<QuestionModel>> getLocalQuestions() async {
    final raw = [
      // === SPACE ===
      {
        'id': 'sp1',
        'question': "Which planet is known as the 'Red Planet'?",
        'options': ['Mercury', 'Venus', 'Mars', 'Jupiter'],
        'correctIndex': 2,
        'category': 'space',
        'difficulty': 'easy',
      },
      {
        'id': 'sp2',
        'question': 'What is the name of the galaxy that contains our Solar System?',
        'options': ['The Andromeda Galaxy', 'The Milky Way Galaxy', 'The Whirlpool Galaxy', 'The Black Eye Galaxy'],
        'correctIndex': 1,
        'category': 'space',
        'difficulty': 'easy',
      },
      {
        'id': 'sp3',
        'question': 'Which celestial body is known as Earth\'s natural satellite?',
        'options': ['The Sun', 'The Moon', 'Mars', 'Venus'],
        'correctIndex': 1,
        'category': 'space',
        'difficulty': 'easy',
      },
      {
        'id': 'sp4',
        'question': 'What is a supernova?',
        'options': ['A collision of two stars', 'A black hole eating a star', 'The explosion of a star', 'A new star being born'],
        'correctIndex': 2,
        'category': 'space',
        'difficulty': 'medium',
      },
      {
        'id': 'sp5',
        'question': 'Who was the first woman to travel into space?',
        'options': ['Sally Ride', 'Valentina Tereshkova', 'Mae Jemison', 'Kalpana Chawla'],
        'correctIndex': 1,
        'category': 'space',
        'difficulty': 'medium',
      },
      {
        'id': 'sp6',
        'question': 'What is the largest planet in our solar system?',
        'options': ['Saturn', 'Neptune', 'Jupiter', 'Uranus'],
        'correctIndex': 2,
        'category': 'space',
        'difficulty': 'easy',
      },
      {
        'id': 'sp7',
        'question': 'What is a black hole?',
        'options': [
          'A hole in space',
          'A region of spacetime with immense gravity',
          'A dark star',
          'An empty void between planets',
        ],
        'correctIndex': 1,
        'category': 'space',
        'difficulty': 'medium',
      },
      {
        'id': 'sp8',
        'question': 'Which planet has the Great Red Spot?',
        'options': ['Mars', 'Saturn', 'Jupiter', 'Neptune'],
        'correctIndex': 2,
        'category': 'space',
        'difficulty': 'hard',
      },

      // === ANIMALS ===
      {
        'id': 'an1',
        'question': 'Which animal is known as the King of the Jungle?',
        'options': ['Tiger', 'Lion', 'Elephant', 'Gorilla'],
        'correctIndex': 1,
        'category': 'animals',
        'difficulty': 'easy',
      },
      {
        'id': 'an2',
        'question': 'What is the fastest land animal?',
        'options': ['Lion', 'Cheetah', 'Peregrine Falcon', 'Horse'],
        'correctIndex': 1,
        'category': 'animals',
        'difficulty': 'easy',
      },
      {
        'id': 'an3',
        'question': 'Which mammal can truly fly?',
        'options': ['Flying Squirrel', 'Bat', 'Flying Fox', 'Sugar Glider'],
        'correctIndex': 1,
        'category': 'animals',
        'difficulty': 'easy',
      },
      {
        'id': 'an4',
        'question': 'What is the largest mammal in the world?',
        'options': ['African Elephant', 'Blue Whale', 'Giraffe', 'Hippopotamus'],
        'correctIndex': 1,
        'category': 'animals',
        'difficulty': 'medium',
      },
      {
        'id': 'an5',
        'question': 'Which animal has the longest lifespan?',
        'options': ['Elephant', 'Giant Tortoise', 'Bowhead Whale', 'Macaw'],
        'correctIndex': 2,
        'category': 'animals',
        'difficulty': 'hard',
      },
      {
        'id': 'an6',
        'question': 'What is a group of lions called?',
        'options': ['A pack', 'A herd', 'A pride', 'A flock'],
        'correctIndex': 2,
        'category': 'animals',
        'difficulty': 'medium',
      },

      // === HISTORY ===
      {
        'id': 'hi1',
        'question': 'In which year did World War II end?',
        'options': ['1943', '1944', '1945', '1946'],
        'correctIndex': 2,
        'category': 'history',
        'difficulty': 'easy',
      },
      {
        'id': 'hi2',
        'question': 'Who was the first President of the United States?',
        'options': ['Thomas Jefferson', 'George Washington', 'Abraham Lincoln', 'John Adams'],
        'correctIndex': 1,
        'category': 'history',
        'difficulty': 'easy',
      },
      {
        'id': 'hi3',
        'question': 'The Colosseum is located in which city?',
        'options': ['Athens', 'Rome', 'Paris', 'Istanbul'],
        'correctIndex': 1,
        'category': 'history',
        'difficulty': 'easy',
      },
      {
        'id': 'hi4',
        'question': 'Who discovered America in 1492?',
        'options': ['Vasco da Gama', 'Ferdinand Magellan', 'Christopher Columbus', 'Amerigo Vespucci'],
        'correctIndex': 2,
        'category': 'history',
        'difficulty': 'medium',
      },
      {
        'id': 'hi5',
        'question': 'What ancient civilization built Machu Picchu?',
        'options': ['Inca', 'Maya', 'Aztec', 'Olmec'],
        'correctIndex': 0,
        'category': 'history',
        'difficulty': 'hard',
      },
      {
        'id': 'hi6',
        'question': 'Who was the first woman to fly solo across the Atlantic Ocean?',
        'options': ['Amelia Earhart', 'Harriet Quimby', 'Bessie Coleman', 'Jacqueline Cochran'],
        'correctIndex': 0,
        'category': 'history',
        'difficulty': 'medium',
      },

      // === SCIENCE ===
      {
        'id': 'sc1',
        'question': 'What is the chemical symbol for water?',
        'options': ['H2O', 'CO2', 'NaCl', 'O2'],
        'correctIndex': 0,
        'category': 'science',
        'difficulty': 'easy',
      },
      {
        'id': 'sc2',
        'question': 'What gas do plants absorb from the atmosphere?',
        'options': ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'],
        'correctIndex': 2,
        'category': 'science',
        'difficulty': 'easy',
      },
      {
        'id': 'sc3',
        'question': 'What is the hardest natural substance on Earth?',
        'options': ['Gold', 'Iron', 'Diamond', 'Platinum'],
        'correctIndex': 2,
        'category': 'science',
        'difficulty': 'easy',
      },
      {
        'id': 'sc4',
        'question': 'What part of the cell contains genetic material?',
        'options': ['Cell membrane', 'Cytoplasm', 'Nucleus', 'Ribosome'],
        'correctIndex': 2,
        'category': 'science',
        'difficulty': 'medium',
      },
      {
        'id': 'sc5',
        'question': 'What is the SI unit of force?',
        'options': ['Joule', 'Newton', 'Watt', 'Pascal'],
        'correctIndex': 1,
        'category': 'science',
        'difficulty': 'hard',
      },
      {
        'id': 'sc6',
        'question': 'Which vitamin is produced when skin is exposed to sunlight?',
        'options': ['Vitamin A', 'Vitamin B', 'Vitamin C', 'Vitamin D'],
        'correctIndex': 3,
        'category': 'science',
        'difficulty': 'medium',
      },

      // === GEOGRAPHY ===
      {
        'id': 'ge1',
        'question': 'What is the largest continent by area?',
        'options': ['Africa', 'North America', 'Asia', 'Europe'],
        'correctIndex': 2,
        'category': 'geography',
        'difficulty': 'easy',
      },
      {
        'id': 'ge2',
        'question': 'Which river is the longest in the world?',
        'options': ['Amazon', 'Nile', 'Mississippi', 'Yangtze'],
        'correctIndex': 1,
        'category': 'geography',
        'difficulty': 'easy',
      },
      {
        'id': 'ge3',
        'question': 'What is the capital of Japan?',
        'options': ['Seoul', 'Beijing', 'Bangkok', 'Tokyo'],
        'correctIndex': 3,
        'category': 'geography',
        'difficulty': 'easy',
      },
      {
        'id': 'ge4',
        'question': 'Which country has the largest population?',
        'options': ['India', 'United States', 'China', 'Indonesia'],
        'correctIndex': 0,
        'category': 'geography',
        'difficulty': 'medium',
      },
      {
        'id': 'ge5',
        'question': 'What is the smallest country in the world?',
        'options': ['Monaco', 'Vatican City', 'San Marino', 'Liechtenstein'],
        'correctIndex': 1,
        'category': 'geography',
        'difficulty': 'medium',
      },
      {
        'id': 'ge6',
        'question': 'Which desert is the largest non-polar desert in the world?',
        'options': ['Gobi Desert', 'Sahara Desert', 'Arabian Desert', 'Kalahari Desert'],
        'correctIndex': 1,
        'category': 'geography',
        'difficulty': 'hard',
      },
    ];

    await Future.delayed(const Duration(milliseconds: 200));
    final questions = raw.map((m) => QuestionModel.fromMap(m)).toList();
    questions.shuffle();
    for (var i = 0; i < questions.length; i++) {
      final q = questions[i];
      final shuffledOptions = List<String>.from(q.options)..shuffle();
      final correctOption = q.options[q.correctIndex];
      final newCorrectIndex = shuffledOptions.indexOf(correctOption);
      questions[i] = QuestionModel(
        id: q.id,
        question: q.question,
        options: shuffledOptions,
        correctIndex: newCorrectIndex,
        category: q.category,
        difficulty: q.difficulty,
      );
    }
    return questions;
  }
}
