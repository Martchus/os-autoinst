#!/usr/bin/perl
#
# Copyright (c) 2021 SUSE LLC
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, see <http://www.gnu.org/licenses/>.

# This test covers the signalblocker module and tinycv's helper to create
# threads upfront.

use Test::Most;

use FindBin '$Bin';
use lib "$Bin/../external/os-autoinst-common/lib";
use OpenQA::Test::TimeLimit '10000';
use File::Basename qw(dirname);
use Test::Warnings qw(warnings :report_warnings);
use Time::HiRes qw(sleep);
use POSIX ':signal_h';

use needle;
use cv;

no warnings 'redefine';
sub bmwqemu::diag { note $_[0] }

my $data_dir = $bmwqemu::vars{NEEDLES_DIR} = dirname(__FILE__) . '/data';

cv::init;
require tinycv;

# test image creation, search and destruction
my $ref_image_path  = "$data_dir/kde.ref.png";
my $test_image_path = "$data_dir/kde.test.png";
for my $i (1 .. 10000) {
    my $ref_image = tinycv::read($ref_image_path);
    is $ref_image->xres, 1024, "ref image width ($i)";
    is $ref_image->yres, 768,  "ref image height ($i)";

    my $test_image = tinycv::read($ref_image_path);
    is $test_image->xres, 1024, "test image width ($i)";
    is $test_image->yres, 768,  "test image height ($i)";

    my @res = $test_image->search_needle($ref_image, 100, 100, 50, 50, 0);
    is_deeply \@res, [1, 100, 100], 'search ($i)' or diag explain \@res;

    undef $ref_image;
    undef $test_image;
}

done_testing;
