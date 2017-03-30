use Test::More;
use Test::LeakTrace;
use List::Flatten::XS 'flatten';

my $pattern = +[
    [1, [2, 3, 4], [5, 6, 7, 8, 9, 1, 2, 3]],
    [[1, 2, 3], [4, 5, [6, 7, [8, 9, [1, 2, 3]]]]],
    [[[1, 2, 3], 4, 5], 6, 7, [8, [9, [1], 2], 3]],
    [1, [2, [3, [4, [5, [6, [7, [8, [9, [1, [2, [3]]]]]]]]]]]],
    [[[[[[[[[[[[1], 2], 3], 4], 5], 6], 7], 8], 9], 1], 2], 3],
];

no_leaks_ok {
    flatten($pattern->[0]);
} 'Detected memory leak via flatten()';

my $expected_for_level = +[
    +{
        1 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3]
    },
    +{
        1 => [1, 2, 3, 4, 5, [6, 7, [8, 9, [1, 2, 3]]]],
        2 => [1, 2, 3, 4, 5, 6, 7, [8, 9, [1, 2, 3]]],
        3 => [1, 2, 3, 4, 5, 6, 7, 8, 9, [1, 2, 3]],
        4 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3]
    },
    +{
        1 => [[1, 2, 3], 4, 5, 6, 7, 8, [9, [1], 2], 3],
        2 => [1, 2, 3, 4, 5, 6, 7, 8, 9, [1], 2, 3],
        3 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3]
    },
    +{
        1  => [1, 2, [3, [4, [5, [6, [7, [8, [9, [1, [2, [3]]]]]]]]]]],
        5  => [1, 2, 3, 4, 5, 6, [7, [8, [9, [1, [2, [3]]]]]]],
        9  => [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, [2, [3]]],
        11 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3]
    },
    +{
        1  => [[[[[[[[[[[1], 2], 3], 4], 5], 6], 7], 8], 9], 1], 2, 3],
        5  => [[[[[[[1], 2], 3], 4], 5], 6], 7, 8, 9, 1, 2, 3],
        9  => [[[1], 2], 3, 4, 5, 6, 7, 8, 9, 1, 2, 3],
        11 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3]
    }
];

for my $i (0 .. $#$pattern) {
    while (my ($level, $expected) = each %{$expected_list->[$i]}) {
        no_leaks_ok {
            flatten($pattern->[$i], $level);
        } 'Detected memory leak via flatten($ary, $level)';
    }
}
done_testing;