class SNode<T> {
    data: T;
    next: SNode<T> | null;
  
    constructor(item: T, next: SNode<T> | null) {
      this.data = item;
      this.next = next;
    }
}
  
  
class Stack<T> {
    end: null | SNode<T>;

    constructor() {
        this.end = null;
    }

    push(item: T) {
        if (this.end == null) {
        this.end = new SNode(item, null);
        } else {
        let newnode = new SNode(item, this.end);
        this.end = newnode;
        }
    }

    pop(): T {
        if (this.end == null) {
        throw "Stack Empty";
        }
        let res = this.end.data;
        this.end = this.end.next;
        return res;
    }

    peek(): T {
        if (this.end == null) {
        throw "Stack Empty";
        }
        return this.end.data;
    }

    count(): number {
        let current = this.end;
        let count = 0;
        while (current != null) {
        count += 1;
        current = current.next;
        }
        return count;
    }

    to_array(): T[] {
        let current = this.end;
        let arr = [];
        while (current != null) {
            arr.push(current.data);
            current = current.next;
        }
        return arr;
    }
}

enum BracketType {
    Round = ")",
    Curly = "}",
    Square = "]",
    Angle = ">",
}

enum CheckResult {
    Good = "Good",
    Incomplete = "Incomplete",
    Wrong = "Wrong",
}

function checkLine(line: string): [CheckResult, BracketType[] | null] {
    let stack: Stack<BracketType> = new Stack();
    while (line.length != 0) {
        let head = line.substring(0, 1);
        let tail = line.substring(1);
        line = tail;
        switch (head) {
        case "(": stack.push(BracketType.Round); break;
        case "{": stack.push(BracketType.Curly); break;
        case "[": stack.push(BracketType.Square); break;
        case "<": stack.push(BracketType.Angle); break;
        case ")":
            if (stack.pop() != BracketType.Round) {
                return [CheckResult.Wrong, [BracketType.Round]];
            }
            break;
        case "}":
            if (stack.pop() != BracketType.Curly) {
                return [CheckResult.Wrong, [BracketType.Curly]];
            }
            break;
        case "]":
            if (stack.pop() != BracketType.Square) {
                return [CheckResult.Wrong, [BracketType.Square]];
            }
            break;
        case ">":
            if (stack.pop() != BracketType.Angle) {
                return [CheckResult.Wrong, [BracketType.Angle]];
            }
            break;
        }
    }
    if (stack.count() != 0) {
        return [CheckResult.Incomplete, stack.to_array()];
    }
    return [CheckResult.Good, null];
}

function solve1(input: string) {
    let sum = 0;
    for (let line of input.split("\n")) {
        let [result, bracket] = checkLine(line);
        if (result == CheckResult.Wrong) {
            if (bracket == null) {
                throw `${line} is ${result} with ${bracket}`;
            }
            let score = getScore(bracket[0]);
            sum += score;
        }
    }
    console.log("solution 1:");
    console.log(`Total score: ${sum}`);
}

function solve2(input: string) {
    let scores = [];
    for (let line of input.split("\n")) {
        let [result, bracket] = checkLine(line);
        if (result == CheckResult.Incomplete) {
            if (bracket == null) {
                throw `${line} is ${result} with ${bracket}`;
            }
            let score = getScore2(bracket);
            scores.push(score);
        }
    }
    scores.sort((a, b) => a - b);
    let middle = Math.floor(scores.length / 2);
    console.log("solution 2:");
    console.log(`score: ${scores[middle]}`);
}

function getScore2(brackets: BracketType[]): number {
    let sum = 0;
    for (let b of brackets) {
        sum *= 5;
        let score = 0;
        switch (b) {
        case BracketType.Round: score = 1; break;
        case BracketType.Square: score = 2; break;
        case BracketType.Curly: score = 3; break;
        case BracketType.Angle: score = 4; break;
        }
        sum += score;
    }
    return sum;
}

function getScore(bt: BracketType): number {
    switch (bt) {
    case BracketType.Round: return 3;
    case BracketType.Curly: return 1197;
    case BracketType.Square: return 57;
    case BracketType.Angle: return 25137;
    }
}



for (let filename of Deno.args) {
    let input = await Deno.readTextFile(filename);
    console.log(`${filename}:`);
    solve1(input);
    solve2(input);
}