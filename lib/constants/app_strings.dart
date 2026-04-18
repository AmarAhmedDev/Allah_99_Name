class AppStrings {
  // Home Screen
  static String appTitle(bool am) => am ? 'የአሏህ መልካም ስሞች' : 'Asma\'ul Husna';
  static String discoverText(bool am) => am ? '99ኙን ውብ የአላህ ስሞች ይማሩ' : 'Discover the 99 Beautiful Names of Allah';
  static String startLearning(bool am) => am ? 'መማር ጀምር' : 'Start Learning';
  static String playAllNames(bool am) => am ? 'ሁሉንም አጫውት' : 'Play All Names';
  static String testFeature(bool am) => am ? 'ፈተና' : 'Test';
  static String tasbihFeature(bool am) => am ? 'ተስቢህ' : 'Tasbih';
  static String puzzleFeature(bool am) => am ? 'ፐዝል' : 'Puzzle';
  static String hadithQuote(bool am) => am 
      ? '"በእርግጥም አላህ ዘጠና ዘጠኝ ስሞች አሉት። እነሱን የሐፈዛቸው (ያወቃቸው) ጀነት ይገባል።"' 
      : '"Indeed, Allah has ninety-nine names, one hundred less one. Whoever encompasses them will enter Paradise."';
  static String hadithSource(bool am) => am ? '- ሰሂህ ቡኻሪ' : '- Sahih Bukhari';

  // Application general
  static String selectLanguage(bool am) => am ? 'ቋንቋ ይምረጡ' : 'Select Language';

  // Names List Screen
  static String searchPlaceholder(bool am) => am ? 'ስሞችን ይፈልጉ...' : 'Search names...';
  static String playAll(bool am) => am ? 'ሁሉንም አጫውት' : 'Play All';
  static String noNamesFound(bool am) => am ? 'ምንም ስም አልተገኘም' : 'No names found';

  // Name Detail Screen
  static String previous(bool am) => am ? 'ቀዳሚ' : 'Previous';
  static String next(bool am) => am ? 'ቀጣይ' : 'Next';

  // Practice Screen
  static String testKnowledge(bool am) => am ? 'እውቀትዎን ይፈትኑ' : 'Test Your Knowledge';
  static String score(bool am) => am ? 'ውጤት: ' : 'Score: ';
  static String whatIsNameFor(bool am) => am ? 'ይህ ትርጉም የማን ስም ነው:' : 'What is the name for:';
  static String nextQuestion(bool am) => am ? 'ቀጣይ ጥያቄ' : 'Next Question';
  static String seeResults(bool am) => am ? 'ውጤት ይመልከቱ ✨' : 'See Results ✨';
  static String practiceComplete(bool am) => am ? 'ልምምድ ተጠናቋል!' : 'Practice Complete!';
  static String yourScore(bool am) => am ? 'የእርስዎ ውጤት' : 'Your Score';
  static String tryAgain(bool am) => am ? 'እንደገና ይሞክሩ' : 'Try Again';
  static String returnHome(bool am) => am ? 'ወደ ዋናው ገጽ ይመለሱ' : 'Return Home';
  static String correctStats(bool am) => am ? 'ትክክል' : 'Correct';
  static String wrongStats(bool am) => am ? 'ስህተት' : 'Wrong';
  static String totalStats(bool am) => am ? 'ድምር' : 'Total';

  // Tasbih Screen
  static String digitalTasbih(bool am) => am ? 'ዲጂታል ተስቢህ' : 'Digital Tasbih';
  static String tapToCount(bool am) => am ? 'ለመቁጠር የትኛውንም ቦታ ይንኩ' : 'Tap anywhere to count';
  static String reset(bool am) => am ? 'አድስ (Reset)' : 'Reset';
  static String target(bool am) => am ? 'ዒላማ: ' : 'Target: ';
  static String cycle(bool am) => am ? 'ዙር: ' : 'Cycle: ';
  
  // Puzzle Levels Screen
  static String puzzleLevels(bool am) => am ? 'የግጥምጥም ደረጃዎች' : 'Puzzle Levels';
  static String level(bool am) => am ? 'ደረጃ ' : 'Level ';
  static String names(bool am) => am ? 'ስሞች ' : 'Names ';
  static String locked(bool am) => am ? 'ተቆልፏል' : 'Locked';
  static String completeToUnlock(bool am, int level) => am ? 'ይህንን ለመክፈት ደረጃ $levelን ያጠናቁ!' : 'Complete Level $level to unlock this!';

  // Puzzle Game Screen
  static String completeOrder(bool am) => am ? 'ቅደም ተከተሉን ያሟሉ' : 'Complete the order';
  static String checkOrder(bool am) => am ? 'ቅደም ተከተል አረጋግጥ' : 'Check Order';
  static String correct(bool am) => am ? 'ትክክል!' : 'Correct!';
  static String excellentCompleted(bool am) => am ? 'በጣም ጥሩ! ይህንን ደረጃ አጠናቀዋል።' : 'Excellent! You completed this level.';
  static String nextLevel(bool am) => am ? 'ቀጣይ ደረጃ' : 'Next Level';
  static String notQuiteRight(bool am) => am ? 'ትክክል አይደለም! ሌላ ቦታ ይሞክሩ።' : 'Not correct! Try another slot.';
  static String keepTrying(bool am) => am ? 'መሞከርዎን ይቀጥሉ! ፍንጮቹን ይመልከቱ።' : 'Keep trying! Look at the hints.';
  static String allMemorized(bool am, int total) => am ? 'ማሻአላህ! $total ስሞችን በቃሎት አጥንተዋል! 🎉' : 'Mashallah! You memorized all $total names! 🎉';
  static String dragInstructions(bool am) => am ? 'የአረብኛ ስሞችን በትክክለኛው የቅደም ተከተል ቦታ ያስቀምጡ።' : 'Drag the Arabic names into the correct sequential order.';
  static String levelComplete(bool am, int level) => am ? 'ደረጃ $level ተጠናቋል!' : 'Level $level Complete!';
  static String orderPreserved(bool am) => am ? 'ትክክለኛው ቅደም ተከተል ለክለሳ ከላይ ተቀምጧል።' : 'The correct order is preserved above for review.';
  static String playAgain(bool am) => am ? 'እንደገና ይጫወቱ' : 'Play Again';
  static String backToLevels(bool am) => am ? 'ወደ ደረጃዎች ይመለሱ' : 'Back to Levels';
  static String completedAllLevels(bool am) => am ? 'ማሻአላህ! ሁሉንም ደረጃዎች አጠናቀዋል!' : 'Mashallah! You completed all levels!';
}
