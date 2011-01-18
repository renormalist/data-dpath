#! /usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::DPath::Context;
use Data::Dumper;

my $data = {
            'goal' => { lines => [
                                  { aaa => 'aaa' },
                                  { bbb => 'bbb' },
                                 ],
                        numbers => bless([
                                          { 111 => '111' },
                                          { 222 => '222' },
                                         ], "AffeZomtec"),
                      }
           };

ok(Data::DPath::Context::HASH_or_ARRAY(\ ($data)), "hash");
ok(Data::DPath::Context::HASH_or_ARRAY(\ ($data->{goal})), "hash");
ok(Data::DPath::Context::HASH_or_ARRAY(\ ($data->{goal}{lines})), "array");
ok(Data::DPath::Context::HASH_or_ARRAY(\ ($data->{goal}{numbers})), "array");
ok(Data::DPath::Context::HASH_or_ARRAY(\ ($data->{goal}{numbers}[0])), "hash");
ok(!Data::DPath::Context::HASH_or_ARRAY(\ ($data->{goal}{numbers}[0]{111})), "misc");
 
# is(Data::DPath::Context::HASH_or_ARRAY(\($data)), Data::DPath::Context::KIND_OF_HASH, "hash");
# is(Data::DPath::Context::HASH_or_ARRAY(\($data->{goal})), Data::DPath::Context::KIND_OF_HASH, "hash");
# is(Data::DPath::Context::HASH_or_ARRAY(\($data->{goal}{lines})), Data::DPath::Context::KIND_OF_ARRAY, "array");
# is(Data::DPath::Context::HASH_or_ARRAY(\($data->{goal}{numbers})), Data::DPath::Context::KIND_OF_ARRAY, "array");
# is(Data::DPath::Context::HASH_or_ARRAY(\($data->{goal}{numbers}[0])), Data::DPath::Context::KIND_OF_HASH, "hash");
# is(Data::DPath::Context::HASH_or_ARRAY(\($data->{goal}{numbers}[0]{111})), Data::DPath::Context::KIND_OF_OTHER, "misc");
 
done_testing();
