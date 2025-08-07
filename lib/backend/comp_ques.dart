final Map<String, Map<String, List<Map<String, dynamic>>>> compQuestions = {
  'Computer Science': {
  'Flutter': [
    {
      'question': 'What is the role of the build() method in Flutter?',
      'options': ['Create backend', 'Construct the widget tree', 'Trigger setState', 'Manage dependencies'],
      'answer': 'Construct the widget tree',
    },
    {
      'question': 'Which widget handles dynamic lists in Flutter?',
      'options': ['Column', 'ListView.builder', 'Row', 'Text'],
      'answer': 'ListView.builder',
    },
    {
      'question': 'Which widget provides internal state management?',
      'options': ['StatelessWidget', 'TextField', 'StatefulWidget', 'MaterialApp'],
      'answer': 'StatefulWidget',
    },
  ],
  'Java': [
    {
      'question': 'What is the purpose of the "final" keyword in Java?',
      'options': ['Loop control', 'Inheritance', 'Define constant values', 'Runtime error handling'],
      'answer': 'Define constant values',
    },
    {
      'question': 'Which concept allows multiple forms in Java?',
      'options': ['Encapsulation', 'Polymorphism', 'Abstraction', 'Inheritance'],
      'answer': 'Polymorphism',
    },
    {
      'question': 'What does JVM stand for?',
      'options': ['Java Virtual Machine', 'Java Vendor Mode', 'Just Virtual Mode', 'Java Visual Method'],
      'answer': 'Java Virtual Machine',
    },
  ],
  'Machine Learning': [
    {
      'question': 'What is overfitting in machine learning?',
      'options': ['Model performs poorly', 'Model memorizes training data', 'Model doesn’t learn', 'Model uses wrong algorithm'],
      'answer': 'Model memorizes training data',
    },
    {
      'question': 'Which of these is a supervised learning algorithm?',
      'options': ['K-Means', 'Linear Regression', 'Apriori', 'PCA'],
      'answer': 'Linear Regression',
    },
    {
      'question': 'What is the purpose of a loss function?',
      'options': ['Measure model accuracy', 'Measure prediction error', 'Save the model', 'Clean the data'],
      'answer': 'Measure prediction error',
    },
  ],
  'Backend': [
    {
      'question': 'What does an API do?',
      'options': ['Handles UI', 'Connects frontend with backend', 'Manages memory', 'Stores videos'],
      'answer': 'Connects frontend with backend',
    },
    {
      'question': 'What is REST in web development?',
      'options': ['Request Service Type', 'A UI framework', 'Architectural style for APIs', 'Security tool'],
      'answer': 'Architectural style for APIs',
    },
    {
      'question': 'Which HTTP method is used to update a resource?',
      'options': ['GET', 'POST', 'PUT', 'DELETE'],
      'answer': 'PUT',
    },
  ],
  'React JS': [
    {
      'question': 'What is the role of useState in React?',
      'options': ['Manage database', 'Handle side effects', 'Manage local component state', 'Render routing'],
      'answer': 'Manage local component state',
    },
    {
      'question': 'JSX stands for?',
      'options': ['JavaScript XML', 'Java Standard eXtension', 'Java Syntax Exchange', 'JavaScript Exchange'],
      'answer': 'JavaScript XML',
    },
    {
      'question': 'What is a component in React?',
      'options': ['A class', 'A function or class returning UI', 'An object', 'A database'],
      'answer': 'A function or class returning UI',
    },
  ],
  'JavaScript': [
    {
      'question': 'What does "this" refer to in a method inside an object?',
      'options': ['Window', 'Current object', 'Function', 'Global context'],
      'answer': 'Current object',
    },
    {
      'question': 'Which is not a JavaScript data type?',
      'options': ['Boolean', 'Undefined', 'Float', 'Symbol'],
      'answer': 'Float',
    },
    {
      'question': 'What is a promise in JavaScript?',
      'options': ['Loop statement', 'Callback replacement for async code', 'Global variable', 'Array function'],
      'answer': 'Callback replacement for async code',
    },
  ],
  'C++': [
    {
      'question': 'What is a class in C++?',
      'options': ['Function', 'Template for creating objects', 'Variable', 'Pointer'],
      'answer': 'Template for creating objects',
    },
    {
      'question': 'Which operator is used to access members of a class?',
      'options': ['->', '&', '*', '%'],
      'answer': '->',
    },
    {
      'question': 'What is the purpose of a constructor?',
      'options': ['Destroy object', 'Allocate memory', 'Initialize object', 'Overload function'],
      'answer': 'Initialize object',
    },
  ],
  'Game dev': [
    {
      'question': 'Which engine is commonly used for game development?',
      'options': ['React', 'TensorFlow', 'Unity', 'Firebase'],
      'answer': 'Unity',
    },
    {
      'question': 'FPS in games stands for?',
      'options': ['Fast Pixel Speed', 'Frames Per Second', 'Full Pixel Shot', 'File Process Sync'],
      'answer': 'Frames Per Second',
    },
    {
      'question': 'Which language is commonly used in Unity?',
      'options': ['Python', 'C#', 'Ruby', 'Go'],
      'answer': 'C#',
    },
  ],
  'Python': [
    {
      'question': 'What is a lambda function in Python?',
      'options': ['Named function', 'Short anonymous function', 'Class', 'Package'],
      'answer': 'Short anonymous function',
    },
    {
      'question': 'What does the "len()" function do?',
      'options': ['Length of list or string', 'Create a list', 'Open a file', 'Close a loop'],
      'answer': 'Length of list or string',
    },
    {
      'question': 'Which library is used for data manipulation?',
      'options': ['Django', 'NumPy', 'Pandas', 'PyGame'],
      'answer': 'Pandas',
    },
  ],
  'Databases': [
    {
      'question': 'Which language is used to interact with relational databases?',
      'options': ['HTML', 'Python', 'SQL', 'JS'],
      'answer': 'SQL',
    },
    {
      'question': 'Which SQL command is used to retrieve data?',
      'options': ['UPDATE', 'INSERT', 'DELETE', 'SELECT'],
      'answer': 'SELECT',
    },
    {
      'question': 'What is a primary key?',
      'options': ['A foreign table', 'A unique identifier for a record', 'A column with nulls', 'An index'],
      'answer': 'A unique identifier for a record',
    },
  ],
},
};