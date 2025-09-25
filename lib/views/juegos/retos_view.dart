import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/back_fab.dart';

class RetosView extends StatefulWidget {
  const RetosView({super.key});

  @override
  State<RetosView> createState() => _RetosViewState();
}

class _RetosViewState extends State<RetosView> {
  String _selectedGame = 'trivia';
  int _triviaIndex = 0;
  int? _selected;
  int _score = 0;
  List<_MemoryCard> _memoryCards = [];
  List<int> _flippedCards = [];
  int? _firstFlipped;
  int? _secondFlipped;
  
  // Variables para el juego de palabras
  List<_WordPuzzle> _wordPuzzles = [];
  int _currentWordIndex = 0;
  List<String> _userInput = [];
  
  // Variables para el rompecabezas
  List<_PuzzlePiece> _puzzlePieces = [];
  List<int> _puzzleOrder = [];
  bool _puzzleCompleted = false;
  
  final List<_Pregunta> _preguntas = [
    _Pregunta(
      enunciado: '¿Cuál es la capital de Nicaragua?',
      opciones: ['Managua', 'León', 'Granada', 'Masaya'],
      correcta: 0,
      categoria: 'Geografía'
    ),
    _Pregunta(
      enunciado: '¿En qué año se independizó Nicaragua?',
      opciones: ['1821', '1838', '1856', '1893'],
      correcta: 0,
      categoria: 'Historia'
    ),
    _Pregunta(
      enunciado: '¿Cuál es el volcán más alto de Nicaragua?',
      opciones: ['Momotombo', 'San Cristóbal', 'Concepción', 'Maderas'],
      correcta: 1,
      categoria: 'Geografía'
    ),
  ];

  final List<Map<String, dynamic>> _games = [
    {
      'id': 'trivia',
      'title': 'Trivia Nicaragüense',
      'description': 'Pon a prueba tus conocimientos sobre Nicaragua',
      'icon': Icons.quiz_rounded,
      'color': Colors.blue,
    },
    {
      'id': 'memory',
      'title': 'Memoria Cultural',
      'description': 'Encuentra las parejas de símbolos patrios',
      'icon': Icons.psychology_rounded,
      'color': Colors.green,
    },
    {
      'id': 'word',
      'title': 'Palabras Cruzadas',
      'description': 'Completa palabras relacionadas con Nicaragua',
      'icon': Icons.grid_on_rounded,
      'color': Colors.orange,
    },
    {
      'id': 'puzzle',
      'title': 'Rompecabezas',
      'description': 'Arma imágenes de lugares emblemáticos',
      'icon': Icons.extension_rounded,
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: responsive.hp(25),
            floating: false,
            pinned: true,
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Retos y Juegos',
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      cs.primary,
                      cs.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.games_rounded,
                    size: responsive.dp(8),
                    color: cs.onPrimary.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(responsive.wp(4)),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildGameSelector(responsive, cs),
                SizedBox(height: responsive.hp(3)),
                _buildSelectedGame(context, responsive),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: const BackFab(),
    );
  }

  Widget _buildGameSelector(ResponsiveUtils responsive, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona un juego',
          style: GoogleFonts.poppins(
            fontSize: responsive.dp(2.2),
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        SizedBox(height: responsive.hp(2)),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: responsive.wp(3),
            mainAxisSpacing: responsive.hp(1.5),
            childAspectRatio: 1.2,
          ),
          itemCount: _games.length,
          itemBuilder: (context, index) {
            final game = _games[index];
            final isSelected = _selectedGame == game['id'];
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGame = game['id'];
                  _resetGame();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? cs.primaryContainer : cs.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? cs.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      game['icon'],
                      size: responsive.dp(4),
                      color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                    ),
                    SizedBox(height: responsive.hp(1)),
                    Text(
                      game['title'],
                      style: GoogleFonts.poppins(
                        fontSize: responsive.dp(1.4),
                        fontWeight: FontWeight.w600,
                        color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSelectedGame(BuildContext context, ResponsiveUtils responsive) {
    switch (_selectedGame) {
      case 'trivia':
        return _buildTriviaGame(context, responsive);
      case 'memory':
        return _buildMemoryGame(context, responsive);
      case 'word':
        return _buildWordGame(context, responsive);
      case 'puzzle':
        return _buildPuzzleGame(context, responsive);
      default:
        return _buildTriviaGame(context, responsive);
    }
  }

  void _resetGame() {
    setState(() {
      _triviaIndex = 0;
      _selected = null;
      _score = 0;
      _flippedCards.clear();
      _firstFlipped = null;
      _secondFlipped = null;
      _currentWordIndex = 0;
      _userInput.clear();
      _puzzleOrder.clear();
      _puzzleCompleted = false;
      
      // Reinicializar juegos
      if (_selectedGame == 'memory') {
        _initializeMemoryGame();
      } else if (_selectedGame == 'word') {
        _initializeWordGame();
      } else if (_selectedGame == 'puzzle') {
        _initializePuzzleGame();
      }
    });
  }

  void _nextTrivia() {
    if (_selected == null) return;
    
    if (_selected == _preguntas[_triviaIndex].correcta) {
      _score++;
    }
    
    if (_triviaIndex < _preguntas.length - 1) {
      setState(() {
        _triviaIndex++;
        _selected = null;
      });
    } else {
      _showTriviaResult();
    }
  }

  void _showTriviaResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Trivia Completada!'),
        content: Text('Tu puntuación: $_score/${_preguntas.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('Jugar de nuevo'),
          ),
        ],
      ),
    );
  }

  Widget _buildTriviaGame(BuildContext context, ResponsiveUtils responsive) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final p = _preguntas[_triviaIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(responsive.wp(4)),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pregunta ${_triviaIndex + 1}/${_preguntas.length}',
                    style: GoogleFonts.poppins(
                      fontSize: responsive.dp(1.4),
                      fontWeight: FontWeight.w500,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'Puntos: $_score',
                    style: GoogleFonts.poppins(
                      fontSize: responsive.dp(1.4),
                      fontWeight: FontWeight.w600,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.hp(2)),
              Text(
                p.enunciado,
                style: GoogleFonts.poppins(
                  fontSize: responsive.dp(1.8),
                  fontWeight: FontWeight.w600,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: responsive.hp(3)),
        ...List.generate(p.opciones.length, (i) {
          final selected = _selected == i;
          return Padding(
            padding: EdgeInsets.only(bottom: responsive.hp(1)),
            child: GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: EdgeInsets.all(responsive.wp(4)),
                decoration: BoxDecoration(
                  color: selected ? cs.primary : cs.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? cs.primary : cs.outline.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: responsive.dp(3),
                      height: responsive.dp(3),
                      decoration: BoxDecoration(
                        color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + i),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: selected ? cs.primary : cs.surfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: responsive.wp(3)),
                    Expanded(
                      child: Text(
                        p.opciones[i],
                        style: GoogleFonts.poppins(
                          fontSize: responsive.dp(1.6),
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? cs.onPrimary : cs.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        SizedBox(height: responsive.hp(4)),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _selected == null ? null : _nextTrivia,
            icon: Icon(
              _triviaIndex < _preguntas.length - 1 ? Icons.navigate_next : Icons.flag,
            ),
            label: Text(
              _triviaIndex < _preguntas.length - 1 ? 'Siguiente Pregunta' : 'Finalizar Trivia',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: responsive.hp(1.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryGame(BuildContext context, ResponsiveUtils responsive) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    if (_memoryCards.isEmpty) {
      _initializeMemoryGame();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(responsive.wp(4)),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Memoria Cultural',
                style: GoogleFonts.poppins(
                  fontSize: responsive.dp(1.8),
                  fontWeight: FontWeight.w600,
                  color: cs.onPrimaryContainer,
                ),
              ),
              Text(
                'Puntos: $_score',
                style: GoogleFonts.poppins(
                  fontSize: responsive.dp(1.4),
                  fontWeight: FontWeight.w600,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: responsive.hp(2)),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: responsive.wp(2),
            mainAxisSpacing: responsive.hp(1),
            childAspectRatio: 1,
          ),
          itemCount: _memoryCards.length,
          itemBuilder: (context, index) {
            final card = _memoryCards[index];
            final isFlipped = _flippedCards.contains(index) || card.isFlipped;
            
            return GestureDetector(
              onTap: () => _onMemoryCardTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isFlipped ? cs.primary : cs.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cs.outline.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Icon(
                    isFlipped ? card.icon : Icons.help_outline,
                    size: responsive.dp(3),
                    color: isFlipped ? cs.onPrimary : cs.onSurfaceVariant,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: responsive.hp(2)),
        if (_memoryCards.every((card) => card.isFlipped))
          Center(
            child: ElevatedButton(
              onPressed: () => _resetGame(),
              child: Text('Jugar de nuevo'),
            ),
          ),
      ],
    );
  }

  Widget _buildWordGame(BuildContext context, ResponsiveUtils responsive) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(responsive.wp(4)),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Palabras Nicaragüenses',
                style: GoogleFonts.poppins(
                  fontSize: responsive.dp(1.8),
                  fontWeight: FontWeight.w600,
                  color: cs.onPrimaryContainer,
                ),
              ),
              SizedBox(height: responsive.hp(1)),
              Text(
                'Completa las palabras relacionadas con Nicaragua',
                style: GoogleFonts.poppins(
                  fontSize: responsive.dp(1.2),
                  color: cs.onPrimaryContainer.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: responsive.hp(3)),
        _buildWordPuzzle(responsive, cs),
      ],
    );
  }

  Widget _buildPuzzleGame(BuildContext context, ResponsiveUtils responsive) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(responsive.wp(4)),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rompecabezas Cultural',
                style: GoogleFonts.poppins(
                  fontSize: responsive.dp(1.8),
                  fontWeight: FontWeight.w600,
                  color: cs.onPrimaryContainer,
                ),
              ),
              SizedBox(height: responsive.hp(1)),
              Text(
                'Ordena las piezas para formar símbolos patrios',
                style: GoogleFonts.poppins(
                  fontSize: responsive.dp(1.2),
                  color: cs.onPrimaryContainer.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: responsive.hp(3)),
        _buildPuzzlePieces(responsive, cs),
      ],
     );
   }
   
   // Métodos para el juego de memoria
   void _initializeMemoryGame() {
     final icons = [
       Icons.flag, Icons.flag,
       Icons.landscape, Icons.landscape,
       Icons.local_florist, Icons.local_florist,
       Icons.music_note, Icons.music_note,
       Icons.restaurant, Icons.restaurant,
       Icons.church, Icons.church,
       Icons.waves, Icons.waves,
       Icons.sunny, Icons.sunny,
     ];
     
     icons.shuffle();
     
     _memoryCards = List.generate(
       icons.length,
       (index) => _MemoryCard(
         id: index ~/ 2,
         icon: icons[index],
         isFlipped: false,
       ),
     );
     
     _flippedCards.clear();
     _firstFlipped = null;
     _secondFlipped = null;
   }
   
   void _onMemoryCardTap(int index) {
     if (_flippedCards.contains(index) || 
         _memoryCards[index].isFlipped ||
         _flippedCards.length >= 2) return;
     
     setState(() {
       _flippedCards.add(index);
       
       if (_firstFlipped == null) {
         _firstFlipped = index;
       } else {
         _secondFlipped = index;
         _checkMemoryMatch();
       }
     });
   }
   
   void _checkMemoryMatch() {
     if (_firstFlipped == null || _secondFlipped == null) return;
     
     final firstCard = _memoryCards[_firstFlipped!];
     final secondCard = _memoryCards[_secondFlipped!];
     
     if (firstCard.id == secondCard.id) {
       // Match found
       setState(() {
         _memoryCards[_firstFlipped!] = _MemoryCard(
           id: firstCard.id,
           icon: firstCard.icon,
           isFlipped: true,
         );
         _memoryCards[_secondFlipped!] = _MemoryCard(
           id: secondCard.id,
           icon: secondCard.icon,
           isFlipped: true,
         );
         _score += 10;
         _flippedCards.clear();
         _firstFlipped = null;
         _secondFlipped = null;
       });
     } else {
       // No match
       Future.delayed(const Duration(milliseconds: 1000), () {
         setState(() {
           _flippedCards.clear();
           _firstFlipped = null;
           _secondFlipped = null;
         });
       });
     }
   }
   
   // Métodos para el juego de palabras
   void _initializeWordGame() {
     _wordPuzzles = [
       _WordPuzzle(
         word: 'MANAGUA',
         clue: 'Capital de Nicaragua',
         category: 'Geografía',
       ),
       _WordPuzzle(
         word: 'CORDOBA',
         clue: 'Moneda nacional',
         category: 'Economía',
       ),
       _WordPuzzle(
         word: 'GALLO PINTO',
         clue: 'Plato típico nacional',
         category: 'Gastronomía',
       ),
       _WordPuzzle(
         word: 'MASAYA',
         clue: 'Ciudad de las flores',
         category: 'Geografía',
       ),
     ];
     
     _currentWordIndex = 0;
     _userInput = List.filled(_wordPuzzles[0].word.length, '');
   }
   
   Widget _buildWordPuzzle(ResponsiveUtils responsive, ColorScheme cs) {
     if (_wordPuzzles.isEmpty) {
       _initializeWordGame();
     }
     
     final currentPuzzle = _wordPuzzles[_currentWordIndex];
     
     return Column(
       children: [
         Container(
           padding: EdgeInsets.all(responsive.wp(4)),
           decoration: BoxDecoration(
             color: cs.surfaceVariant,
             borderRadius: BorderRadius.circular(12),
           ),
           child: Column(
             children: [
               Text(
                 'Pista: ${currentPuzzle.clue}',
                 style: GoogleFonts.poppins(
                   fontSize: responsive.dp(1.4),
                   fontWeight: FontWeight.w500,
                 ),
                 textAlign: TextAlign.center,
               ),
               SizedBox(height: responsive.hp(1)),
               Text(
                 'Categoría: ${currentPuzzle.category}',
                 style: GoogleFonts.poppins(
                   fontSize: responsive.dp(1.2),
                   color: cs.primary,
                 ),
               ),
             ],
           ),
         ),
         SizedBox(height: responsive.hp(2)),
         Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: List.generate(
             currentPuzzle.word.length,
             (index) => Container(
               margin: EdgeInsets.symmetric(horizontal: responsive.wp(1)),
               width: responsive.wp(8),
               height: responsive.wp(8),
               decoration: BoxDecoration(
                 border: Border.all(color: cs.outline),
                 borderRadius: BorderRadius.circular(8),
                 color: _userInput[index].isNotEmpty ? cs.primaryContainer : cs.surface,
               ),
               child: Center(
                 child: Text(
                   _userInput[index],
                   style: GoogleFonts.poppins(
                     fontSize: responsive.dp(1.6),
                     fontWeight: FontWeight.w600,
                   ),
                 ),
               ),
             ),
           ),
         ),
         SizedBox(height: responsive.hp(2)),
         _buildLetterButtons(responsive, cs, currentPuzzle.word),
       ],
     );
   }
   
   Widget _buildLetterButtons(ResponsiveUtils responsive, ColorScheme cs, String word) {
     final letters = word.split('')..shuffle();
     
     return Wrap(
       spacing: responsive.wp(2),
       runSpacing: responsive.hp(1),
       children: letters.map((letter) {
         return GestureDetector(
           onTap: () => _onLetterTap(letter),
           child: Container(
             padding: EdgeInsets.all(responsive.wp(2)),
             decoration: BoxDecoration(
               color: cs.primary,
               borderRadius: BorderRadius.circular(8),
             ),
             child: Text(
               letter,
               style: GoogleFonts.poppins(
                 fontSize: responsive.dp(1.4),
                 fontWeight: FontWeight.w600,
                 color: cs.onPrimary,
               ),
             ),
           ),
         );
       }).toList(),
     );
   }
   
   void _onLetterTap(String letter) {
     final emptyIndex = _userInput.indexWhere((input) => input.isEmpty);
     if (emptyIndex != -1) {
       setState(() {
         _userInput[emptyIndex] = letter;
         
         if (!_userInput.contains('')) {
           _checkWordCompletion();
         }
       });
     }
   }
   
   void _checkWordCompletion() {
     final userWord = _userInput.join('');
     final correctWord = _wordPuzzles[_currentWordIndex].word.replaceAll(' ', '');
     
     if (userWord == correctWord) {
       _score += 20;
       
       if (_currentWordIndex < _wordPuzzles.length - 1) {
         setState(() {
           _currentWordIndex++;
           _userInput = List.filled(_wordPuzzles[_currentWordIndex].word.length, '');
         });
       } else {
         _showWordGameComplete();
       }
     } else {
       // Palabra incorrecta, limpiar
       Future.delayed(const Duration(milliseconds: 500), () {
         setState(() {
           _userInput = List.filled(_wordPuzzles[_currentWordIndex].word.length, '');
         });
       });
     }
   }
   
   void _showWordGameComplete() {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('¡Felicitaciones!'),
         content: Text('Has completado todas las palabras. Puntuación: $_score'),
         actions: [
           TextButton(
             onPressed: () {
               Navigator.of(context).pop();
               _resetGame();
             },
             child: const Text('Jugar de nuevo'),
           ),
         ],
       ),
     );
   }
   
   // Métodos para el rompecabezas
   void _initializePuzzleGame() {
     _puzzlePieces = [
       _PuzzlePiece(id: 0, icon: Icons.flag, correctPosition: 0),
       _PuzzlePiece(id: 1, icon: Icons.landscape, correctPosition: 1),
       _PuzzlePiece(id: 2, icon: Icons.local_florist, correctPosition: 2),
       _PuzzlePiece(id: 3, icon: Icons.waves, correctPosition: 3),
     ];
     
     _puzzleOrder = [0, 1, 2, 3]..shuffle();
     _puzzleCompleted = false;
   }
   
   Widget _buildPuzzlePieces(ResponsiveUtils responsive, ColorScheme cs) {
     if (_puzzlePieces.isEmpty) {
       _initializePuzzleGame();
     }
     
     return Column(
       children: [
         // Área objetivo
         Container(
           height: responsive.hp(15),
           decoration: BoxDecoration(
             border: Border.all(color: cs.outline, width: 2),
             borderRadius: BorderRadius.circular(12),
           ),
           child: Row(
             children: List.generate(4, (index) {
               final piece = _puzzleOrder.length > index ? 
                 _puzzlePieces.firstWhere((p) => p.id == _puzzleOrder[index]) : null;
               
               return Expanded(
                 child: Container(
                   margin: EdgeInsets.all(responsive.wp(1)),
                   decoration: BoxDecoration(
                     color: piece != null ? cs.primaryContainer : cs.surfaceVariant,
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: piece != null ? Center(
                     child: Icon(
                       piece.icon,
                       size: responsive.dp(4),
                       color: cs.onPrimaryContainer,
                     ),
                   ) : null,
                 ),
               );
             }),
           ),
         ),
         SizedBox(height: responsive.hp(2)),
         ElevatedButton(
           onPressed: _checkPuzzleCompletion,
           child: const Text('Verificar orden'),
         ),
         if (_puzzleCompleted)
           Padding(
             padding: EdgeInsets.only(top: responsive.hp(2)),
             child: Text(
               '¡Rompecabezas completado! +30 puntos',
               style: GoogleFonts.poppins(
                 fontSize: responsive.dp(1.4),
                 fontWeight: FontWeight.w600,
                 color: Colors.green,
               ),
             ),
           ),
       ],
     );
   }
   
   void _checkPuzzleCompletion() {
     bool isCorrect = true;
     for (int i = 0; i < _puzzleOrder.length; i++) {
       if (_puzzleOrder[i] != i) {
         isCorrect = false;
         break;
       }
     }
     
     setState(() {
       if (isCorrect) {
         _puzzleCompleted = true;
         _score += 30;
       } else {
         // Mezclar de nuevo
         _puzzleOrder.shuffle();
       }
     });
   }
 }

 class _Pregunta {
  final String enunciado;
  final List<String> opciones;
  final int correcta;
  final String categoria;
  const _Pregunta({required this.enunciado, required this.opciones, required this.correcta, this.categoria = ''});
}

class _MemoryCard {
  final int id;
  final IconData icon;
  final bool isFlipped;
  
  const _MemoryCard({required this.id, required this.icon, required this.isFlipped});
}

class _WordPuzzle {
  final String word;
  final String clue;
  final String category;
  
  const _WordPuzzle({
    required this.word,
    required this.clue,
    required this.category,
  });
}

class _PuzzlePiece {
  final int id;
  final IconData icon;
  final int correctPosition;
  
  const _PuzzlePiece({
    required this.id,
    required this.icon,
    required this.correctPosition,
  });
}
