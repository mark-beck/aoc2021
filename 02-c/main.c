#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum
{
    FORWARD,
    UP,
    DOWN
} Direction;

typedef struct
{
    Direction direction;
    int distance;
} Instruction;

Instruction parse_instruction(char *string)
{
    Instruction instruction;
    char *pch;
    pch = strtok(string, " ");

    if (pch[0] == 'f') {
        instruction.direction = FORWARD;
    } else if (pch[0] == 'u') {
        instruction.direction = UP;
    } else if (pch[0] == 'd') {
        instruction.direction = DOWN;
    } else {
        printf("Invalid instruction: %s\n", pch);
        exit(1);
    }

    pch = strtok(NULL, " ");

    instruction.distance = atoi(pch);

    return instruction;
}

char **split_lines(char *buffer, size_t size, size_t *count)
{
    *count = 1;
    for (int i = 0; i < size; i++)
    {
        if (buffer[i] == '\n')
        {
            buffer[i] = '\0';
            if (i + 1 < size)
            {
                *count += 1;
            }
        }
    }
    char **lines = malloc(sizeof(char *) * (*count));
    lines[0] = buffer;
    for (int i = 0, j = 1; i < size; i++)
    {
        if (buffer[i] == '\0')
        {
            if (i + 1 < size)
            {
                lines[j++] = buffer + i + 1;
            }
        }
    }

    return lines;
}

int main(int argc, char **argv)
{
    FILE *fp = fopen(argv[1], "r");
    fseek(fp, 0, SEEK_END);
    size_t size = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    char *buffer = malloc(size);

    fread(buffer, size, size, fp);

    fclose(fp);

    size_t line_c = 0;

    char **lines = split_lines(buffer, size, &line_c);

    int depth = 0;
    int pos = 0;
    int aim = 0;

    for (int i = 0; i < line_c; i++)
    {
        Instruction ins = parse_instruction(lines[i]);
        printf("### instruction %d ###\n", i);
        printf("direction: %d\n", ins.direction);
        printf("distance: %d\n", ins.distance);
        if (ins.direction == FORWARD)
        {
            pos += ins.distance;
            depth += ins.distance * aim;
        } else if (ins.direction == UP)
        {
            aim -= ins.distance;
        } else if (ins.direction == DOWN)
        {
            aim += ins.distance;
        }
    }

    printf("### result ###\n");
    printf("depth: %d\n", depth);
    printf("pos: %d\n", pos);
    printf("mult: %d\n", depth * pos);

    return 0;
}
