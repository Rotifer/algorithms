package CircularBuffer;
use Modern::Perl;
use Data::Dumper;
use Carp qw(carp croak);

sub new {
    my $class = shift;
    my $size = shift;
    my @buffer = ( (undef) x $size);
    my $self = {};
    bless $self, $class;
    $self->{buffer} = \@buffer;
    $self->{size} = $size;
    $self->{low} = 0;
    $self->{high} = 0;
    $self->{count} = 0;
    return $self;
}

sub is_empty{
    my $self = shift;
    return $self->{count} == 0;
}

sub is_full {
    my $self = shift;
    return $self->{count} == $self->{size};
}

sub add {
    my $self = shift;
    my $value = shift;
    if ( $self->is_full() ) {
        $self->{low} = ($self->{low} + 1) % $self->{size};
    } else {
        $self->{count}++;
    }
    $self->{buffer}->[ $self->{high} ] = $value;
    $self->{high} = ($self->{high} + 1) % $self->{size};
}

sub remove {
    my $self = shift;
    if ( $self->{count} == 0 ) {
        croak('Circular buffer is empty');
    }
    my $value = $self->{buffer}->[ $self->{low} ];
    $self->{low} = ( $self->{low} + 1 ) % $self->{size};
    $self->{count}--;
    return $value;
}

sub to_string {
    my $self = shift;
    return Dumper($self);
}

my $cb = CircularBuffer->new(5);
say ref $cb;
say $cb->to_string();
foreach my $i (0..5) {
  $cb->add($i);
}
say $cb->to_string();


