# P1 Report: Department Assignment Puzzle

## 1. Value of N

```prolog
?- count_solutions([1,2,3,4,5,6,7,8], N).
N = 3.
```

To reproduce:

```bash
swipl -q -f code/grp13_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8], N), print(N), nl" -t halt
```

## 2. What N = 3 tells us

> **The puzzle is under-constrained.** Clues 1 to 8 do not have a unique solution: out of the 4!³ = 13,824 possible assignments, exactly **three** satisfy all eight clues.

| Friend    | Solution 1                     | Solution 2                     | Solution 3                     |
| :-------- | :----------------------------- | :----------------------------- | :----------------------------- |
| **Alex**  | design · java · AI             | design · java · embedded       | testing · python · embedded    |
| **Ben**   | development · javascript · web | development · javascript · web | development · javascript · web |
| **Carla** | research · c++ · data          | testing · python · AI          | design · java · AI             |
| **Dana**  | testing · python · embedded    | research · c++ · data          | research · c++ · data          |

Each cell is *department · language · project*.

So `main` (P1.a) prints *a* valid answer (Solution 1, the first one found), but the original puzzle has no single "correct" answer.

### 2.1 What the clues do fix

- **Ben is fully determined:** development, JavaScript, web in all three solutions.
- **Most value combinations are fixed:** in every solution, research goes with C++ and data, development with JavaScript and web, design with Java, and testing with Python. Only the AI and embedded projects move between the design and testing friends.
- **Every clue is needed.** Leaving out any one clue increases the count, so none of the eight is redundant:

| Clue left out | Solutions without it |
| :-----------: | :------------------: |
| 1             | 4                    |
| 2             | 6                    |
| 3             | 13                   |
| 4             | 12                   |
| 5             | 9                    |
| 6             | 7                    |
| 7             | 5                    |
| 8             | 16                   |

The clues are not wrong, just not enough: one more piece of information is needed.

## 3. What this means for the repair (P1.c)

Solutions 1 and 3 contain exactly the same four (department, language, project) combinations; they differ only in which person holds each one. Ben keeps his combination, and the three combinations held by Alex, Carla and Dana are rotated among them:

| Combination                 | Solution 1 | Solution 3 |
| :-------------------------- | :--------: | :--------: |
| design · java · AI          | Alex       | Carla      |
| research · c++ · data       | Carla      | Dana       |
| testing · python · embedded | Dana       | Alex       |

A clue that may refer to friends only through attribute values (as P1.c requires) cannot tell these two solutions apart. So any valid ninth clue that leaves one solution must keep **Solution 2**.

Our clue 9 does exactly that:

```prolog
% CLUE 9: The friend who works in the testing department prefers the AI project.
```

It is true only in Solution 2, where Carla works in testing and prefers AI, and

```prolog
?- count_solutions([1,2,3,4,5,6,7,8,9], N).
N = 1.
```