#include <iostream>
#include <string>
#include <vector>
#include <filesystem>
#include <ranges>
#include <algorithm>
#include <utility>
#include <fstream>

struct Point
{
    int x;
    int y;
    Point(int x, int y) : x(x), y(y) {}

    auto to_str() -> std::string
    {
        return "[" + std::to_string(this->x) + "," + std::to_string(this->y) + "]";
    }
};

struct Line
{
    Point start;
    Point end;
    Line(Point start, Point end) : start(start), end(end) {}

    auto max() -> Point
    {
        int x = std::max(this->start.x, this->end.x);
        int y = std::max(this->start.y, this->end.y);
        return Point(x, y);
    }

    auto to_str() -> std::string
    {
        return "Line {\n  " + this->start.to_str() + "\n  " + this->end.to_str() + "\n}";
    }
};

auto max_lines(std::vector<Line> lines) -> Point
{
    int max_x = 0;
    int max_y = 0;
    for (auto line : lines)
    {
        auto max_point = line.max();
        if (max_point.x > max_x)
            max_x = max_point.x;
        if (max_point.y > max_y)
            max_y = max_point.y;
    }
    return Point(max_x, max_y);
}

struct Lexer
{
    std::string statement;
    int current_pos = 0;

    Lexer(std::string statement) : statement(statement) {}

    char peek()
    {
        return statement[current_pos];
    }

    char next()
    {
        return statement[current_pos++];
    }

    void consume(char expected)
    {
        if (peek() == expected)
        {
            next();
            return;
        }
        throw std::runtime_error("Expected (" + std::string(1, expected) + ") on char " + std::to_string(this->current_pos));
    }

    void consume(std::string expected)
    {
        for (auto c : expected)
        {
            consume(c);
        }
    }

    bool is_digit(char c)
    {
        return c >= '0' && c <= '9';
    }

    int get_number()
    {
        std::stringstream ss;

        while (is_digit(peek()))
        {
            ss << next();
        }
        return std::stoi(ss.str());
    }

    Point get_point()
    {
        int x = get_number();
        consume(',');
        int y = get_number();
        return Point(x, y);
    }

    Line parse()
    {
        Point start = get_point();
        consume(" -> ");
        Point end = get_point();
        return Line(start, end);
    }
};

auto parse_file(std::string content) -> std::vector<Line>
{
    std::vector<Line> lines;
    std::string line;
    std::stringstream ss(content);
    while (std::getline(ss, line))
    {
        Lexer lexer(line);
        lines.push_back(lexer.parse());
    }

    return lines;
}

auto print_field(std::vector<std::vector<u_int>> field) -> void
{
    for (auto row : field)
    {
        std::cout << "[";
        for (auto e : row)
        {
            std::cout << e << "|";
        }
        std::cout << "]" << std::endl;
    }
}

auto fill_line_part1(std::vector<std::vector<u_int>> &field, Line line) -> void
{
    if (line.start.x == line.end.x)
    {
        int min_y = std::min(line.start.y, line.end.y);
        int max_y = std::max(line.start.y, line.end.y);
        for (int i = min_y; i <= max_y; i++)
        {
            field[i][line.start.x] += 1;
        }
    }
    else if (line.start.y == line.end.y)
    {
        int min_x = std::min(line.start.x, line.end.x);
        int max_x = std::max(line.start.x, line.end.x);
        for (int i = min_x; i <= max_x; i++)
        {
            field[line.start.y][i] += 1;
        }
    }
}

auto fill_line_part2(std::vector<std::vector<u_int>> &field, Line line) -> void
{
    if (line.start.x == line.end.x)
    {
        int min_y = std::min(line.start.y, line.end.y);
        int max_y = std::max(line.start.y, line.end.y);
        for (int i = min_y; i <= max_y; i++)
        {
            field[i][line.start.x] += 1;
        }
    }
    else if (line.start.y == line.end.y)
    {
        int min_x = std::min(line.start.x, line.end.x);
        int max_x = std::max(line.start.x, line.end.x);
        for (int i = min_x; i <= max_x; i++)
        {
            field[line.start.y][i] += 1;
        }
    }
    else if (line.start.x - line.end.x == line.start.y - line.end.y)
    {
        int min_x = std::min(line.start.x, line.end.x);
        int min_y = std::min(line.start.y, line.end.y);
        int max_x = std::max(line.start.x, line.end.x);

        for (int x = min_x, y = min_y; x <= max_x; x++, y++) {
            field[y][x] += 1;
        }
    }
    else if (line.start.x - line.end.x == (line.start.y - line.end.y) * -1)
    {
        int min_x = std::min(line.start.x, line.end.x);
        int max_x = std::max(line.start.x, line.end.x);
        int max_y = std::max(line.start.y, line.end.y);

        for (int x = min_x, y = max_y; x <= max_x; x++, y--) {
            field[y][x] += 1;
        }
    }
}

auto count_part1(std::vector<std::vector<u_int>> &field) -> int
{
    int counter = 0;
    for (auto row : field)
    {
        for (u_int x : row)
        {
            if (x >= 2)
                counter++;
        }
    }
    return counter;
}

auto solve_part1(std::vector<Line> lines) -> int
{

    Point point = max_lines(lines);
    std::cout << "max fields: " << point.to_str() << std::endl;

    std::vector<std::vector<u_int>> field;

    for (int y = 0; y <= point.y; y++)
    {
        std::vector<u_int> row(point.x + 1);
        field.push_back(row);
    }

    for (Line line : lines)
    {
        fill_line_part1(field, line);
    }

    // print_field(field);

    int count = count_part1(field);

    return count;
}

auto solve_part2(std::vector<Line> lines) -> int
{

    Point point = max_lines(lines);
    std::cout << "max fields: " << point.to_str() << std::endl;

    std::vector<std::vector<u_int>> field;

    for (int y = 0; y <= point.y; y++)
    {
        std::vector<u_int> row(point.x + 1);
        field.push_back(row);
    }

    for (Line line : lines)
    {
        fill_line_part2(field, line);
    }

    // print_field(field);

    int count = count_part1(field);

    return count;
}

auto main(int argc, char *argv[]) -> int
{
    std::vector<std::string> arguments(argv, argv + argc);

    // ignore first argument
    arguments.erase(arguments.begin());

    // loop over the arguments
    for (auto &argument : arguments)
    {
        // check if the argument is a file
        if (std::filesystem::exists(argument))
        {
            // read the file
            std::ifstream file(argument);
            std::string content((std::istreambuf_iterator<char>(file)),
                                (std::istreambuf_iterator<char>()));
            // solve the file

            auto lines = parse_file(content);

            auto result1 = solve_part1(lines);
            std::cout << "count part 1 = " << result1 << std::endl;

            auto result2 = solve_part2(lines);
            std::cout << "count part 2 = " << result2 << std::endl;
        }
        else
        {
            // print error message
            std::cout << "File " << argument << " does not exist" << std::endl;
        }
    }

    return 0;
}