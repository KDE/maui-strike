#include <cstdlib>

int main(int argc, char** argv)
{
    if (argc < 2)
    {
        return 1;
    }

    if (std::atoi(argv[1]) == 4)
    {
        return 0;
    }
    else
    {
        return 1;
    }
}
