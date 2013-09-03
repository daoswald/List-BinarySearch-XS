use 5.008000;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'List::BinarySearch::XS',
    VERSION_FROM        => 'lib/List/BinarySearch/XS.pm', # finds $VERSION
    PREREQ_PM           => {},          # e.g., Module::Name => 1.1
    ($] >= 5.005 ?                      # New keywords supported since 5.005
      (ABSTRACT_FROM    => 'lib/List/BinarySearch/XS.pm', # Retrieve abstract
       AUTHOR           => 'David Oswald <davido [@at] cpan [d.o.t.] org>') : ()),
    LICENSE             => 'perl',
    LIBS                => [''],        # e.g., '-lm'
    DEFINE              => '',          # e.g., '-DHAVE_SOMETHING'
    INC                 => '-I.',       # e.g., '-I. -I/usr/include/other'
    CONFIGURE_REQUIRES  => {
      'ExtUtils::MakeMaker' => '6.62',  # Core, but updated version.
    },
    BUILD_REQUIRES      => {
      'Test::More'  => '0.98',          # Core, but we use newer semantics.
      'English'     => '0',             # Core, but since when?
    },
);
