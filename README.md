
# Intro

Code breaking puzzle game implemented in bash. 

This script was created as a corona-lockdown-exercize to learn bash coding. Apologies that as a result it is ugly and inefficient ...

# Goal

Break the hidden code within a limited number of inferences. Upon submitting an attempt the game returns the number of correct but incorrectly placed (blue) and correctly placed (green) pegs. When completing a level by breaking the code within the maximum allowed number of guesses the player can choose to go to the next level. Level difficulty increases by increasing the number of peg colors and/or the code length or by allowing duplicates. The maximum number of attempts is customized to be challenging but possible to accomplish with a decent strategy. Finish all levels (with and without duplicates) to get a treat.

# Key bindings

| Key             | Action                     |
|:---------------:|:--------------------------:|
| h,left          | move cursor left           |
| l,right         | move cursor right          |
| r,1             | place/remove red peg       |
| g,2             | place/remove green peg     |
| y,3             | place/remove yellow peg    |
| b,4             | place/remove blue peg      |
| m,5             | place/remove magenta peg   |
| c,6             | place/remove cyan peg      |
| w,7             | place/remove white peg     |
| d,8             | place/remove dark grey peg |
| .,              | remove peg                 |
| space,enter,tab | submit attempt             |
| x               | new game same level        |
| s               | new game select level      |
| q               | quit game                  |
| z               | new game random level      |

