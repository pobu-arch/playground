#!/usr/bin/env perl

%SPEC_INFO =
(
    '2006' =>
    {
        'macro'             => '-DSPEC_CPU -DNDEBUG -DSPEC_CPU_LP64',
        
        # Int
        '400.perlbench'     => '06_perlbench.filelist',
        '483.xalancbmk'     => '06_xalancbmk.filelist'
    },

    '2017' =>
    {
        'macro'             => '-DSPEC -DSPEC_CPU -DSPEC_LP64 -DNDEBUG -DSPEC_AUTO_SUPPRESS_OPENMP',
        
        # Int
        '600.perlbench_s'   => '17_perlbench.filelist',
        '602.gcc_s'         => '17_gcc.filelist',
        '623.xalancbmk_s'   => '17_xalancbmk.filelist',
        '625.x264_s'        => '17_x264.filelist',
        '657.xz_s'          => '17_xz.filelist',
        
        # Fp
        '526.blender_r'     => '17_blender.filelist'
    }
);

%SUPPORTED_BENCHMARKS =
(

####################################################################################################

# SPECint 2006 Supported

####################################################################################################

    '400.perlbench' =>
    {
        'version' => '2006',
        'type'    => 'int',
        'macro'   => '-DPERL_CORE -fgnu89-inline',

        'test'    => ['attrs.pl',
                      'gv.pl',
                      'makerand.pl',
                      'pack.pl',
                      'redef.pl',
                      'ref.pl',
                      'regmesg.pl',
                      'test.pl'],

        'train'   => ['diffmail.pl 2 550 15 24 23 100',
                      'perfect.pl b 3',
                      'scrabbl.pl < scrabbl.in',
                      'splitmail.pl 535 13 25 24 1091',
                      'suns.pl'
                      ],

        'ref'     => ['checkspam.pl 2500 5 25 11 150 1 1 1 1',
                      'diffmail.pl 4 800 10 17 19 300',
                      'splitmail.pl 1600 12 26 16 4500']
    },

    '401.bzip2' =>
    {
        'version'   => '2006',
        'type'      => 'int',
        'macro'     => '',

        'test'      => ['input.program 5','dryer.jpg 2'],

        'train'     => ['input.program 10','byoudoin.jpg 5', 'input.combined 80'],

        'ref'       => ['input.source 280', 'chicken.jpg 30', 'liberty.jpg 30', 'input.program 280',
                        'text.html 280', 'input.combined 200']
    },

    '403.gcc' =>
    {
        'version'   => '2006',
        'type'      => 'int',
        'macro'     => '',

        'test'      => ['cccp.i -o cccp.s'],

        'train'     => ['integrate.i -o integrate.s'],

        'ref'       => ['166.i -o 166.s', '200.i -o 200.s', 'c-typeck.i -o c-typeck.s',
                        'cp-decl.i -o cp-decl.s', 'expr.i -o expr.s', 'expr2.i -o expr2.s',
                        'g23.i -o g23.s', 's04.i -o s04.s', 'scilab.i -o scilab.s']
    },

    '429.mcf' =>
    {
        'version'   => '2006',
        'type'      => 'int',
        'macro'     => '',

        'test'      => ['inp.in'],

        'train'     => ['inp.in'],

        'ref'       => ['inp.in']
    },

    '445.gobmk' =>
    {
        'version'   => '2006',
        'type'      => 'int',
        'macro'     => '-DHAVE_CONFIG_H',

        'test'      => ['capture.tst', 'connect.tst', 'connection.tst', 'connection_rot.tst',
                        'connect_rot.tst', 'cutstone.tst', 'dniwog.tst'],

        'train'     => ['arb.tst', 'arend.tst', 'arion.tst', 'atari_atari.tst',
                        'blunder.tst', 'buzco.tst', 'nicklas2.tst', 'nicklas4.tst'],

        'ref'       => ['13x13.tst', 'nngs.tst', 'score2.tst', 'trevorc.tst', 'trevord.tst']
    },

    '456.hmmer' =>
    {
        'version'   => '2006',
        'type'      => 'int',
        'macro'     => '-lm',

        'test'      => ['--fixed 0 --mean 325 --num 45000 --sd 200 --seed 0 bombesin.hmm'],

        'train'     => ['--fixed 0 --mean 425 --num 85000 --sd 300 --seed 0 leng100.hmm'],

        'ref'       => ['nph3.hmm swiss41', '--fixed 0 --mean 500 --num 500000 --sd 350 --seed 0 retro.hmm']
    },

    '458.sjeng' =>
    {
        'version'   => '2006',
        'type'      => 'int',
        'macro'     => '',

        'test'      => ['test.txt'],

        'train'     => ['train.txt'],

        'ref'       => ['ref.txt']
    },

    '462.libquantum' =>
    {
        'version'   => '2006',
        'type'      => 'int',
        'macro'     => '-DSPEC_CPU_LINUX -lm',

        'test'      => ['33 5'],

        'train'     => ['143 25'],

        'ref'       => ['1397 8']
    },

    '464.h264ref' =>
    {
        'version'   => '2006',
        'type'      => 'int',
        'macro'     => '-lm',

        'test'      => ['-d foreman_test_encoder_baseline.cfg'],

        'train'     => ['-d foreman_train_encoder_baseline.cfg'],

        'ref'       => ['-d foreman_ref_encoder_baseline.cfg', '-d foreman_ref_encoder_main.cfg',
                        '-d sss_encoder_main.cfg']
    },

    '471.omnetpp' =>
    {
        'version'   => '2006',
        'type'      => 'int',
        'macro'     => '',

        'test'      => ['omnetpp.ini'],

        'train'     => ['omnetpp.ini'],

        'ref'       => ['omnetpp.ini']
    },

    '473.astar' =>
    {
        'version'   => '2006',
        'type'      => 'int',
        'macro'     => '',

        'test'      => ['lake.cfg'],

        'train'     => ['BigLakes1024.cfg', 'rivers1.cfg'],

        'ref'       => ['BigLakes2048.cfg', 'rivers.cfg']
    },

####################################################################################################

# SPECint 2017 Supported

####################################################################################################

    '600.perlbench_s' =>
    {
        'version'   => '2017',
        'type'      => 'int',
        'macro'     => '-DPERL_CORE -DDOUBLE_SLASHES_SPECIAL=0 -D_LARGE_FILES'.
                       '-D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64',

        'test'      => ['makerand.pl', 'test.pl'],

        'train'     => ['diffmail.pl 2 550 15 24 23 100',
                        'perfect.pl b 3',
                        'scrabbl.pl < scrabbl.in',
                        'splitmail.pl 535 13 25 24 1091 1',
                        'suns.pl'],

        'ref'       => ['checkspam.pl 2500 5 25 11 150 1 1 1 1',
                        'diffmail.pl 4 800 10 17 19 300',
                        'splitmail.pl 6400 12 26 16 100 0']
    },

    '602.gcc_s' =>
    {
        'version'   => '2017',
        'type'      => 'int',
        'macro'     => '-DSPEC_602 -DIN_GCC -DHAVE_CONFIG_H -fgnu89-inline',

        'test'      => ['t1.c -O3 -finline-limit=50000 -o t1.opts-O3_-finline-limit_50000.s'],

        'train'     => ['200.c -O3 -finline-limit=50000 -o 200.opts-O3_-finline-limit_50000.s',
                        'scilab.c -O3 -finline-limit=50000 -o scilab.opts-O3_-finline-limit_50000.s',
                        'train01.c -O3 -finline-limit=50000 -o train01.opts-O3_-finline-limit_50000.s'],

        'ref'       => ['gcc-pp.c -O5 -fipa-pta -o gcc-pp.opts-O5_-fipa-pta.s',
                        'gcc-pp.c -O5 -finline-limit=1000 -fselective-scheduling -fselective-scheduling2 -o gcc-pp.opts-O5_-finline-limit_1000_-fselective-scheduling_-fselective-scheduling2.s',
                        'gcc-pp.c -O5 -finline-limit=24000 -fgcse -fgcse-las -fgcse-lm -fgcse-sm -o gcc-pp.opts-O5_-finline-limit_24000_-fgcse_-fgcse-las_-fgcse-lm_-fgcse-sm.s']
    },

    '605.mcf_s' =>
    {
        'version'   => '2017',
        'type'      => 'int',
        'macro'     => '',

        'test'      => ['inp.in'],

        'train'     => ['inp.in'],

        'ref'       => ['inp.in']
    },

    '620.omnetpp_s' =>
    {
        'version'   => '2017',
        'type'      => 'int',
        'macro'     => '-DWITH_NETBUILDER',

        'test'      => ['-c General -r 0'],

        'train'     => ['-c General -r 0'],

        'ref'       => ['-c General -r 0']
    },

    '623.xalancbmk_s' =>
    {
        'version'   => '2017',
        'type'      => 'int',
        'macro'     => '-DAPP_NO_THREADS -DXALAN_INMEM_MSG_LOADER -DPROJ_XMLPARSER -DPROJ_XMLUTIL'.
                       ' -DPROJ_PARSERS -DPROJ_SAX4C -DPROJ_SAX2 -DPROJ_DOM -DPROJ_VALIDATORS'.
                       ' -DXML_USE_INMEM_MESSAGELOADER',

        'test'      => ['-v test.xml xalanc.xsl'],

        'train'     => ['-v allbooks.xml xalanc.xsl'],

        'ref'       => ['-v t5.xml xalanc.xsl']
    },

    '631.deepsjeng_s' =>
    {
        'version'   => '2017',
        'type'      => 'int',
        'macro'     => '-DNDEBUG -DBIG_MEMORY',

        'test'      => ['test.txt'],

        'train'     => ['train.txt'],

        'ref'       => ['ref.txt']
    },

    '641.leela_s' =>
    {
        'version'   => '2017',
        'type'      => 'int',
        'macro'     => '',

        'test'      => ['test.sgf'],

        'train'     => ['train.sgf'],

        'ref'       => ['ref.sgf']
    },

    '648.exchange2_s' =>
    {
        'version'   => '2017',
        'type'      => 'int',
        'macro'     => '',

        'test'      => ['0'],

        'train'     => ['1'],

        'ref'       => ['6']
    },

    '657.xz_s' =>
    {
        'version'   => '2017',
        'type'      => 'int',
        'macro'     => '-DSPEC_AUTO_BYTEORDER=0x12345678 -DHAVE_CONFIG_H=1 -DSPEC_MEM_IO -DSPEC_XZ',

        'test'      => ['cpu2006docs.tar.xz 4 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 1548636 1555348 0',
                        'cpu2006docs.tar.xz 4 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 1462248 -1 1',
                        'cpu2006docs.tar.xz 4 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 1428548 -1 2',
                        'cpu2006docs.tar.xz 4 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 1034828 -1 3e',
                        'cpu2006docs.tar.xz 4 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 1061968 -1 4',
                        'cpu2006docs.tar.xz 4 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 1034588 -1 4e',
                        'cpu2006docs.tar.xz 1 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 650156 -1 0',
                        'cpu2006docs.tar.xz 1 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 639996 -1 1',
                        'cpu2006docs.tar.xz 1 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 637616 -1 2',
                        'cpu2006docs.tar.xz 1 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 628996 -1 3e',
                        'cpu2006docs.tar.xz 1 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 631912 -1 4',
                        'cpu2006docs.tar.xz 1 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 629064 -1 4e'],

        'train'     => ['input.combined.xz 40 a841f68f38572a49d86226b7ff5baeb31bd19dc637a922a972b2e6d1257a890f6a544ecab967c313e370478c74f760eb229d4eef8a8d2836d233d3e9dd1430bf 6356684 -1 8',
                        'IMG_2560.cr2.xz 40 ec03e53b02deae89b6650f1de4bed76a012366fb3d4bdc791e8633d1a5964e03004523752ab008eff0d9e693689c53056533a05fc4b277f0086544c6c3cbbbf6 40822692 40824404 4'],

        'ref'       => ['cpu2006docs.tar.xz 6643 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 1036078272 1111795472 4',
                        'cld.tar.xz 1400 19cf30ae51eddcbefda78dd06014b4b96281456e078ca7c13e1c0c9e6aaea8dff3efb4ad6b0456697718cede6bd5454852652806a657bb56e07d61128434b474 536995164 539938872 8']
    },

####################################################################################################

# SPECfp 2017 Supported

####################################################################################################
    
    '603.bwaves_s' =>
    {
        'version'   => '2017',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => ['< bwaves_1.in', '< bwaves_2.in'],

        'train'     => ['< bwaves_1.in', '< bwaves_2.in'],

        'ref'       => ['< bwaves_1.in', '< bwaves_2.in']
    },

    '654.roms_s' =>
    {
        'version'   => '2017',
        'type'      => 'fp',
        'macro'     => '-w -m literal-single.pm -m c-comment.pm '.
                       '-DBENCHMARK -DNestedGrids=1 -DNO_GETTIMEOFDAY',

        'test'      => ['< ocean_benchmark0.in'],

        'train'     => ['< ocean_benchmark1.in'],

        'ref'       => ['< ocean_benchmark3.in']
    }
);

%UNSUPPORTED_BENCHMARKS =
(

####################################################################################################

# SPECint 2006 Unsupported

####################################################################################################

    '483.xalancbmk' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'int',
        'macro'     => '-DSPEC_CPU_LINUX -DAPP_NO_THREADS -DXALAN_INMEM_MSG_LOADER'.
                       '-DPROJ_XMLPARSER -DPROJ_XMLUTIL -DPROJ_PARSERS -DPROJ_SAX4C'.
                       '-DPROJ_SAX2 -DPROJ_DOM -DPROJ_VALIDATORS -DXML_USE_NATIVE_TRANSCODER'.
                       '-DXML_USE_INMEM_MESSAGELOADER -DXML_USE_PTHREADS',

        'test'      => ['-v t5.xml xalanc.xsl'],

        'train'     => [],

        'ref'       => ['-v test.xml xalanc.xsl']
    },

####################################################################################################

# SPECint 2017 Unsupported

####################################################################################################

    '625.x264_s' =>
    {
        'reason'    => 'multiple inputs',
        'version'   => '2017',
        'type'      => 'int',
        'macro'     => '-DSPEC_AUTO_BYTEORDER=0x12345678',
        'setup'     =>
        {
            'filelist'  => '17_x264_ldecode.filelist',
            'run'       => ['-i BuckBunny.264 -o BuckBunny.yuv']
        },
        
        'test'      => ['--dumpyuv 50 --frames 156 -o BuckBunny_New.264 BuckBunny.yuv 1280x720'],

        'train'     => [],

        'ref'       => []
    },

####################################################################################################

# SPECfp 2006 Unsupported

####################################################################################################

    '410.bwaves' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '416.gamess' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '433.milc' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '434.zeusmp' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '435.gromacs' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '436.cactusADM' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '437.leslie3d' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '444.namd' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '447.dealII' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '450.soplex' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '453.povray' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '454.calculix' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '459.GemsFDTD' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '465.tonto' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '470.lbm' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '481.wrf' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '482.sphinx3' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2006',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

####################################################################################################

# SPECfp 2017 Unsupported

####################################################################################################

    '526.blender_r' =>
    {
        'version'   => '2017',
        'type'      => 'fp',
        'macro'     => '-DSPEC_AUTO_BYTEORDER=0x12345678'.
                       '-DGLEW_NO_ES -DGLEW_STATIC -DWITH_DNA_GHASH -DWITH_GL_PROFILE_COMPAT'.
                       '-DWITH_HEADLESS -DHAVE_UNSIGNED_CHAR -DHAVE_STDBOOL_H -funsigned-char',

        'test'      => ['cube.blend --render-output cube_ --threads 1 -b -F RAWTGA -s 1 -e 1 -a'],

        'train'     => [],

        'ref'       => []
    },

    '607.cactuBSSN_s' =>
    {
        'version'   => '2017',
        'type'      => 'fp',
        'macro'     => '-DCCODE',

        'test'      => ['spec_test.par'],

        'train'     => [],

        'ref'       => []
    },

    '619.lbm_s' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2017',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '621.wrf_s' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2017',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '627.cam4_s' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2017',
        'type'      => 'fp',
        'macro'     => '-stack_size,0x10000000',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '628.pop2_s' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2017',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '638.imagick_s' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2017',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '644.nab_s' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2017',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    },

    '649.fotonik3d_s' =>
    {
        'reason'    => 'TODO work',
        'version'   => '2017',
        'type'      => 'fp',
        'macro'     => '',

        'test'      => [],

        'train'     => [],

        'ref'       => []
    }

);